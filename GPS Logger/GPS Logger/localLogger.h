//
//  localLogger.h
//  GPS Logger
//
//  Created by Deep Datta Roy on 6/17/14.
//  Copyright (c) 2014 Deep Datta Roy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocalLogger : NSObject

    - (id)init;
    - (BOOL) saveGPS: (double*)coordinates;
    - (BOOL) clearHistory;
    - (NSArray*) getLocations;
    - (int) getNumLocations;
    - (BOOL) sendToServer:(BOOL)syncTimeSave;
    - (void) renameOldLog:(NSString*)oldUserName forDevice:(NSString*)oldDeviceName;
    - (void) recoverOldLog;
    - (void) saveOldLog;


@end
