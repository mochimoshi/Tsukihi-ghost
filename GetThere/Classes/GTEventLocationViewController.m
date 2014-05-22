//
//  GTEventLocationViewController.m
//  GetThere
//
//  Created by Alex Yuh-Rern Wang on 5/16/14.
//  Copyright (c) 2014 Chromatiqa. All rights reserved.
//

#import "GTEventLocationViewController.h"
#import "GTNewEventTableViewController.h"

@interface GTEventLocationViewController ()<MKMapViewDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;

@property (strong, nonatomic) NSString *selectedLocationName;
@property (strong, nonatomic) NSString *selectedLocationAddress;
@property (assign, nonatomic) CLLocationCoordinate2D selectedCoordinates;

@end

@implementation GTEventLocationViewController

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
    
    self.mapView = [[MKMapView alloc] initWithFrame:self.view.frame];
    self.mapView.showsUserLocation = YES;
    [self.mapView setDelegate:self];
    [self.view addSubview:self.mapView];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    GTNewEventTableViewController *eventController = (GTNewEventTableViewController *)self.delegate;
    eventController.selectedLocationName = self.selectedLocationName;
    eventController.selectedLocationAddress = self.selectedLocationAddress;
    eventController.selectedCoordinates = self.selectedCoordinates;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *currentLocation = [locations objectAtIndex:0];
    [self.locationManager stopUpdatingLocation];
    MKMapCamera *mapCamera = [[MKMapCamera alloc] init];
    [mapCamera setCenterCoordinate:currentLocation.coordinate];
    [mapCamera setAltitude:3000.0];
    [self.mapView setCamera:mapCamera animated:YES];
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if (!(error))
         {
             CLPlacemark *placemark = [placemarks objectAtIndex:0];
             NSLog(@"Current Location Detected");
             NSLog(@"placemark %@",placemark);
             NSString *locatedAt = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
             NSLog(@"%@", locatedAt);
             
             self.selectedLocationName = placemark.name;
             self.selectedLocationAddress = [placemark.addressDictionary objectForKey:@"thoroughfare"];
             self.selectedCoordinates = self.mapView.centerCoordinate;
         }
         else
         {
             NSLog(@"Geocode failed with error %@", error);
             NSLog(@"\nCurrent Location Not Detected\n");
         }
         /*---- For more results
          placemark.region);
          placemark.country);
          placemark.locality);
          placemark.name);
          placemark.ocean);
          placemark.postalCode);
          placemark.subLocality);
          placemark.location);
          ------*/
     }];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:self.mapView.centerCoordinate.latitude longitude:self.mapView.centerCoordinate.longitude];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if (!(error))
         {
             CLPlacemark *placemark = [placemarks objectAtIndex:0];
             NSLog(@"Current Location Detected");
             NSLog(@"placemark %@",placemark);
             NSString *locatedAt = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
             NSLog(@"%@", locatedAt);
         }
         else
         {
             NSLog(@"Geocode failed with error %@", error);
             NSLog(@"\nCurrent Location Not Detected\n");
         }
         /*---- For more results
          placemark.region);
          placemark.country);
          placemark.locality);
          placemark.name);
          placemark.ocean);
          placemark.postalCode);
          placemark.subLocality);
          placemark.location);
          ------*/
     }];
}

- (void)dealloc
{
    self.delegate = nil;
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
