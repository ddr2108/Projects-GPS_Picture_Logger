//
//  AppDelegate.m
//  GPS Logger
//
//  Created by Deep Datta Roy on 5/16/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "AppDelegate.h"
#import "ServerLogger.h"
#import "LocalLogger.h"

@interface AppDelegate () <CLLocationManagerDelegate>

@end


@implementation AppDelegate{
    //Locaation manager
    CLLocationManager *locationManager;
    
    //For background stuff
    NSTimer *repeatTimer;
    UIBackgroundTaskIdentifier locationTask;
    
    //Flag for actually taking data
    int logFlag;

}

    - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
    {
        //Set white text at top
        [application setStatusBarHidden:NO];
        [application setStatusBarStyle:UIStatusBarStyleLightContent];

        //Set up location manager at launch
        self->locationManager = [[CLLocationManager alloc] init];
        self->locationManager.delegate = self;
        
        [self autoLogSetup: 1];
        
        return YES;
    }

    - (void)applicationWillResignActive:(UIApplication *)application
    {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    - (void)applicationDidEnterBackground:(UIApplication *)application
    {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

    }

    - (void)applicationWillEnterForeground:(UIApplication *)application
    {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    - (void)applicationDidBecomeActive:(UIApplication *)application
    {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    - (void)applicationWillTerminate:(UIApplication *)application
    {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    /*
     * autoLogSetup()
     *
     * parameters:
     * 	int startupFlag - flag of where this setup comes from, 1 from app startup, 0 else
     * returns:
     * 	none
     *
     * Determine whether to turn on auto log and set it up
     */
    - (void) autoLogSetup:(int) startupFlag{
    
        //If there is a timer already, and this fx is being called at startup, don't continue
        if (startupFlag==1 && [repeatTimer isValid]){
            return;
        }
        
        //Remove old timers
        [repeatTimer invalidate];
        repeatTimer = NULL;

        //Check if supposed to do autologging
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        long autoLog = [[defaults objectForKey:@"autoLog"] integerValue];
        long interval = [[defaults objectForKey:@"interval"] integerValue];
        
        //If user wants to auto log
        if (autoLog==1){
            [self->locationManager startUpdatingLocation];
            
            //Create task to do in background
            self->locationTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
                [[UIApplication sharedApplication] endBackgroundTask:self->locationTask];
                self->locationTask = UIBackgroundTaskInvalid;
            }];
            
            //Create a timer to wake up to do again
            self->repeatTimer = [NSTimer scheduledTimerWithTimeInterval:interval*60
                                                                 target:self
                                                               selector:@selector(changeAccuracy)
                                                               userInfo:nil
                                                                repeats:YES];
        }else{
            //If logging is diabled, turn off timer
            [repeatTimer invalidate];
            repeatTimer = NULL;
            
            //Stop location manager
            [self->locationManager stopUpdatingLocation];
        }
        
        //Say time to log
        logFlag = 1;
    
    }

    /*
     * changeAccuracy()
     *
     * parameters:
     * 	none
     * returns:
     * 	none
     *
     * Change accuracey of lcoation manager and set up flag to log
     */
    - (void) changeAccuracy {
        //Say time to log
        logFlag = 1;
        
        //Do the logging
        [self->locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        [self->locationManager setDistanceFilter:kCLDistanceFilterNone];
    }

    /*
     * locationManager(), didUpdateLocations
     *
     * parameters:
     * 	CLLocationManager* lm - location manager
     *  NSArray* locations - locations
     * returns:
     * 	none
     *
     * Gets the updated location and saves it
     */
    -(void)locationManager:(CLLocationManager *)curLocationManager didUpdateLocations:(NSArray *) newLocations{
    
        ///////////////////CHECK IF LOGGING PERMITTED///////////
        //CHeck if it should record new data point
        if (logFlag == 0){
            return;
        }
        logFlag = 0;
    
        /////////////////////////SAVE LOCATION///////////////////
        //Get the location
        CLLocation *newLocation = [newLocations lastObject];
        double coordinates[] = {newLocation.coordinate.longitude, newLocation.coordinate.latitude};
        
        //Create object for logging to server
        ServerLogger *serverLog = [[ServerLogger alloc] init];
        //Save Data
        BOOL dataInserted = [serverLog saveGPS:coordinates];
        
        //if data was inserted, try to insert other items
        if (dataInserted==TRUE){
            //Create local logger
            LocalLogger* localLog = [[LocalLogger alloc] init];
            //Save Data
            [localLog sendToServer:TRUE];
            [localLog saveOldLog];
            
        }
        
        //If not inserted save data locally
        if (dataInserted==FALSE){
            //Create local logger
            LocalLogger* localLog = [[LocalLogger alloc] init];
            //Save Data
            [localLog saveGPS:coordinates];
        }
    
        //Set accuracy
        [curLocationManager setDesiredAccuracy:kCLLocationAccuracyThreeKilometers];
        [curLocationManager setDistanceFilter:99999];
    }

@end
