//
//  IntroViewController
//  GPS Logger
//
//  Created by Deep Datta Roy on 5/16/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "IntroViewController.h"
#import "serverLogger.h"
#import "localLogger.h"


@interface IntroViewController () <CLLocationManagerDelegate, MKMapViewDelegate>

    //Interaction with interface
    @property (weak, nonatomic) IBOutlet UILabel *latitudeLabel;
    @property (weak, nonatomic) IBOutlet UILabel *longitudeLabel;
    @property (weak, nonatomic) IBOutlet UILabel *timeLabel;
    @property (weak, nonatomic) IBOutlet UILabel *addressLabel;
    - (IBAction)logButton:(id)sender;

    @property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation IntroViewController{
    CLLocationManager *manager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;

    int logFlag;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //Initialize the location structures
    manager = [[CLLocationManager alloc] init];
    geocoder = [[CLGeocoder alloc] init];
    
    logFlag = 0;


}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logButton:(id)sender {
    
    //Start updating the location
    manager.delegate = self;
    manager.desiredAccuracy = kCLLocationAccuracyBest;
    [manager startUpdatingLocation];
    
    //Center the map
    _mapView.userTrackingMode=YES;

    //Mark to log
    logFlag = 1;
    
}

#pragma mark CLLocationManagerDelegate Methods

- (void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{

    ///////////////////CHECK IF LOGGING PERMITTED///////////
    //CHeck if it should record new data point
    if (logFlag == 0){
        return;
    }
    logFlag = 0;
    
    ////////////////////GET LOCATION/////////////////////
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"h:mm a"];

    
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
    
    /////////////////////////SEND TO SERVER///////////////////
    //Create object for logging
    serverLogger *serverLog = [[serverLogger alloc] init];

    //Get coordinates
    double coordinates[] = {newLocation.coordinate.longitude, newLocation.coordinate.latitude};
    
    //Save Data
    BOOL dataInserted = [serverLog saveGPS:coordinates];
    
    //if data was inserted, try to insert other items
    if (dataInserted==TRUE){
        
        //Create local logger
        localLogger* localLog = [[localLogger alloc] init];
        
        //Save Data
        [localLog sendToServer];
        
    }
    
    
    //If not inserted save data locally
    if (dataInserted==FALSE){
    
        //Create local logger
        localLogger* localLog = [[localLogger alloc] init];
        
        //Save Data
        [localLog saveGPS:coordinates];
    
    }

}
@end
