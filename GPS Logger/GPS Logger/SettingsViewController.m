//
//  SettingsViewController
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
}

- (IBAction)finishedName:(id)sender {
    //Get the new name
    NSString* name = [self.nameTextBox text];
    
    //Get the defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //Store into defaults
    [defaults setObject:name forKey:@"name"];
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
    NSString* points = [self.pointsTextBox text];
    
    //Get the defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //Store into defaults
    [defaults setObject:points forKey:@"points"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *name = [defaults objectForKey:@"name"];
    NSString *deviceName = [defaults objectForKey:@"deviceName"];
    NSString* points = [defaults objectForKey:@"points"];

    self.nameTextBox.text = name;
    self.deviceNameTextBox.text = deviceName;
    self.pointsTextBox.text = points;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
