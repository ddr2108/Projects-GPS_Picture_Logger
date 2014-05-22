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

    //Location of storage
    @property (strong, nonatomic) NSString *dataFilePath;


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
    
}

#pragma mark CLLocationManagerDelegate Methods

- (void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{

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
    
    NSFileManager *filemgr;
    NSString *docsDir;
    NSArray *dirPaths;
    filemgr = [NSFileManager defaultManager];
    
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(
                                                   NSDocumentDirectory, NSUserDomainMask, YES);
    
    docsDir = dirPaths[0];
    
    // Build the path to the data file
    _dataFilePath = [[NSString alloc] initWithString: [docsDir
                                                       stringByAppendingPathComponent: @"data.archive"]];

    
}
@end
