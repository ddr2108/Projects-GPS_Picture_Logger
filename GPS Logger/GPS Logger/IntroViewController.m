//
//  FirstViewController.m
//  GPS Logger
//
//  Created by Deep Datta Roy on 5/16/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "IntroViewController.h"


@interface IntroViewController () <CLLocationManagerDelegate, MKMapViewDelegate>

    //Interaction with interface
    @property (weak, nonatomic) IBOutlet UILabel *latitudeTextBox;
    @property (weak, nonatomic) IBOutlet UILabel *longitudeTextBox;
    @property (weak, nonatomic) IBOutlet UILabel *addressTextBox;
    - (IBAction)logButton:(id)sender;

    @property (weak, nonatomic) IBOutlet MKMapView *mapView;


@end

@implementation IntroViewController{
    CLLocationManager *manager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //Initialize the location structures
    manager = [[CLLocationManager alloc] init];
    geocoder = [[CLGeocoder alloc] init];


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

    //[_mapView setCenter:_mapView.userLocation.coordinate animated:YES];

    
}

#pragma mark CLLocationManagerDelegate Methods

- (void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{

    ////////////////////GET LOCATION/////////////////////
    //If there is actually a location, update the view
    if (newLocation != NULL){
        self.latitudeTextBox.text = [NSString stringWithFormat:@"%.4f", newLocation.coordinate.latitude];
        self.longitudeTextBox.text = [NSString stringWithFormat:@"%.4f", newLocation.coordinate.longitude];
    }
    
    //Try to reverse the coordinates to get address
    [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error == NULL && [placemarks count] > 0){
            placemark = [placemarks lastObject];
            
            self.addressTextBox.text = [NSString stringWithFormat:@"%@\n%@ %@\n",placemark.thoroughfare, placemark.locality, placemark.postalCode];
            
        }
    }];
    
    ////////////////GET STORAGE PATH/////////////////////
    NSFileManager *filemgr;
    NSArray *dirPaths;
    NSString *dataFilePath;
    
    //Initialize file manager
    filemgr = [NSFileManager defaultManager];
    
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    // Build the path to the data file
    dataFilePath = [[NSString alloc] initWithString: [dirPaths[0] stringByAppendingPathComponent: @"gps_logger.archive"]];
    
    ///////////////////////STORE DATA/////////////////////
    NSMutableArray *coordinateArray;
    
    // Check if the file already exists, and pull form it if it does
    if ([filemgr fileExistsAtPath: dataFilePath]){
        coordinateArray = [NSKeyedUnarchiver unarchiveObjectWithFile: dataFilePath];
    }else{
        //Store data to array
        coordinateArray = [[NSMutableArray alloc] init];
    }
    
    //Add information from this logging
    [coordinateArray addObject: newLocation];
    [coordinateArray addObject:[NSDate date]];

    //Stor data to archive
    [NSKeyedArchiver archiveRootObject:coordinateArray toFile: dataFilePath];

    
}
@end
