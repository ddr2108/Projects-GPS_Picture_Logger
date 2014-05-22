//
//  FirstViewController.m
//  GPS Logger
//
//  Created by Deep Datta Roy on 5/16/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "IntroViewController.h"


@interface IntroViewController () <CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *Latitude;
@property (weak, nonatomic) IBOutlet UILabel *Longitude;
@property (weak, nonatomic) IBOutlet UILabel *Address;
- (IBAction)Log:(id)sender;

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
    
    manager = [[CLLocationManager alloc] init];
    geocoder = [[CLGeocoder alloc] init];
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)Log:(id)sender {
    
    manager.delegate = self;
    manager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [manager startUpdatingLocation];
    
}

#pragma mark CLLocationManagerDelegate Methods

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"Error %@", error);
    
}

- (void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    
    NSLog(@"Location %@", newLocation);
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != NULL){
        self.Latitude.text = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
        self.Longitude.text = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
    }
    
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error == nil && [placemarks count] > 0){
            placemark = [placemarks lastObject];
            
            self.Address.text = [NSString stringWithFormat:@"%@ %@\n", placemark.locality, placemark.postalCode];
            
        }else{
            NSLog(@"Error %@", error);
        }
    }];
    
}

@end
