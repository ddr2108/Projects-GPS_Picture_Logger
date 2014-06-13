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
}

- (void)viewDidAppear:(BOOL)animated{
    

    int numDaysHistory = 10;

    ///////////////CLEAR CURRENT MAP/////////////////////
    [_mapView removeAnnotations:_mapView.annotations];
    
    ///////////////GET USER DEFAULTS////////////////////
    //get the defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString* days = [defaults objectForKey:@"days"];

    if (days!=NULL){
        numDaysHistory = [days intValue];
    }
    
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
    
    ///////////////////RETRIEVE DATA FROM LOG/////////////////////
    // Check if the file already exists
    if ([filemgr fileExistsAtPath: dataFilePath]){
        
        //Get the data as an array
        NSMutableArray *coordinateArray;
        coordinateArray = [NSKeyedUnarchiver unarchiveObjectWithFile: dataFilePath];
        
        //Create a Date formatter
        NSDateFormatter *dateFormatterLong = [[NSDateFormatter alloc] init];
        [dateFormatterLong setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatterLong setTimeStyle:NSDateFormatterMediumStyle];

        //Find number of points
        unsigned long logCount = [coordinateArray count];
        if (logCount==0){
            return;
        }
        
        //Get previous date
        NSDate *now = [NSDate date];
        NSDateFormatter *dateFormatterShort = [[NSDateFormatter alloc] init];
        [dateFormatterShort setDateFormat:@"MM-d-YYYY"];
        NSString* possibleDates [numDaysHistory];
        for (int i = 0; i < numDaysHistory; i++){
            NSDate *prevDate = [now dateByAddingTimeInterval:-60*60*24*i];
            possibleDates[i] = [dateFormatterShort stringFromDate:prevDate];
            
        }

        
        //Arrays to hold coordinates
        CLLocationCoordinate2D lastCoordinates;
        MKPointAnnotation* lastPoints;
        
        BOOL dateMatch = FALSE;
        //Go through the points
        for (int i = 0; i < (logCount)/2; i++){
           dateMatch = FALSE;
            
            //Create the title for the point
            NSString *myDateString = [dateFormatterLong stringFromDate:(NSDate *) coordinateArray[logCount - 2*i - 1]];
            NSString *myDateStringShort = [dateFormatterShort stringFromDate:(NSDate *) coordinateArray[logCount - 2*i - 1]];

            //Check if this date falls into range
            for (int i = 0; i < numDaysHistory; i++){
                if ([possibleDates[i] isEqualToString:myDateStringShort]){
                    dateMatch = TRUE;
                    break;
                }
            }
            if (dateMatch==FALSE){
                break;
            }
            
            //Create the coordinate
            lastCoordinates.latitude = ((CLLocation *)coordinateArray[logCount - 2*i - 2]).coordinate.latitude;
            lastCoordinates.longitude = ((CLLocation *)coordinateArray[logCount - 2*i - 2]).coordinate.longitude;
            
            //Create the point
            lastPoints = [[MKPointAnnotation alloc] init];
            lastPoints.coordinate = lastCoordinates;
            lastPoints.title = myDateString;
         
            //Print point on map
            [_mapView addAnnotation:lastPoints];

        }

    }
    
    /////////////GET DATA FROM SERVER////////////////////////////
    NSString *userName = [defaults objectForKey:@"userName"];
    NSString *deviceName = [defaults objectForKey:@"deviceName"];
    //Get date
    NSDate *currentDate = [NSDate date];
    unsigned units = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComponents = [calendar components:units fromDate:currentDate];
    NSString *date = [NSString stringWithFormat:@"%ld-%ld-%ld", (long)[dateComponents month], [dateComponents day], (long)[dateComponents year]];

    //Get from server the number of points it has
    NSString *requestString = [NSString stringWithFormat:@"http://deepdattaroy.com/other/projects/GPS%%20Logger/get_locations.php?userName=%@&deviceName=%@&date=%@&daysHistory=%d",
                               userName,
                               deviceName,
                               date,
                               numDaysHistory];
    
    NSURL *url = [NSURL URLWithString:requestString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:10];
    [request setHTTPMethod: @"GET"];
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    NSData *respData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
    NSString* respString = [[NSString alloc] initWithData:respData encoding:NSUTF8StringEncoding];
    NSArray* reponsePieces = [respString componentsSeparatedByString:@" "];
    
    ////////////////////MAP NEW DATA//////////////////////////////
    //Arrays to hold coordinates
    CLLocationCoordinate2D lastCoordinates;
    MKPointAnnotation* lastPoints;
    
    //Put all received data into map
    for (int i = 0; i < [reponsePieces count] - 1; i+=4){
        
        //Create the coordinate
        lastCoordinates.latitude = [reponsePieces[i + 1] doubleValue];
        lastCoordinates.longitude = [reponsePieces[i] doubleValue];
        
        //Create the point
        lastPoints = [[MKPointAnnotation alloc] init];
        lastPoints.coordinate = lastCoordinates;
        lastPoints.title = reponsePieces[i+2];
        
        //Print point on map
        [_mapView addAnnotation:lastPoints];
        
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
