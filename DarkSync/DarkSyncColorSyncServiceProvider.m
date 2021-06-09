//
//  DarkSyncColorSyncServiceProvider.m
//  DarkSync
//
//  Created by Cătălin Stan on 08/06/2021.
//

#import "DarkSyncColorSyncServiceProvider.h"

static NSString * const DarkSyncColorSyncServiceName = @"com.catalinstan.DarkSyncColorSyncService";

@implementation DarkSyncColorSyncServiceProvider

+ (DarkSyncColorSyncServiceProvider *)defaultProvider {
    static DarkSyncColorSyncServiceProvider *defaultProvider;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultProvider = [DarkSyncColorSyncServiceProvider new];
    });
    return defaultProvider;
}

#pragma mark - DarkSyncColorSyncServiceProviderProtocol

- (id<DarkSyncColorSyncServiceConnectionProtocol>)connectionWithRemoteObjectProxy:(id<DarkSyncColorSyncServiceProtocol> __autoreleasing *)remoteObjectProxy errorHandler:(void (^)(NSError * _Nonnull))errorHandler {
    DarkSyncColorSyncServiceConnection *connection = [[DarkSyncColorSyncServiceConnection alloc] initWithServiceName:DarkSyncColorSyncServiceName];
    connection.interruptionHandler = ^{
        errorHandler([NSError new]);
    };
    [connection resume];
    
    *remoteObjectProxy = [connection remoteObjectProxyWithErrorHandler:errorHandler];
    
    return connection;
}

@end
