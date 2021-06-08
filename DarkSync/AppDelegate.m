//
//  AppDelegate.m
//  DarkSync
//
//  Created by Cătălin Stan on 08/06/2021.
//

#import "AppDelegate.h"

static void *const effectiveAppearanceContext = (void *)&effectiveAppearanceContext;

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

@interface AppDelegate ()

@property (strong) IBOutlet NSWindow *window;
@property NSURL *darkProfile;
@property NSURL *lightProfile;

@end

@implementation AppDelegate

- (void)interfaceThemeChanged:(NSAppearance *)appearance {
    NSURL *profile;
    if ([appearance.name localizedCaseInsensitiveContainsString:@"dark"]) {
        profile = self.darkProfile;
    } else {
        profile = self.lightProfile;
    }
    
    if (!profile) {
        return;
    }
 
    NSLog(@" * %@", profile.lastPathComponent);
    NSDictionary *profileInfo = @{
        (__bridge id)kColorSyncDeviceDefaultProfileID: profile
    };
    ColorSyncDeviceSetCustomProfiles(kColorSyncDisplayDeviceClass, CGDisplayCreateUUIDFromDisplayID(CGMainDisplayID()), (__bridge CFDictionaryRef)profileInfo);
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    CFErrorRef error;
    NSMutableArray<NSURL *> *profiles = [NSMutableArray arrayWithCapacity:16];
    NSDictionary *opts;
    if (@available(macOS 11.0, *)) {
        opts = @{ (__bridge id)kColorSyncWaitForCacheReply: @YES };
    } else {
        opts = @{};
    }
    ColorSyncIterateInstalledProfilesWithOptions(ProfileIterateCallback, NULL, (void *)profiles, (CFDictionaryRef)opts, &error);
    if (error) {
        NSLog(@" *** error: %@", (__bridge NSError *)error);
        [NSApplication.sharedApplication terminate:self];
        return;
    }
    
    NSLog(@" * %@", [profiles valueForKeyPath:@"lastPathComponent"]);

    self.lightProfile = profiles[2];
    self.darkProfile = profiles[1];
    
    [NSApplication.sharedApplication addObserver:self forKeyPath:@"effectiveAppearance" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:effectiveAppearanceContext];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (context == effectiveAppearanceContext) {
        NSAppearance *new = change[NSKeyValueChangeNewKey];
        SEL selector = @selector(interfaceThemeChanged:);
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:selector object:nil];
        [self performSelector:selector withObject:new afterDelay:0.5];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
