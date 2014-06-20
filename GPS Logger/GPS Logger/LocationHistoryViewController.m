//
//  LocationHistoryViewController.m
//  GPS Logger
//  Contains the map for history
//
//  Created by Deep Datta Roy on 5/17/14.
//  Copyright (c) 2014 Deep Datta Roy. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "LocationHistoryViewController.h"
#import "serverLogger.h"
#import "localLogger.h"


@interface LocationHistoryViewController () <MKMapViewDelegate>
    //map view
    @property (weak, nonatomic) IBOutlet MKMapView *mapView;
@end

@implementation LocationHistoryViewController

    /*
    * viewDidLoad()
    *
    * parameters:
    * 	none
    * returns:
    * 	none
    *
    * Initialize view for gui
    */
    - (void)viewDidLoad{
        [super viewDidLoad];
    }

    /*
     * viewDidAppear()
     *
     * parameters:
     * 	BOOL animated
     * returns:
     * 	none
     *
     * Create the map
     */
    - (void)viewDidAppear:(BOOL)animated{
        
        //Clear current data
        [_mapView removeAnnotations:_mapView.annotations];
        _mapView.delegate = self;
        
        //Get local data
        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

            //Create object for getting local logs
            localLogger *localLog = [[localLogger alloc] init];
            //Get Location Data locally
            NSArray* localData = [localLog getLocations];
            
            //Map new data
            [self mapPoints:localData];
            
        });
        
        //Get server data
        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            //Create object for getting server logs
            serverLogger *serverLog = [[serverLogger alloc] init];
            //Get Location Data from server
            NSArray* serverData = [serverLog getLocations];
            
            //Map new data
            [self mapPoints:serverData];
            
        });

    }

    /*
     * mapPoints()
     *
     * parameters:
     * 	NSArray* data - data to map
     * returns:
     * 	none
     *
     * Actually map out the points
     */
    - (void) mapPoints:(NSArray*) data{
        
        //Arrays to hold coordinates
        CLLocationCoordinate2D lastCoordinates;
        MKPointAnnotation* lastPoints;
        
        //Put all received data into map
        for (int i = 0; i < [data count] - 1; i+=4){
            
            //Create the coordinate
            lastCoordinates.latitude = [data[i + 1] doubleValue];
            lastCoordinates.longitude = [data[i] doubleValue];
            
            //Create the point
            lastPoints = [[MKPointAnnotation alloc] init];
            lastPoints.coordinate = lastCoordinates;
            lastPoints.title = [NSString stringWithFormat:@"%@ %@", data[i+2], data[i+3]];
            
            //Print point on map
            dispatch_async( dispatch_get_main_queue(), ^{
                [_mapView addAnnotation:lastPoints];
            });
            
            
        }
        
        //Fix up map to center it
        dispatch_async( dispatch_get_main_queue(), ^{
            [_mapView showAnnotations:[_mapView annotations] animated:YES];
            
        });
        
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

@end
