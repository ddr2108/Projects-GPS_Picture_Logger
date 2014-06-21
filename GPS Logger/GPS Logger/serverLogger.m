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
        NSString* base = @"saveGPS.php";
        NSArray* parameters =[NSArray arrayWithObjects: @"userName", @"deviceName", @"date", @"time", @"longitude", @"latitude", nil];
        NSArray* data = [NSArray arrayWithObjects: userName, deviceName, date, [NSString stringWithFormat:@"%ld", time], [NSString stringWithFormat:@"%f", longitude], [NSString stringWithFormat:@"%f", latitude],nil];
        NSMutableURLRequest *request = [self generateRequest:base forParameters:parameters forData:data];
        
        //Get data from request
        NSData *urlReturn = [self processRequest:request];
        
        //If connection could not be made
        if (urlReturn==NULL){
            return FALSE;
        }
        
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
     * clearHistory()
     *
     * parameters:
     * 	none
     * returns:
     * 	BOOL - true if deleted
     *
     * Deletes from server all the GPS data assocated with this user/device
     */
    - (BOOL) clearHistory {
        
        //Create the request
        NSString* base = @"deleteGPS.php";
        NSArray* parameters =[NSArray arrayWithObjects: @"userName", @"deviceName", @"date", @"deleteID", nil];
        NSArray* data = [NSArray arrayWithObjects: userName, deviceName, date, @"-1",nil];
        NSMutableURLRequest *request = [self generateRequest:base forParameters:parameters forData:data];
        
        //Get data from request
        NSData *urlReturn = [self processRequest:request];
        
        //If connection could not be made
        if (urlReturn==NULL){
            return FALSE;
        }
        
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
        NSString* base = @"getLocations.php";
        NSArray* parameters =[NSArray arrayWithObjects: @"userName", @"deviceName", @"date", @"daysHistory", nil];
        NSArray* data = [NSArray arrayWithObjects: userName, deviceName, date, [NSString stringWithFormat:@"%ld", daysHistory], nil];
        NSMutableURLRequest *request = [self generateRequest:base forParameters:parameters forData:data];

        //Get data from request
        NSData *urlReturn = [self processRequest:request];
        
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
        NSString* base = @"getLocations.php";
        NSArray* parameters =[NSArray arrayWithObjects: @"userName", @"deviceName", @"date", @"daysHistory", nil];
        NSArray* data = [NSArray arrayWithObjects: userName, deviceName, date, @"-1", nil];
        NSMutableURLRequest *request = [self generateRequest:base forParameters:parameters forData:data];

        //Get data from request
        NSData *urlReturn = [self processRequest:request];
        
        //If connection could not be made
        if (urlReturn==NULL){
            return 0;
        }
        
        //Parse Data
        return (int)[[[NSString alloc] initWithData:urlReturn encoding:NSUTF8StringEncoding] integerValue];
        
    }

    /*
     * generateRequest(), forParameters, forData
     *
     * parameters:
     * 	NSString* page - base page
     *  NSArray* parameters - parameters
     *  NSArray* data - the actual data
     * returns:
     * 	NSMutableURLRequest* request - the request url
     *
     * Process the request
     */
    -(NSMutableURLRequest*) generateRequest: (NSString*)page forParameters: (NSArray*)parameters forData: (NSArray*)data{
        //Base URL
        NSString *baseURL = [NSString stringWithFormat:@"http://deepdattaroy.com/other/projects/GPS%%20Logger/"];
        //Will be request url
        NSString *URL = [baseURL stringByAppendingString:[NSString stringWithFormat:@"%@", page]];
        
        //Create post part of request
        NSString *post = [NSString stringWithFormat:@"%@=%@", parameters[0], data[0]];
        //Parse through data and generate final url
        for (int i = 1; i < [parameters count]; i++) {
            post = [post stringByAppendingString:[NSString stringWithFormat:@"&%@=%@", parameters[i], data[i]]];
        }
        NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];

        //Create the request
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL]
                                                                    cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                                    timeoutInterval:1];
        
        //Set up the request
        [request setHTTPMethod:@"POST"];
        [request setValue:[NSString stringWithFormat:@"%lu", [post length]] forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:postData];

        return request;
    }

    /*
     * processRequest()
     *
     * parameters:
     * 	NSMutableURLRequest* request - the request url
     * returns:
     * 	NSData* - data returned by request
     *
     * Process the request
     */
    - (NSData*) processRequest: (NSMutableURLRequest*) request{
        
        //Create parts of reponse
        NSError *urlError = NULL;
        NSURLResponse *urlResponse = NULL;
        
        //Return response
        return [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&urlError];

    }

@end
