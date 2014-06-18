//
//  HistoryViewController.m
//  GPS Logger
//
//  Created by Deep Datta Roy on 5/17/14.
//  Copyright (c) 2014 Deep Datta Roy. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "HistoryViewController.h"
#import "serverLogger.h"
#import "localLogger.h"


@interface HistoryViewController () <MKMapViewDelegate>
    @property (weak, nonatomic) IBOutlet MKMapView *mapView;
@end

@implementation HistoryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated{
    
    ///////////////CLEAR CURRENT MAP/////////////////////
    [_mapView removeAnnotations:_mapView.annotations];
    _mapView.delegate = self;
    
    ///////////////////GET DATA FROM LOCAL/////////////////////
    //Create object for logging
    localLogger *localLog = [[localLogger alloc] init];
    
    //Get Location Data
    NSArray* localData = [localLog getLocations];
    
    /////////////GET DATA FROM SERVER////////////////////////////
    //Create object for logging
    serverLogger *serverLog = [[serverLogger alloc] init];
    
    //Get Location Data
    NSArray* serverData = [serverLog getLocations];

    ////////////////////MAP NEW DATA//////////////////////////////
    //Combine data from array
    NSArray* combinedData = [localData arrayByAddingObjectsFromArray:serverData];
    
    //Arrays to hold coordinates
    CLLocationCoordinate2D lastCoordinates;
    MKPointAnnotation* lastPoints;
    
    //Put all received data into map
    for (int i = 0; i < [combinedData count] - 1; i+=4){
        
        //Create the coordinate
        lastCoordinates.latitude = [combinedData[i + 1] doubleValue];
        lastCoordinates.longitude = [combinedData[i] doubleValue];
        
        //Create the point
        lastPoints = [[MKPointAnnotation alloc] init];
        lastPoints.coordinate = lastCoordinates;
        lastPoints.title = [NSString stringWithFormat:@"%@ %@", combinedData[i+2], combinedData[i+3]];
        
        //Print point on map
        [_mapView addAnnotation:lastPoints];
        
    }

    //Fix up map to center it
    [_mapView showAnnotations:[_mapView annotations] animated:YES];

}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
