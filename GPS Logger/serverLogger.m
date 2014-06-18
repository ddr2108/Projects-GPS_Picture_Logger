//
//  serverLogger.m
//  GPS Logger
//
//  Created by Deep Datta Roy on 6/14/14.
//  Copyright (c) 2014 Deep Datta Roy. All rights reserved.
//

#import "serverLogger.h"

@implementation serverLogger{
    NSUserDefaults *defaults;
    
    NSString* userName;
    NSString* deviceName;
    NSInteger daysHistory;

    NSString* date;
    NSInteger time;

}

    /*
     * init()
     *
     * parameters:
     * 	none
     * returns:
     * 	id - id of object
     *
     * constructor - sets up initialization for connection with server
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
            daysHistory = [[defaults objectForKey:@"daysHistory"] integerValue];

            //Get the date/time info
            NSDate *currentDate = [NSDate date];
            unsigned units = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit;
            NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            NSDateComponents *dateComponents = [calendar components:units fromDate:currentDate];
            date = [NSString stringWithFormat:@"%ld-%ld-%ld", [dateComponents month], [dateComponents day], [dateComponents year]];
            time = [dateComponents hour]*60+[dateComponents minute];


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
     * Saves the GPS data to the server
     */
    - (BOOL) saveGPS: (double*)coordinates{
        
        //Pull out coordinates
        double longitude = coordinates[0];
        double latitude = coordinates[1];

        //Create the request
        NSString *request = [NSString stringWithFormat:@"http://deepdattaroy.com/other/projects/GPS%%20Logger/save_gps.php?userName=%@&deviceName=%@&date=%@&time=%ld&longitude=%f&latitude=%f",
                                   userName,
                                   deviceName,
                                   date,
                                   (long)time,
                                   longitude,
                                   latitude];
        NSURL *url = [NSURL URLWithString:request];
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url
                                                            cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                            timeoutInterval:10];
        [urlRequest setHTTPMethod: @"GET"];

        //Send request
        NSError *urlError = NULL;
        NSURLResponse *urlResponse = NULL;
        NSData *urlReturn = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&urlResponse error:&urlError];
        
        //Return whether actually inserted
        return [[[NSString alloc] initWithData:urlReturn encoding:NSUTF8StringEncoding] isEqualToString:@"Inserted"];

    }

    /*
     * saveGPS(), forDate, forTime
     *
     * parameters:
     * 	double* coordinates - array with [longitude latitude]
     *  NSString* date - date to insert
     *  NSInteger time - time to insert
     * returns:
     * 	boolean - true if data inserted
     *
     * Saves the GPS data to the server
     */
    - (BOOL) saveGPS: (double*)coordinates forDate:(NSString*)oldDate forTime:(NSInteger)oldTime {
        
        //Save the modified date/time
        date = oldDate;
        time = oldTime;
        
        //Call normal saving function
        return [self saveGPS:coordinates];
        
    }

    /*
     * deleteGPS()
     *
     * parameters:
     * 	none
     * returns:
     * 	BOOL - true if deleted
     *
     * Deletes from server all the GPS data assocated with this user/device
     */
    - (BOOL) deleteGPS {
        
        //Create the request
        NSString *request = [NSString stringWithFormat:@"http://deepdattaroy.com/other/projects/GPS%%20Logger/delete_gps.php?userName=%@&deviceName=%@",
                             userName,
                             deviceName];
        NSURL *url = [NSURL URLWithString:request];
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url
                                                                  cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                              timeoutInterval:10];
        [urlRequest setHTTPMethod: @"GET"];
        
        //Send request
        NSError *urlError = NULL;
        NSURLResponse *urlResponse = NULL;
        NSData *urlReturn = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&urlResponse error:&urlError];
        
        //Return whether actually inserted
        return [[[NSString alloc] initWithData:urlReturn encoding:NSUTF8StringEncoding] isEqualToString:@"Deleted"];
        
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
    - (NSArray*) getLocations {
    
        //Create the request
        NSString *request = [NSString stringWithFormat:@"http://deepdattaroy.com/other/projects/GPS%%20Logger/get_locations.php?userName=%@&deviceName=%@&date=%@&daysHistory=%ld",
                                   userName,
                                   deviceName,
                                   date,
                                   daysHistory];
        NSURL *url = [NSURL URLWithString:request];
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url
                                                            cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                            timeoutInterval:10];
        [urlRequest setHTTPMethod: @"GET"];
        
        //Send request
        NSError *urlError = NULL;
        NSURLResponse *urlResponse = NULL;
        NSData *urlReturn = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&urlResponse error:&urlError];
                
        //Parse Data
        return [[[NSString alloc] initWithData:urlReturn encoding:NSUTF8StringEncoding] componentsSeparatedByString:@" "];
        
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
    - (int) getNumLocations {
        
        //Create the request
        NSString *request = [NSString stringWithFormat:@"http://deepdattaroy.com/other/projects/GPS%%20Logger/get_locations.php?userName=%@&deviceName=%@&date=%@&daysHistory=%d",
                             userName,
                             deviceName,
                             date,
                             -1];
        NSURL *url = [NSURL URLWithString:request];
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url
                                                                  cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                              timeoutInterval:10];
        [urlRequest setHTTPMethod: @"GET"];
        
        //Send request
        NSError *urlError = NULL;
        NSURLResponse *urlResponse = NULL;
        NSData *urlReturn = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&urlResponse error:&urlError];
        
        //Parse Data
        return (int)[[[NSString alloc] initWithData:urlReturn encoding:NSUTF8StringEncoding] integerValue];
        
    }

@end
