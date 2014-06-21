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
    - (BOOL) saveGPS: (double*)coordinates forDate:(NSString*)date forTime:(NSInteger)time;
    - (BOOL) clearHistory;
    - (NSArray*) getLocations;
    - (int) getNumLocations;

@end
