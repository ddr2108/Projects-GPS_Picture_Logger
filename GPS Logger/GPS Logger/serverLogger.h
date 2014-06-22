//
//  serverLogger.h
//  GPS Logger
//
//  Created by Deep Datta Roy on 6/14/14.
//  Copyright (c) 2014 Deep Datta Roy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface serverLogger : NSObject

    - (id)init;
    - (BOOL) saveGPS: (double*)coordinates;
    - (BOOL) saveGPS: (double*)coordinates forDate:(NSString*)oldDate forTime:(NSInteger)oldTime forUserName:(NSString*)oldUserName forDeviceName:(NSString*)oldDeviceName;
    - (BOOL) clearHistory;
    - (NSArray*) getLocations;
    - (int) getNumLocations;

@end
