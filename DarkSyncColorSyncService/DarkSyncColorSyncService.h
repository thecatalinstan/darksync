//
//  DarkSyncColorSyncService.h
//  DarkSyncColorSyncService
//
//  Created by Cătălin Stan on 08/06/2021.
//

#import <Foundation/Foundation.h>
#import "DarkSyncColorSyncServiceProtocol.h"

// This object implements the protocol which we have defined. It provides the actual behavior for the service. It is 'exported' by the service to make it available to the process hosting the service over an NSXPCConnection.
@interface DarkSyncColorSyncService : NSObject <DarkSyncColorSyncServiceProtocol>
@end
