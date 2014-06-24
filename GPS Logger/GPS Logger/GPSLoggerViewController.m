//
//  GPSLoggerViewController.m
//  GPS Logger
//  Does the inital logging
//
//  Created by Deep Datta Roy on 5/16/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "GPSLoggerViewController.h"
#import "ServerLogger.h"
#import "LocalLogger.h"


@interface GPSLoggerViewController () <CLLocationManagerDelegate, MKMapViewDelegate>

    //Interaction with interface
    @property (weak, nonatomic) IBOutlet UILabel* latitudeLabel;
    @property (weak, nonatomic) IBOutlet UILabel* longitudeLabel;
    @property (weak, nonatomic) IBOutlet UILabel* timeLabel;
    @property (weak, nonatomic) IBOutlet UILabel* addressLabel;
    - (IBAction)logButton:(id)sender;

    //Maps
    @property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation GPSLoggerViewController{
    
    //Managers
    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;

    //Flag for logging again
    int logFlag;
}

    /*
     * viewDidLoad()
     *
     * parameters:
     * 	none
     * returns:
     * 	none
     *
     * Initialize map managers and defaults when first screen loads
     */
    - (void)viewDidLoad {
        [super viewDidLoad];
        
        //Initialize defualts
        [self initializeDefaults];
        
        //Initialize the location structures
        locationManager = [[CLLocationManager alloc] init];
        geocoder = [[CLGeocoder alloc] init];
        
        //Do not get coordinates yet
        logFlag = 0;

    }

    /*
     * didReceiveMemoryWarning()
     *
     * parameters:
     * 	none
     * returns:
     * 	none
     *
     * Memory cleaning
     */
    - (void)didReceiveMemoryWarning{
        [super didReceiveMemoryWarning];
    }

    /*
     * initializeDefaults()
     *
     * parameters:
     * 	none
     * returns:
     * 	none
     *
     * Initialize defaults in case it has not yet
     */
    - (void) initializeDefaults{
        
        //Load up defaults
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        
        //Load a default and if null, means there are no defaults
        NSString *userName = [defaults objectForKey:@"userName"];
        if (userName==NULL){
            //Create User defaults
            [defaults setObject:[NSString stringWithFormat:@"%@", [[NSUUID UUID] UUIDString]] forKey:@"userName"];
            [defaults setObject:[NSString stringWithFormat:@"%@", [[UIDevice currentDevice] name]] forKey:@"deviceName"];
            [defaults setObject:[NSString stringWithFormat:@"10"] forKey:@"daysHistory"];
            [defaults setObject:[NSString stringWithFormat:@"10"] forKey:@"interval"];
            [defaults setObject:[NSString stringWithFormat:@"Never"] forKey:@"syncTime"];
            [defaults setObject:[NSNumber numberWithInt:0] forKey:@"autoLog"];
        }

    }
    /*
     * logButton()
     *
     * parameters:
     * 	id sender - id of button
     * returns:
     * 	none
     *
     * Log when button pressed
     */
    - (IBAction)logButton:(id)sender {
        
        //Clear the labels
        self.latitudeLabel.text = [NSString stringWithFormat:@""];
        self.longitudeLabel.text = [NSString stringWithFormat:@""];
        self.timeLabel.text = [NSString stringWithFormat:@""];
        self.addressLabel.text = [NSString stringWithFormat:@""];

        //Start updating the location
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [locationManager startUpdatingLocation];
        
        //Center the map
        _mapView.userTrackingMode=YES;

        //Mark to log
        logFlag = 1;
        
    }

    #pragma mark CLLocationManagerDelegate Methods

    /*
     * locationManager(), didUpdateToLocation, fromLocation
     *
     * parameters:
     * 	CLLocation* newLocation - new location
     *  CLLocation* oldLocation - previous location
     * returns:
     * 	none
     *
     * Get the actual location that has been just updated
     */
    - (void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{

        ///////////////////CHECK IF LOGGING PERMITTED///////////
        //CHeck if it should record new data point
        if (logFlag == 0){
            return;
        }
        logFlag = 0;
        
        ////////////////////GET LOCATION/////////////////////
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"h:mma"];

        
        //If there is actually a location, update the view
        if (newLocation != NULL){
            self.latitudeLabel.text = [NSString stringWithFormat:@"%.4f", newLocation.coordinate.latitude];
            self.longitudeLabel.text = [NSString stringWithFormat:@"%.4f", newLocation.coordinate.longitude];
            self.timeLabel.text = [dateFormatter stringFromDate:[NSDate date]];
        }
        
        //Try to reverse the coordinates to get address
        [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error) {
            if (error == NULL && [placemarks count] > 0){
                placemark = [placemarks lastObject];
                self.addressLabel.text = [NSString stringWithFormat:@"%@\n%@ %@\n",placemark.thoroughfare, placemark.locality, placemark.postalCode];
                
            }
        }];
        
        /////////////////////////SAVE LOCATION///////////////////
        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{   //Asyncronous

            //Get coordinates
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
            
        });

    }
@end
