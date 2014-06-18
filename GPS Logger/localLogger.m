//
//  localLogger.m
//  GPS Logger
//
//  Created by Deep Datta Roy on 6/17/14.
//  Copyright (c) 2014 Deep Datta Roy. All rights reserved.
//

#import "localLogger.h"
#import "serverLogger.h"

@implementation localLogger{
    NSUserDefaults *defaults;
    NSString* userName;
    NSString* deviceName;
    
    NSString* date;
    NSInteger time;

    NSString* logPath;
    NSMutableArray* logData;
}

    /*
     * init()
     *
     * parameters:
     * 	none
     * returns:
     * 	id - id of object
     *
     * constructor - sets up initialization for local logging
     */
    - (id)init{
        
        //Do super object intializtion
        self = [super init];
        
        //If initialization successfull
        if (self){
            
            //Get user defaults and get user name and device name
            defaults = [NSUserDefaults standardUserDefaults];
            userName = [defaults objectForKey:@"userName"];
            deviceName = [defaults objectForKey:@"deviceName"];
            
            //Get the date/time info
            NSDate *currentDate = [NSDate date];
            unsigned units = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit;
            NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            NSDateComponents *dateComponents = [calendar components:units fromDate:currentDate];
            date = [NSString stringWithFormat:@"%ld-%ld-%ld", [dateComponents month], [dateComponents day], [dateComponents year]];
            time = [dateComponents hour]*60+[dateComponents minute];

            //Get log location and contents
            logData = [[NSMutableArray alloc] init];
            NSArray* dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            logPath = [[NSString alloc] initWithString: [dirPaths[0] stringByAppendingPathComponent: @"gps_logger.archive"]];
            logData = [NSKeyedUnarchiver unarchiveObjectWithFile:logPath];

        }
        
        //return id
        return self;
    }

    /*
     * saveGPS()
     *
     * parameters:
     * 	double* coordinates - array with [longitude latitude]
     * returns:
     * 	boolean - true if data inserted
     *
     * Saves the GPS data to the local log
     */
    - (BOOL) saveGPS: (double*)coordinates{
        
        //Add information from this logging
        [logData addObject: [NSNumber numberWithDouble:coordinates[0]]];
        [logData addObject: [NSNumber numberWithDouble:coordinates[1]]];
        [logData addObject: date];
        [logData addObject: [NSNumber numberWithLong:time]];

        //Store data to archive
        [NSKeyedArchiver archiveRootObject:logData toFile:logPath];

        //Return success
        return TRUE;
    }

    /*
     * deleteGPS()
     *
     * parameters:
     * 	none
     * returns:
     * 	BOOL - true if deleted
     *
     * Deletes from local all the GPS data assocated with this user/device
     */
    - (BOOL) deleteGPS{
        
        //Clear Data
        logData = [[NSMutableArray alloc] init];
        
        //Store data to archive
        [NSKeyedArchiver archiveRootObject:logData toFile:logPath];
        
        //Return success
        return TRUE;
    }

    /*
     * getLocations()
     *
     * parameters:
     * 	none
     * returns:
     * 	NSArray* - array with all the locations for user/device
     *
     * Gets all the locations assocated with this user/device
     */
    - (NSArray*) getLocations{
        
        //return data
        return logData;
    }

    /*
     * getNumLocations()
     *
     * parameters:
     * 	none
     * returns:
     * 	int - number of locations stores
     *
     * Gets number of locations assocated with this user/device
     */
    - (int) getNumLocations{
        
        //Find number of items locally
        return (int)[logData count]/4;
        
    }

    /*
     * sendToServer()
     *
     * parameters:
     * 	none
     * returns:
     * 	none
     *
     * Sends data in log to server
     */
    - (void) sendToServer{
        
        //Variables for checking sync status
        BOOL sendFail = FALSE;
        NSMutableArray* removedLogData = [[NSMutableArray alloc] init];
        
        //Create connection to server
        serverLogger* serverLog = [[serverLogger alloc] init];
        
        //Go through the points
        for (int i = 0; i < [self getNumLocations]; i++){
            
            //Get the coordinates
            double coordinates[] = {[logData[2*i+0] integerValue], [logData[2*i+1] integerValue]};
            NSString* oldDate = logData[2*i+2];
            NSInteger oldTime = [logData[2*i+3] integerValue];
            
            //Save Data
            BOOL insertSuccess = [serverLog saveGPS:coordinates forDate:oldDate forTime:oldTime];
            
            //Check if insertion was a success
            if (insertSuccess==FALSE){
                //State failure
                sendFail = TRUE;
                break;
            }else{
                //Data to remove
                [removedLogData addObject:logData[2*i+0]];
                [removedLogData addObject:logData[2*i+1]];
                [removedLogData addObject:logData[2*i+2]];
                [removedLogData addObject:logData[2*i+3]];
            }
            
        }
        
        //if all successful, update sync time
        if (sendFail == FALSE){
            NSString *syncTime = [NSString stringWithFormat:@"%@ %ld:%ld", date, time/60, time%60];
            [defaults setObject:syncTime forKey:@"syncTime"];
        }
        
        //Store data to archive
        [logData removeObjectsInArray:removedLogData];
        [NSKeyedArchiver archiveRootObject:logData toFile:logPath];

    }


@end
