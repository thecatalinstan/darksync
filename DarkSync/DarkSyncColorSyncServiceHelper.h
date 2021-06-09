//
//  DarkSyncColorSyncServiceHelper.h
//  DarkSync
//
//  Created by Cătălin Stan on 08/06/2021.
//

#import <Foundation/Foundation.h>
#import "DarkSyncColorSyncServiceProvider.h"

NS_ASSUME_NONNULL_BEGIN

@protocol DarkSyncColorSyncServiceHelperProtocol

- (BOOL)setColorSyncProfile:(NSURL *)profileURL
                    display:(NSUUID *)displayUUID
                      error:(NSError *__autoreleasing *)error;

@end

@interface DarkSyncColorSyncServiceHelper : NSObject<DarkSyncColorSyncServiceHelperProtocol>

@property (class, readonly) DarkSyncColorSyncServiceHelper *sharedHelper;

- (instancetype)initWithProvider:(id<DarkSyncColorSyncServiceProviderProtocol>)provider NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
