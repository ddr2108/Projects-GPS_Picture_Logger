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
            NSArray* dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            logPath = [[NSString alloc] initWithString: [dirPaths[0] stringByAppendingPathComponent: @"gps_logger.archive"]];
            logData = [NSKeyedUnarchiver unarchiveObjectWithFile:logPath];
            
            //Nothing at that path
            if (logData == NULL){
                logData = [[NSMutableArray alloc] init];
            }


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
     * clearHistory()
     *
     * parameters:
     * 	none
     * returns:
     * 	BOOL - true if deleted
     *
     * Deletes from local all the GPS data assocated with this user/device
     */
    - (BOOL) clearHistory{
        
        //Variables for keeping deleted items
        NSMutableArray* removedLogData = [[NSMutableArray alloc] init];
        
        //Go through the points
        for (int i = 0; i < [self getNumLocations]; i++){
            
            //Check if that point is from today
            if ([date  isEqualToString:logData[4*i+2]]){
                //Data to remove
                [removedLogData addObject:logData[4*i+0]];
                [removedLogData addObject:logData[4*i+1]];
                [removedLogData addObject:logData[4*i+2]];
                [removedLogData addObject:logData[4*i+3]];
            }
            
        }
        
        //Store data to archive
        [logData removeObjectsInArray:removedLogData];
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
        
        //Correct the times
        for (int i = 3; i < [logData count]; i+=4){
            NSString* logTime;
            //Check AM or PM
            if (time/60>=12){
                logTime = [NSString stringWithFormat:@"%ld:%02ldPM", ([logData[i] integerValue]/60)%12, [logData[i] integerValue]%60];
            }else{
                logTime = [NSString stringWithFormat:@"%ld:%02ldAM", ([logData[i] integerValue]/60)%12, [logData[i] integerValue]%60];
            }

            [logData replaceObjectAtIndex:i withObject:logTime];
        }
        
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
     * 	BOOL syncTimeSave - whether to save syn time
     * returns:
     * 	BOOL - whether sync succeeded or not
     *
     * Sends data in log to server
     */
    - (BOOL) sendToServer:(BOOL)syncTimeSave{
    
        //Variables for checking sync status
        BOOL sendFail = FALSE;
        NSMutableArray* removedLogData = [[NSMutableArray alloc] init];
        
        //Create connection to server
        serverLogger* serverLog = [[serverLogger alloc] init];
        
        //Go through the points
        for (int i = 0; i < [self getNumLocations]; i++){
            
            //Get the coordinates
            double coordinates[] = {[logData[4*i+0] doubleValue], [logData[4*i+1] doubleValue]};
            NSString* oldDate = logData[4*i+2];
            NSInteger oldTime = [logData[4*i+3] integerValue];

            //Save Data
            BOOL insertSuccess = [serverLog saveGPS:coordinates forDate:oldDate forTime:oldTime forUserName:userName forDeviceName:deviceName];
            
            //Check if insertion was a success
            if (insertSuccess==FALSE){
                //State failure
                sendFail = TRUE;
                break;
            }else{
                //Data to remove
                [removedLogData addObject:logData[4*i+0]];
                [removedLogData addObject:logData[4*i+1]];
                [removedLogData addObject:logData[4*i+2]];
                [removedLogData addObject:logData[4*i+3]];
            }
            
        }
        
        //if all successful, update sync time
        if (sendFail == FALSE){
            NSString *syncTime;
            //Check AM or PM
            if (time/60>=12){
                syncTime = [NSString stringWithFormat:@"%@ %ld:%02ldPM", date, (time/60)%12, time%60];
            }else{
                syncTime = [NSString stringWithFormat:@"%@ %ld:%02ldAM", date, (time/60)%12, time%60];
            }
            [defaults setObject:syncTime forKey:@"syncTime"];
        }
        
        //Store data to archive
        [logData removeObjectsInArray:removedLogData];
        [NSKeyedArchiver archiveRootObject:logData toFile:logPath];
        
        //return success
        return !sendFail;

    }

    /*
     * renameOldLog(), forDevice
     *
     * parameters:
     *  NSString* oldUserName - old user name
     *  NSString* oldDeviceName - old device name
     * returns:
     * 	none
     *
     * Renames a local log file
     */
    - (void) renameOldLog:(NSString*)oldUserName forDevice:(NSString*)oldDeviceName{
        //Rename file
        NSArray* dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString* oldLogPath = [[NSString alloc] initWithString: [dirPaths[0] stringByAppendingPathComponent: [NSString stringWithFormat:@"%@-%@.archive", oldUserName, oldDeviceName]]];
        
        //Save File
        [NSKeyedArchiver archiveRootObject:logData toFile:oldLogPath];
        
        //Open file with list of old files
        NSString* filesPath = [[NSString alloc] initWithString: [dirPaths[0] stringByAppendingPathComponent:@"paths.archive"]];
        NSMutableArray* filesPathData = [NSKeyedUnarchiver unarchiveObjectWithFile:filesPath];
        
        //if file does not exists
        if (filesPathData==NULL){
            filesPathData = [[NSMutableArray alloc] init];
        }

        //Add to list of old files
        [filesPathData addObject: oldUserName];
        [filesPathData addObject: oldDeviceName];

        //Store data to archive
        [NSKeyedArchiver archiveRootObject:filesPathData toFile:filesPath];
        
        //Remove Old file
        logData = [[NSMutableArray alloc] init];
        [NSKeyedArchiver archiveRootObject:logData toFile:logPath];
    }

    /*
     * recoverOldLog()
     *
     * parameters:
     *  none
     * returns:
     * 	none
     *
     * Try to recover old data not uploaded to server
     */
    - (void) recoverOldLog{
        //Get path of possible old file
        NSArray* dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString* oldLogPath = [[NSString alloc] initWithString: [dirPaths[0] stringByAppendingPathComponent: [NSString stringWithFormat:@"%@-%@.archive", userName, deviceName]]];
        
        //Place the data into new log
        NSMutableArray* oldLogData = [[NSMutableArray alloc] init];
        oldLogData = [NSKeyedUnarchiver unarchiveObjectWithFile:oldLogPath];
        
        //if file does not exists
        if (oldLogData==NULL){
            oldLogData = [[NSMutableArray alloc] init];
        }else{
            [[NSFileManager defaultManager] removeItemAtPath:oldLogPath error:NULL];
        }
        
        //Save to log
        [NSKeyedArchiver archiveRootObject:oldLogData toFile:logPath];
    }

    /*
     * saveOldLog()
     *
     * parameters:
     *  none
     * returns:
     * 	none
     *
     * Save old data
     */
    - (void) saveOldLog{
        //Open file with list of old files
        NSArray* dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString* filesPath = [[NSString alloc] initWithString: [dirPaths[0] stringByAppendingPathComponent:@"paths.archive"]];
        NSMutableArray* filesPathData = [NSKeyedUnarchiver unarchiveObjectWithFile:filesPath];
        NSMutableArray* removedFilesPathData = [[NSMutableArray alloc] init];
        
        BOOL saveSuccess;
        //Go through all possible paths
        for (int i = 0; i < ([filesPathData count]); i+=2){
            
            //Pull out names
            userName = filesPathData[i];
            deviceName = filesPathData[i + 1];

            //Pull out paths and open files
            logPath = [[NSString alloc] initWithString: [dirPaths[0] stringByAppendingPathComponent: [NSString stringWithFormat:@"%@-%@.archive", userName, deviceName]]];
            logData = [NSKeyedUnarchiver unarchiveObjectWithFile:logPath];

            //If no data
            if (logData==NULL){
                [removedFilesPathData addObject:filesPathData[i]];
                [removedFilesPathData addObject:filesPathData[i+1]];
                continue;
            }
            
            //Save to server
            saveSuccess = [self sendToServer:FALSE];
            //If successful, delete from list
            if (saveSuccess){
                [removedFilesPathData addObject:filesPathData[i]];
                [removedFilesPathData addObject:filesPathData[i+1]];
                [[NSFileManager defaultManager] removeItemAtPath:logPath error:NULL];
            }
        }
        
        //Remove successfull paths from list
        [filesPathData removeObjectsInArray:removedFilesPathData];
        [NSKeyedArchiver archiveRootObject:filesPathData toFile:filesPath];
        
    }

@end
