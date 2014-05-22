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
    
    _mapView.delegate = self;

    //Simulated annotations on the map
    CLLocationCoordinate2D poi1Coord , poi2Coord , poi3Coord , poi4Coord;
    //poi1 coordinates
    poi1Coord.latitude = 37.78754;
    poi1Coord.longitude = -122.40718;
    //poi2 coordinates
    poi2Coord.latitude = 37.78615;
    poi2Coord.longitude = -122.41040;
    //poi3 coordinates
    poi3Coord.latitude = 37.78472;
    poi3Coord.longitude = -122.40516;
    //poi4 coordinates
    poi4Coord.latitude = 37.78866;
    poi4Coord.longitude = -122.40623;
    
    MKPointAnnotation *poi1 = [[MKPointAnnotation alloc] init];
    MKPointAnnotation *poi2 = [[MKPointAnnotation alloc] init];
    MKPointAnnotation *poi3 = [[MKPointAnnotation alloc] init];
    MKPointAnnotation *poi4 = [[MKPointAnnotation alloc] init];
    
    
    poi1.coordinate = poi1Coord;
    poi2.coordinate = poi2Coord;
    poi3.coordinate = poi3Coord;
    poi4.coordinate = poi4Coord;
    
    poi1.title = @"McDonald's";
    poi1.subtitle = @"Best burgers in town";
    poi2.title = @"Apple store";
    poi2.subtitle = @"Iphone on sales..";
    poi3.title = @"Microsoft";
    poi3.subtitle = @"Microsoft's headquarters";
    poi4.title = @"Post office";
    poi4.subtitle = @"You got mail!";
    
    [_mapView addAnnotation:poi1];
    [_mapView addAnnotation:poi2];
    [_mapView addAnnotation:poi3];
    [_mapView addAnnotation:poi4];

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
