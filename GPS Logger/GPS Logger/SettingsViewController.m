//
//  SecondViewController.m
//  GPS Logger
//
//  Created by Deep Datta Roy on 5/16/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

    @property (weak, nonatomic) IBOutlet UITextField *nameTextBox;
    @property (weak, nonatomic) IBOutlet UITextField *deviceNameTextBox;
    @property (weak, nonatomic) IBOutlet UITextField *pointsTextBox;
    @property (weak, nonatomic) IBOutlet UITextField *timeIntervalTextBox;
    @property (weak, nonatomic) IBOutlet UILabel *pointsAvailableLabel;
    @property (weak, nonatomic) IBOutlet UISwitch *autoLogSwitch;
    @property (weak, nonatomic) IBOutlet UILabel *syncedLabel;

@end

@implementation SettingsViewController

- (IBAction)clearHistory:(id)sender {
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
    coordinateArray = [[NSMutableArray alloc] init];
    
    //Stor data to archive
    [NSKeyedArchiver archiveRootObject:coordinateArray toFile: dataFilePath];
    
    self.pointsAvailableLabel.text = [NSString stringWithFormat:@"%d", 0];
    
    
    /////////////////////////CLEAR SERVER///////////////////
    //Get user defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //Get things need to send to db
    NSString *userName = [defaults objectForKey:@"userName"];
    NSString *deviceName = [defaults objectForKey:@"deviceName"];
    
    //Create the request url and submit
    NSString *requestString = [NSString stringWithFormat:@"http://deepdattaroy.com/other/projects/GPS%%20Logger/delete_gps.php?userName=%@&deviceName=%@",
                               userName,
                               deviceName];
    NSURL *url = [NSURL URLWithString:requestString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:10];
    [request setHTTPMethod: @"GET"];
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];


}

- (IBAction)finishedName:(id)sender {
    //Get the new name
    NSString* name = [self.nameTextBox text];
    
    //Get the defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //Store into defaults
    [defaults setObject:name forKey:@"userName"];
}

- (IBAction)finishedDeviceName:(id)sender {
    //Get the new name
    NSString* deviceName = [self.deviceNameTextBox text];
    
    //Get the defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //Store into defaults
    [defaults setObject:deviceName forKey:@"deviceName"];
}

- (IBAction)finishedPoints:(id)sender {
    //Get the new name
    NSString* days = [self.pointsTextBox text];
    
    //Get the defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //Store into defaults
    [defaults setObject:days forKey:@"days"];
}
- (IBAction)finishedInterval:(id)sender {
    //Get the new name
    NSString* interval = [self.timeIntervalTextBox text];
    
    //Get the defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //Store into defaults
    [defaults setObject:interval forKey:@"interval"];

}
- (IBAction)autoLog:(id)sender {
    //Get the new name
    NSNumber* autoLog;
    if ([sender isOn]){
        [autoLog initWithInt:1];
    }else{
        [autoLog initWithInt:0];
    }
    //Get the defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //Store into defaults
    [defaults setObject:autoLog forKey:@"autoLog"];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    //////////////////////RESTORE DEFAULTS/////////////////////////
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *userName = [defaults objectForKey:@"userName"];
    NSString *deviceName = [defaults objectForKey:@"deviceName"];
    NSString* days = [defaults objectForKey:@"days"];
    NSString* interval = [defaults objectForKey:@"interval"];
    NSNumber* autoLog = [defaults objectForKey:@"autoLog"];;
    NSString* syncTime = [defaults objectForKey:@"syncTime"];

    
    self.nameTextBox.text = userName;
    self.deviceNameTextBox.text = deviceName;
    self.pointsTextBox.text = days;
    self.timeIntervalTextBox.text = interval;
    self.syncedLabel.text = syncTime;
    if ([autoLog intValue] == 1){
        [self.autoLogSwitch setOn:TRUE];
    }else{
        [self.autoLogSwitch setOn:FALSE];
    }
    
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
    
    ///////////////////////GET SIZE OF DATA/////////////////////
    NSMutableArray *coordinateArray;
    coordinateArray = [NSKeyedUnarchiver unarchiveObjectWithFile: dataFilePath];
    
    //////////////////////CHECK FOR DATA AT SERVER/////////////////
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
                               -1];

    NSURL *url = [NSURL URLWithString:requestString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                        cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                        timeoutInterval:10];
    [request setHTTPMethod: @"GET"];
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    NSData *respData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
    NSString* respString = [[NSString alloc] initWithData:respData encoding:NSUTF8StringEncoding];

    int totalPoints = [respString intValue] + (int)[coordinateArray count]/2;
    self.pointsAvailableLabel.text = [NSString stringWithFormat:@"%d", totalPoints];

    
}
- (void)viewDidAppear:(BOOL)animated{


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
