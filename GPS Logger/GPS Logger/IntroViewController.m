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


@interface IntroViewController ()

@end

@implementation IntroViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    CLLocationManager *locationMgr =
    [[CLLocationManager alloc] init];

    locationMgr.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    locationMgr.delegate = self;
    
    locationMgr.distanceFilter = 100.0f;
    
    [locationMgr startUpdatingLocation];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
