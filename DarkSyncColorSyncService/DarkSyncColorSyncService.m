//
//  DarkSyncColorSyncService.m
//  DarkSyncColorSyncService
//
//  Created by Cătălin Stan on 08/06/2021.
//

#import "DarkSyncColorSyncService.h"

#import <ColorSync/ColorSync.h>
#import <CoreGraphics/CoreGraphics.h>

@implementation DarkSyncColorSyncService

- (void)setColorSyncProfile:(NSString *)profileURLString display:(NSString *)displayUUIDString reply:(void (^)(BOOL, NSError *))reply {
    BOOL status = YES;
    NSError *error;
    
    NSURL *profileURL;
    CFUUIDRef displayUUIDRef = NULL;
    NSDictionary *deviceInfo;
    
    if (!(profileURL = [[NSURL alloc] initWithString:profileURLString])) {
        error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorUnsupportedURL userInfo:@{
            NSURLErrorFailingURLStringErrorKey: profileURLString
        }];
        status = NO;
        goto done;
    }
    
    if (!(displayUUIDRef = CFUUIDCreateFromString(kCFAllocatorDefault, (CFStringRef)displayUUIDString))) {
        error = [NSError errorWithDomain:NSPOSIXErrorDomain code:EINVAL userInfo:@{
            NSLocalizedDescriptionKey: @(strerror(EINVAL)),
            NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"Invalid UUID: %@", displayUUIDString],
        }];
        status = NO;
        goto done;
    }
    
    
    deviceInfo = (__bridge_transfer NSDictionary *)ColorSyncDeviceCopyDeviceInfo(kColorSyncDisplayDeviceClass, displayUUIDRef);
    if (!CFEqual((__bridge CFUUIDRef)deviceInfo[(__bridge id)kColorSyncDeviceID], displayUUIDRef)) {
        error = [NSError errorWithDomain:NSPOSIXErrorDomain code:ENODEV userInfo:@{
            NSLocalizedDescriptionKey: @(strerror(ENODEV)),
            NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"ColorSyncDeviceCopyDeviceInfo returned UUID: %@, expecting %@", CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, (__bridge CFUUIDRef)deviceInfo[(__bridge id)kColorSyncDeviceID])),  CFUUIDCreateString(kCFAllocatorDefault, displayUUIDRef)],
        }];
        status = NO;
        goto done;
    }
    
    
    if (!ColorSyncDeviceSetCustomProfiles(kColorSyncDisplayDeviceClass, displayUUIDRef, (__bridge CFDictionaryRef)@{
        (__bridge id)kColorSyncDeviceDefaultProfileID: profileURL,
                                                                                                                  })) {
        error = [NSError errorWithDomain:NSPOSIXErrorDomain code:ENXIO userInfo:@{
            NSLocalizedDescriptionKey: @(strerror(ENXIO)),
            NSLocalizedFailureReasonErrorKey: @"ColorSyncDeviceSetCustomProfiles failed.",
        }];
        status = NO;
        goto done;
    }
    
done:
    if (displayUUIDRef) {
        CFRelease(displayUUIDRef);
        displayUUIDRef = NULL;
    }
    reply(status, error);
}

@end
