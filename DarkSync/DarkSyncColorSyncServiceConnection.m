//
//  DarkSyncColorSyncServiceConnection.m
//  DarkSync
//
//  Created by Cătălin Stan on 08/06/2021.
//

#import "DarkSyncColorSyncServiceConnection.h"
#import "DarkSyncColorSyncServiceProtocol.h"

NS_ASSUME_NONNULL_BEGIN

__attribute__((objc_direct_members))
@interface DarkSyncColorSyncServiceConnection ()

@property (readonly) NSCondition *condition;

@end

NS_ASSUME_NONNULL_END

@implementation DarkSyncColorSyncServiceConnection

- (instancetype)initWithServiceName:(NSString *)serviceName {
    self = [super initWithServiceName:serviceName];
    if (self) {
        self.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(DarkSyncColorSyncServiceProtocol)];
        _condition = [NSCondition new];        
    }
    return self;
}
#pragma mark - DarkSyncColorSyncServiceConnection

- (void)wait {
    [self.condition wait];
}

- (BOOL)waitUntilDate:(nonnull NSDate *)limit {
    return [self.condition waitUntilDate:limit];
}

- (void)signal {
    [self.condition signal];
}

@end
