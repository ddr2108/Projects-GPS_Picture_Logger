//
//  HistoryViewController.m
//  GPS Logger
//
//  Created by Deep Datta Roy on 5/17/14.
//  Copyright (c) 2014 Deep Datta Roy. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "HistoryViewController.h"

@interface HistoryViewController () <MKMapViewDelegate>
    @property (weak, nonatomic) IBOutlet MKMapView *mapView;
@end

@implementation HistoryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    ////////////////GET STORAGE PATH/////////////////////
    NSFileManager *filemgr;
    NSArray *dirPaths;
    NSString *dataFilePath;
    
    _mapView.delegate = self;

    //Initialize file manager
    filemgr = [NSFileManager defaultManager];
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(
        NSDocumentDirectory, NSUserDomainMask, YES);
    // Build the path to the data file
    dataFilePath = [[NSString alloc] initWithString: [dirPaths[0] stringByAppendingPathComponent: @"gps_logger.archive"]];
    
    ///////////////////RETRIEVE DATA/////////////////////
    // Check if the file already exists
    if ([filemgr fileExistsAtPath: dataFilePath]){
        
        //Get the data as an array
        NSMutableArray *coordinateArray;
        coordinateArray = [NSKeyedUnarchiver unarchiveObjectWithFile: dataFilePath];
        
        //Create a Date formatter
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];

        //Find number of points
        unsigned long logCount = [coordinateArray count];
        int numPointsDisplay = 10;
        if (logCount<20){
            numPointsDisplay = (int)logCount/2;
        }
        
        //Arrays to hold coordinates
        CLLocationCoordinate2D lastCoordinates[numPointsDisplay];
        MKPointAnnotation* lastPoints[numPointsDisplay];
        
        //Go through the points
        for (int i = 0; i < numPointsDisplay; i++){
            //Create the coordinate
            lastCoordinates[i].latitude = ((CLLocation *)coordinateArray[logCount - 2*i - 2]).coordinate.latitude;
            lastCoordinates[i].longitude = ((CLLocation *)coordinateArray[logCount - 2*i - 2]).coordinate.longitude;
            
            //Create the title for the point
            NSString *myDateString = [dateFormatter stringFromDate:(NSDate *) coordinateArray[logCount - 2*i - 1]];
            
            //Create the point
            lastPoints[i] = [[MKPointAnnotation alloc] init];
            lastPoints[i].coordinate = lastCoordinates[i];
            lastPoints[i].title = myDateString;
         
            //Print point on map
            [_mapView addAnnotation:lastPoints[i]];

        }

    }
    
    //Fix up map to center it
    [_mapView showAnnotations:[_mapView annotations] animated:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
