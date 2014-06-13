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
    //Get user defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //Get parts of date
    NSDate *currentDate = [NSDate date];
    unsigned units = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComponents = [calendar components:units fromDate:currentDate];

    //Get things need to send to db
    NSString *userName = [defaults objectForKey:@"userName"];
    NSString *deviceName = [defaults objectForKey:@"deviceName"];
    NSString *date = [NSString stringWithFormat:@"%ld-%ld-%ld", (long)[dateComponents month], [dateComponents day], (long)[dateComponents year]];
    NSInteger time = [dateComponents hour]*60+[dateComponents minute];
    double longitude = newLocation.coordinate.longitude;
    double latitude = newLocation.coordinate.latitude;

    //Create the request url and submit
    NSString *requestString = [NSString stringWithFormat:@"http://deepdattaroy.com/other/projects/GPS%%20Logger/save_gps.php?userName=%@&deviceName=%@&date=%@&time=%ld&longitude=%f&latitude=%f",
                            userName,
                            deviceName,
                            date,
                            (long)time,
                            longitude,
                            latitude];
    
    NSURL *url = [NSURL URLWithString:requestString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                        cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                        timeoutInterval:10];

    [request setHTTPMethod: @"GET"];
    
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    NSData *respData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
    
    BOOL dataInserted = [[[NSString alloc] initWithData:respData encoding:NSUTF8StringEncoding] isEqualToString:@"Inserted"];

    //if data was inserted, try to insert other items
    if (dataInserted==TRUE){
        
        //if all successful, update sync time
        NSString *date = [NSString stringWithFormat:@"%ld:%ld %ld-%ld-%ld", [dateComponents hour], [dateComponents minute], (long)[dateComponents month], [dateComponents day], (long)[dateComponents year]];
        [defaults setObject:date forKey:@"syncTime"];
    }
    
    //If not inserted save data locally
    if (dataInserted==FALSE){
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
        [coordinateArray addObject: currentDate];
        
        //Stor data to archive
        [NSKeyedArchiver archiveRootObject:coordinateArray toFile: dataFilePath];
    }

}
@end
