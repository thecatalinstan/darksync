//
//  DarkSyncColorSyncServiceHelper.m
//  DarkSync
//
//  Created by Cătălin Stan on 08/06/2021.
//

#import "DarkSyncColorSyncServiceHelper.h"

#import "DarkSyncColorSyncServiceProvider.h"
#import "DarkSyncColorSyncServiceConnection.h"

NS_ASSUME_NONNULL_BEGIN

__attribute__((objc_direct_members))
@interface DarkSyncColorSyncServiceHelper ()

@property (nonatomic, readonly) id<DarkSyncColorSyncServiceProviderProtocol> provider;

@end

NS_ASSUME_NONNULL_END

@implementation DarkSyncColorSyncServiceHelper

+ (DarkSyncColorSyncServiceHelper *)sharedHelper {
    static DarkSyncColorSyncServiceHelper *sharedHelper;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedHelper = [[DarkSyncColorSyncServiceHelper alloc] initWithProvider:DarkSyncColorSyncServiceProvider.defaultProvider];
    });
    return sharedHelper;
}

- (instancetype)initWithProvider:(id<DarkSyncColorSyncServiceProviderProtocol>)provider {
    self = [super init];
    if (self) {
        _provider = provider;
    }
    return self;
}

#pragma mark - DarkSyncColorSyncServiceHelperProtocol

- (BOOL)setColorSyncProfile:(NSURL *)profileURL display:(NSUUID *)displayUUID error:(NSError *__autoreleasing  _Nullable *)error {
    __block BOOL result = YES;
    __block NSError *err;
    id<DarkSyncColorSyncServiceProtocol> proxy;
    id<DarkSyncColorSyncServiceConnectionProtocol> connection = [self.provider connectionWithRemoteObjectProxy:&proxy errorHandler:^(NSError *error) {
        result = NO;
        err = error;
    }];
    
    [proxy setColorSyncProfile:profileURL.absoluteString display:displayUUID.UUIDString reply:^(BOOL status, NSError *error) {
        result = status;
        err = error;
        
        [connection signal];
    }];
    
    [connection wait];
    [connection invalidate];
    
    if (error) {
        *error = err;
    }
    
    return result;
}

@end
