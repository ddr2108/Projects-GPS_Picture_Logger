//
//  localLogger.h
//  GPS Logger
//
//  Created by Deep Datta Roy on 6/17/14.
//  Copyright (c) 2014 Deep Datta Roy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface localLogger : NSObject

    - (id)init;
    - (BOOL) saveGPS: (double*)coordinates;
    - (BOOL) clearHistory;
    - (NSArray*) getLocations;
    - (int) getNumLocations;
    - (BOOL) sendToServer;
    - (void) renameOld:(NSString*)oldUserName forDevice:(NSString*)oldDeviceName;

@end
