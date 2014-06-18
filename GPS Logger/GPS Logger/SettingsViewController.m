//
//  SecondViewController.m
//  GPS Logger
//
//  Created by Deep Datta Roy on 5/16/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "SettingsViewController.h"
#import "serverLogger.h"
#import "localLogger.h"

@interface SettingsViewController ()

    @property (weak, nonatomic) IBOutlet UITextField *nameTextBox;
    @property (weak, nonatomic) IBOutlet UITextField *deviceNameTextBox;
    @property (weak, nonatomic) IBOutlet UITextField *pointsTextBox;
    @property (weak, nonatomic) IBOutlet UITextField *timeIntervalTextBox;
    @property (weak, nonatomic) IBOutlet UILabel *pointsAvailableLabel;
    @property (weak, nonatomic) IBOutlet UISwitch *autoLogSwitch;
    @property (weak, nonatomic) IBOutlet UILabel *syncedLabel;

@end

@implementation SettingsViewController{
    NSUserDefaults *defaults;
}

- (void)viewDidLoad{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated{
    
    //////////////////////RESTORE DEFAULTS/////////////////////////
    defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *userName = [defaults objectForKey:@"userName"];
    NSString *deviceName = [defaults objectForKey:@"deviceName"];
    NSString* days = [defaults objectForKey:@"daysHistory"];
    NSString* interval = [defaults objectForKey:@"interval"];
    NSNumber* autoLog = [defaults objectForKey:@"autoLog"];;
    NSString* syncTime = [defaults objectForKey:@"syncTime"];
    NSLog(@"%d", [autoLog intValue]);
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
    
    ///////////////////////CHECK FOR DATA /////////////////////
    //Data local
    localLogger* localLog = [[localLogger alloc] init];
    //Data on server
    serverLogger* serverLog = [[serverLogger alloc] init];
    
    //Count total data
    int totalPoints = [localLog getNumLocations] + [serverLog getNumLocations];
    self.pointsAvailableLabel.text = [NSString stringWithFormat:@"%d", totalPoints];
    
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)clearHistory:(id)sender {
    
    ///////////////////////CLEAR LOCAL/////////////////////
    //Create object for server logging
    localLogger *localLog = [[localLogger alloc] init];
    //Delete Data
    [localLog deleteGPS];
    
    /////////////////////////CLEAR SERVER///////////////////
    //Create object for server logging
    serverLogger *serverLog = [[serverLogger alloc] init];
    //Delete Data
    [serverLog deleteGPS];

    ///////////////////FIX GUI/////////////////////////////
    self.pointsAvailableLabel.text = [NSString stringWithFormat:@"%d", 0];

}

- (IBAction)finishedName:(id)sender {
    //Get the new name
    NSString* name = [self.nameTextBox text];
    
    //Store into defaults
    [defaults setObject:name forKey:@"userName"];
}

- (IBAction)finishedDeviceName:(id)sender {
    //Get the new name
    NSString* deviceName = [self.deviceNameTextBox text];
    
    //Store into defaults
    [defaults setObject:deviceName forKey:@"deviceName"];
}

- (IBAction)finishedPoints:(id)sender {
    //Get the new name
    NSString* days = [self.pointsTextBox text];
    
    //Store into defaults
    [defaults setObject:days forKey:@"daysHistory"];
}
- (IBAction)finishedInterval:(id)sender {
    //Get the new name
    NSString* interval = [self.timeIntervalTextBox text];
    
    //Store into defaults
    [defaults setObject:interval forKey:@"interval"];

}
- (IBAction)autoLog:(id)sender {
    //Get the new log mode
    NSNumber* autoLog;
    if ([sender isOn]){
        autoLog = [NSNumber numberWithInt:1];
    }else{
        autoLog = [NSNumber numberWithInt:0];
    }

    //Store into defaults
    [defaults setObject:autoLog forKey:@"autoLog"];

}

@end
