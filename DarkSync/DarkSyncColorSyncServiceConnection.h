//
//  DarkSyncColorSyncServiceConnection.h
//  DarkSync
//
//  Created by Cătălin Stan on 08/06/2021.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DarkSyncColorSyncServiceConnectionProtocol

- (void)wait;
- (BOOL)waitUntilDate:(NSDate *)limit;
- (void)signal;

- (void)invalidate;

@end

@interface DarkSyncColorSyncServiceConnection : NSXPCConnection <DarkSyncColorSyncServiceConnectionProtocol>

@end

NS_ASSUME_NONNULL_END
