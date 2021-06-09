//
//  AppDelegate.m
//  DarkSync
//
//  Created by Cătălin Stan on 08/06/2021.
//

#import "AppDelegate.h"

static void *const effectiveAppearanceContext = (void *)&effectiveAppearanceContext;
static NSTimeInterval delay = 0;

void DisplayReconfigurationCallBack(CGDirectDisplayID display, CGDisplayChangeSummaryFlags flags, void *context);
bool ProfileIterateCallback(CFDictionaryRef profileInfo, void* context);

@interface NSAppearance (DarkSync)

@property (nonatomic, readonly) BOOL isDarkAppearance;

@end

@implementation NSAppearance (DarkSync)

- (BOOL)isDarkAppearance {
    return [self.name localizedCaseInsensitiveContainsString:@"dark"];
}

@end

@interface AppDelegate ()

@property NSURL *darkProfileURL;
@property NSURL *lightProfileURL;

@end

@implementation AppDelegate

- (void)interfaceThemeChanged:(NSAppearance *)appearance {
    NSURL *profileURL;
    if (!(profileURL = appearance.isDarkAppearance ? self.darkProfileURL : self.lightProfileURL)) {
        return;
    }
    
    CFErrorRef errorRef;
    ColorSyncProfileRef profile;
    if (!(profile = ColorSyncProfileCreateWithURL((__bridge CFURLRef)profileURL, &errorRef))) {
        NSLog(@"%@", (__bridge NSError *)errorRef);
        return;
    }
    
    size_t nSamplesPerChannel = 0;
    NSData *tables;
    if (!(tables = (__bridge_transfer NSData *)ColorSyncProfileCreateDisplayTransferTablesFromVCGT(profile, &nSamplesPerChannel))) {
        CFRelease(profile);
        return;
    }
    CFRelease(profile);
    
    const CGGammaValue *redTable = tables.bytes;
    const CGGammaValue *greenTable = redTable + nSamplesPerChannel;
    const CGGammaValue *blueTable = greenTable + nSamplesPerChannel;
        
    if (kCGErrorSuccess != CGSetDisplayTransferByTable(CGMainDisplayID(),(uint32_t)nSamplesPerChannel, redTable, greenTable, blueTable)) {
        return;
    }
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSMutableArray<NSURL *> *profiles = [NSMutableArray arrayWithCapacity:16];
    NSDictionary *opts;
    if (@available(macOS 11.0, *)) {
        opts = @{ (__bridge id)kColorSyncWaitForCacheReply: @YES };
    } else {
        opts = @{};
    }

    CFErrorRef error;
    ColorSyncIterateInstalledProfilesWithOptions(ProfileIterateCallback, NULL, (void *)profiles, (CFDictionaryRef)opts, &error);
    if (error) {
        NSLog(@" *** error: %@", (__bridge NSError *)error);
        [NSApplication.sharedApplication terminate:self];
        return;
    }
    
    NSLog(@" * %@", [profiles valueForKeyPath:@"lastPathComponent"]);

    self.lightProfileURL = profiles[2];
    self.darkProfileURL = profiles[1];
    
    [NSApplication.sharedApplication addObserver:self forKeyPath:@"effectiveAppearance" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:effectiveAppearanceContext];
    
    CGError err;
    if (kCGErrorSuccess != (err = CGDisplayRegisterReconfigurationCallback(DisplayReconfigurationCallBack, (void *)self))) {
        NSLog(@"CGDisplayRegisterReconfigurationCallback failed. %d\n", err);
    }
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    CGDisplayRemoveReconfigurationCallback(DisplayReconfigurationCallBack, (void *)self);
    CGRestorePermanentDisplayConfiguration();
    CGDisplayRestoreColorSyncSettings();
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (context == effectiveAppearanceContext) {
        NSAppearance *new = change[NSKeyValueChangeNewKey];
        SEL selector = @selector(interfaceThemeChanged:);
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:selector object:nil];
        [self performSelector:selector withObject:new afterDelay:0.5];
        delay = 0.5;
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end

void DisplayReconfigurationCallBack(CGDirectDisplayID display, CGDisplayChangeSummaryFlags flags, void *context) {
    AppDelegate *delegate = (__bridge AppDelegate *)context;
    [delegate interfaceThemeChanged:NSApplication.sharedApplication.effectiveAppearance];
}

bool ProfileIterateCallback (CFDictionaryRef profileInfo, void* context) {
    NSMutableArray *profiles = (__bridge NSMutableArray *)context;
    
    CFURLRef profileURL;
    if (!(profileURL = CFDictionaryGetValue(profileInfo, kColorSyncProfileURL)) || CFNullGetTypeID() == CFGetTypeID(profileURL)) {
        return true;
    }

    CFStringRef profileClass;
    if (!(profileClass = CFDictionaryGetValue(profileInfo, kColorSyncProfileClass)) || !CFEqual(profileClass, kColorSyncSigDisplayClass)) {
        return true;
    }
    
    ColorSyncProfileRef profile;
    CFDataRef model = NULL;
        
    CFErrorRef error;
    if (!(profile = ColorSyncProfileCreateWithURL(profileURL, &error))) {
        NSLog(@" *** error: %@", (__bridge NSError *)error);
        goto cleanup;
    }
    
    if (!(model = ColorSyncProfileCopyTag(profile, CFSTR("mmod")))) {
        goto cleanup;
    }
    
    [profiles addObject:(__bridge NSURL *)profileURL];
    
cleanup:
    if (profile) {
        CFRelease(profile);
    }
    if (model) {
        CFRelease(model);
    }
    
    return true;
}
