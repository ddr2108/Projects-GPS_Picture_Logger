//
//  SettingsViewController
//  GPS Logger
//  Set up the settings
//
//  Created by Deep Datta Roy on 5/16/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "SettingsViewController.h"
#import "AppDelegate.h"
#import "serverLogger.h"
#import "localLogger.h"

@interface SettingsViewController ()

    //Interact with user
    @property (weak, nonatomic) IBOutlet UITextField* userNameTextBox;
    @property (weak, nonatomic) IBOutlet UITextField* deviceNameTextBox;
    @property (weak, nonatomic) IBOutlet UITextField* intervalTextBox;
    @property (weak, nonatomic) IBOutlet UITextField* daysHistoryTextBox;
    @property (weak, nonatomic) IBOutlet UISwitch* autoLogSwitch;
    @property (weak, nonatomic) IBOutlet UILabel* pointsAvailableLabel;
    @property (weak, nonatomic) IBOutlet UILabel* syncTimeLabel;

@end

@implementation SettingsViewController{
    //holds the defaults
    NSUserDefaults *defaults;
}

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
     * Restore the labels and text boxes for setting
     */
    - (void)viewDidAppear:(BOOL)animated{
        
        //////////////////////RESTORE DEFAULTS/////////////////////////
        defaults = [NSUserDefaults standardUserDefaults];
        
        NSString* userName = [defaults objectForKey:@"userName"];
        NSString* deviceName = [defaults objectForKey:@"deviceName"];
        NSString* interval = [defaults objectForKey:@"interval"];
        NSString* days = [defaults objectForKey:@"daysHistory"];
        NSNumber* autoLog = [defaults objectForKey:@"autoLog"];;
        NSString* syncTime = [defaults objectForKey:@"syncTime"];

        self.userNameTextBox.text = userName;
        self.deviceNameTextBox.text = deviceName;
        self.intervalTextBox.text = interval;
        self.daysHistoryTextBox.text = days;
        if ([autoLog intValue] == 1){
            [self.autoLogSwitch setOn:TRUE];
        }else{
            [self.autoLogSwitch setOn:FALSE];
        }
        self.syncTimeLabel.text = syncTime;

        
        ///////////////////////CHECK FOR DATA /////////////////////
        //Data local
        localLogger* localLog = [[localLogger alloc] init];
        //Data on server
        serverLogger* serverLog = [[serverLogger alloc] init];
        
        //Count total data
        int totalPoints = [localLog getNumLocations] + [serverLog getNumLocations];
        self.pointsAvailableLabel.text = [NSString stringWithFormat:@"%d", totalPoints];
        
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

    /*
     * sync()
     *
     * parameters:
     * 	id sender - the button that did it
     * returns:
     * 	none
     *
     * Sync the data points
     */
    - (IBAction)sync:(id)sender {
        
        //Create object for local logging
        localLogger* localLog = [[localLogger alloc] init];
        //Sync data
        [localLog sendToServer];
        
        //Adjust the sync time if needed
        NSString* syncTime = [defaults objectForKey:@"syncTime"];
        self.syncTimeLabel.text = syncTime;

    }


    /*
     * clearHistory()
     *
     * parameters:
     * 	id sender - the button that did it
     * returns:
     * 	none
     *
     * Clear all the data points
     */
    - (IBAction)clearHistory:(id)sender {
        
        //Create object for local logging
        localLogger* localLog = [[localLogger alloc] init];
        //Delete Data locally
        [localLog deleteGPS];
        
        //Create object for server logging
        serverLogger* serverLog = [[serverLogger alloc] init];
        //Delete Data at server
        [serverLog deleteGPS];

        //Update saying no more points available
        self.pointsAvailableLabel.text = [NSString stringWithFormat:@"%d", 0];

    }

    /*
     * finishedUserName()
     *
     * parameters:
     * 	id sender - the text box that did it
     * returns:
     * 	none
     *
     * Save user Name
     */
    - (IBAction)finishedUserName:(id)sender {
        
        //Get the new name
        NSString* userName = [self.userNameTextBox text];
        
        //Store into defaults
        [defaults setObject:userName forKey:@"userName"];
    }

    /*
     * finishedDeviceName()
     *
     * parameters:
     * 	id sender - the text box that did it
     * returns:
     * 	none
     *
     * Save device name
     */
    - (IBAction)finishedDeviceName:(id)sender {
        
        //Get the new name
        NSString* deviceName = [self.deviceNameTextBox text];
        
        //Store into defaults
        [defaults setObject:deviceName forKey:@"deviceName"];
        
    }

    /*
     * finishedInterval()
     *
     * parameters:
     * 	id sender - the text box that did it
     * returns:
     * 	none
     *
     * Save logging interval
     */
    - (IBAction)finishedInterval:(id)sender {
        
        //Get the new name
        NSString* interval = [self.intervalTextBox text];
        
        //Store into defaults if a number
        if ([interval rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]].location != NSNotFound){
            [self showWarningMessage:@"Must be a positive number less than 10"];
            self.intervalTextBox.text = [defaults objectForKey:@"interval"];
        }else if ([interval integerValue] > 9){
            [self showWarningMessage:@"Must be a positive number less than 10"];
            self.intervalTextBox.text = [defaults objectForKey:@"interval"];
        }else{
            [defaults setObject:interval forKey:@"interval"];
        }

    }

    /*
     * finishedDaysHistory()
     *
     * parameters:
     * 	id sender - the text box that did it
     * returns:
     * 	none
     *
     * Save number of days history to save
     */
    - (IBAction)finishedDaysHistory:(id)sender {
        
        //Get the new name
        NSString* daysHistory = [self.daysHistoryTextBox text];
        
        //Store into defaults if a number
        if ([daysHistory rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]].location != NSNotFound){
            [self showWarningMessage:@"Must be a positive number"];
            self.daysHistoryTextBox.text = [defaults objectForKey:@"daysHistory"];
        }else{
            [defaults setObject:daysHistory forKey:@"daysHistory"];
        }

    }

    /*
     * autoLog()
     *
     * parameters:
     * 	id sender - the switch that did it
     * returns:
     * 	none
     *
     * Save auto log button
     */
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
        
        //Contact app delegate to fix up logging
        AppDelegate *appDelegate= [[UIApplication sharedApplication] delegate];
        [appDelegate autoLogSetup];


    }

    /*
     * showWarningMessage()
     *
     * parameters:
     * 	NSString* message - message to display
     * returns:
     * 	none
     *
     * Show warning message
     */
    - (void) showWarningMessage: (NSString*)message{
    
        //Create message dialog and show it
        UIAlertView *warningMessage = [[UIAlertView alloc] initWithTitle:@"Error"
														message:message
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles: nil];
		[warningMessage show];
        
    }

@end
