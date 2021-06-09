//
//  DarkSyncColorSyncServiceProvider.h
//  DarkSync
//
//  Created by Cătălin Stan on 08/06/2021.
//

#import <Foundation/Foundation.h>

#import "DarkSyncColorSyncServiceProtocol.h"
#import "DarkSyncColorSyncServiceConnection.h"

NS_ASSUME_NONNULL_BEGIN

@protocol DarkSyncColorSyncServiceProviderProtocol

- (id<DarkSyncColorSyncServiceConnectionProtocol>)connectionWithRemoteObjectProxy:(id<DarkSyncColorSyncServiceProtocol> _Nullable __autoreleasing *_Nonnull)remoteObjectProxy errorHandler:(void(^)(NSError *))errorHandler;

@end

@interface DarkSyncColorSyncServiceProvider : NSObject <DarkSyncColorSyncServiceProviderProtocol>

@property (class, readonly) DarkSyncColorSyncServiceProvider *defaultProvider;

@end

NS_ASSUME_NONNULL_END
