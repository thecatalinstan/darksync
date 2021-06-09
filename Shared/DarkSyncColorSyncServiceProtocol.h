//
//  DarkSyncColorSyncServiceProtocol.h
//  DarkSyncColorSyncService
//
//  Created by Cătălin Stan on 08/06/2021.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DarkSyncColorSyncServiceProtocol

- (void)setColorSyncProfile:(NSString *)profileURLString
                    display:(NSString *)displayUUIDString
                      reply:(void (^)(BOOL, NSError *_Nullable))reply;

@end

NS_ASSUME_NONNULL_END
