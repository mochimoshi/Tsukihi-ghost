//
//  GTChatViewController.m
//  GetThere
//
//  Created by Angela Yeung on 4/29/14.
//  Copyright (c) 2014 Chromatiqa. All rights reserved.
//

#import "GTChatViewController.h"
#import "GTPersonViewController.h"
#import "BTWTweetComposeView.h"
#import "GTMapAnnotation.h"
#import "GTNewEventTableViewController.h"

#import "UILabel+GTLabel.h"
#import "UIFont+BTWFont.h"
#import "UIImage+BTWImage.h"
#import "UIImage+ImageEffects.h"
#import "GTConstants.h"
#import "GTUtilities.h"

#import <AFNetworking/AFNetworking.h>
#import <CoreLocation/CoreLocation.h>

@interface GTChatViewController ()<MKMapViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate,CLLocationManagerDelegate, UIActionSheetDelegate, BTWTweetComposeViewDelegate, GTNewEventDelegate>

/* user info */

@property (strong, nonatomic) MKMapView *mapView;
@property (strong, nonatomic) UIImageView *previewImage;

@property (strong, nonatomic) UIActionSheet *settingsSheet;

@property (strong, nonatomic) BTWTweetComposeView *composeView;
@property (assign, nonatomic) BOOL hasPopupOpen;

@property (strong, nonatomic) NSDictionary *chat;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSMutableArray *mapPinData;

@property (strong, nonatomic) UILabel *currentLocationLabel;
@property (strong, nonatomic) UILabel *attendeesLabel;
@property (strong, nonatomic) UIView *attendeesView;
@property (strong, nonatomic) UIButton *attendeesButton;

@property (strong, nonatomic) CLLocation *destinationLocation;

/* location manager */
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (assign, nonatomic) CLLocationCoordinate2D currentCoordinate;
@property (strong, nonatomic) NSMutableArray *mapPins;

/* status array */
@property (strong, nonatomic) NSMutableArray *statuses;

@property (strong, nonatomic) UIImage *picture;
@property (strong, nonatomic) NSMutableArray *photoPins;

/* http manager */
@property (strong, nonatomic) AFHTTPRequestOperationManager *httpManager;


@end

@implementation GTChatViewController

#define kFirechatNS @"https://getthere.firebaseio.com/"

#define kAttendeeLocations @"http://tsukihi.org/backtier/events/get_event_attendee_locations"
#define kUpdateLocation @"http://tsukihi.org/backtier/users/update_location"
#define kEventMessages @"http://tsukihi.org/backtier/events/get_event_messages"
#define kEventInfo @"http://tsukihi.org/backtier/events/get_event"

static const CGFloat kNavBarHeight = 64;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)awakeFromNib
{

    if (!self.httpManager) {
        self.httpManager = [AFHTTPRequestOperationManager manager];
    }
    
    self.chat = [[NSDictionary alloc] init];
    self.statuses = [[NSMutableArray alloc] init];
    self.hasPopupOpen = NO;
    
    // setting up text field response
    
    //NSDictionary *params = @{@"event": @{@"id": [NSNumber numberWithInteger:self.eventID]}};
    NSDictionary *params = @{@"event": @{@"id": [NSNumber numberWithInteger:[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventID"]integerValue]]}};
    NSLog(@"id num: %@", params);
    [self.httpManager GET:kEventMessages parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.chat = responseObject;

        dispatch_async(dispatch_get_main_queue(), ^{
            // Update map pins
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
    
    self.name = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
    
    self.settingsSheet = [[UIActionSheet alloc] init];
    [self.settingsSheet setDelegate:self];
    [self.settingsSheet setTitle:NSLocalizedString(@"Actions", nil)];
    [self.settingsSheet addButtonWithTitle:NSLocalizedString(@"Post message", nil)];
    [self.settingsSheet addButtonWithTitle:NSLocalizedString(@"Set details / invite friends", nil)];
    [self.settingsSheet addButtonWithTitle:NSLocalizedString(@"View pending meetups", nil)];
    [self.settingsSheet addButtonWithTitle:NSLocalizedString(@"Cancel current meetup", nil)];
    [self.settingsSheet addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
    [self.settingsSheet setCancelButtonIndex:4];
    [self.settingsSheet setDestructiveButtonIndex:3];
    
    [self startStandardUpdates];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self createViews];
    [self setupViews];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableViewData) name:@"ReloadAppDelegateTable" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(populateLocations:) name:@"PopulateUserLocations" object:nil];


    //[self setDummyMapPins];
}


- (void)populateLocations:(NSNotification *)notification{
    NSLog(@"GOT HERE!!!!");
    [self setDummyMapPins];
}

- (void)reloadTableViewData{
    NSLog(@"GOT TO CHAT VIEW!");
    
    NSDictionary *params = @{@"event": @{@"id": [NSNumber numberWithInteger:[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventID"]integerValue]]}};
    [self.httpManager GET:kEventMessages parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        self.chat = responseObject;
        dispatch_async(dispatch_get_main_queue(), ^{
        });
        NSLog(@"Set chat: %@", self.chat);
        [self setPinStatuses ];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(!CLLocationCoordinate2DIsValid(self.currentCoordinate)) {
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = 37.4240943;
        coordinate.longitude = -122.1701957;
        self.currentCoordinate = coordinate;
    }
    MKMapCamera *camera = [[MKMapCamera alloc] init];
    [camera setCenterCoordinate:self.currentCoordinate];
    [camera setAltitude:3000.0];
    
    [self.mapView setCamera:camera animated:YES];
    
    self.eventID = [[[NSUserDefaults standardUserDefaults] objectForKey:@"eventID"] integerValue];
    
    if(self.eventID == 0) {
        [self.attendeesLabel setText:NSLocalizedString(@"Roaming nowhere in particular.\nInvite people to meetup!", nil)];
    }
    else {
        [self.httpManager GET:kEventInfo
                   parameters:@{@"event": @{@"id": [NSNumber numberWithInteger: self.eventID]}}
                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                          if([responseObject isKindOfClass:[NSDictionary class]]) {
                              CLLocationCoordinate2D coord;
                              coord.latitude = [[responseObject objectForKey:@"latitude"] floatValue];
                              coord.longitude = [[responseObject objectForKey:@"longitude"] floatValue];
                              self.destinationLocation = [[CLLocation alloc] initWithLatitude:coord.latitude longitude:coord.longitude];
                              CLGeocoder *geocoder = [[CLGeocoder alloc] init];
                              [geocoder reverseGeocodeLocation:self.destinationLocation completionHandler:^(NSArray *placemarks, NSError *error) {
                                  CLPlacemark *placemark = [placemarks objectAtIndex:0];
                                  [self.attendeesLabel setText:[NSString stringWithFormat:@"%@\nMeeting at: %@\n%d attendees", [responseObject objectForKey:@"event_name"], placemark.name, [[responseObject objectForKey:@"users"] count]]];
                                  
                              }];

                              CLLocation *selfLocation = [[CLLocation alloc] initWithLatitude:self.currentCoordinate.latitude longitude:self.currentCoordinate.longitude];
                              [geocoder reverseGeocodeLocation:selfLocation completionHandler:^(NSArray *placemarks, NSError *error) {
                                  CLPlacemark *placemark = [placemarks objectAtIndex:0];
                                  [self.currentLocationLabel setText:[NSString stringWithFormat:@"%@ ~ %.02f km from destination", placemark.name, [self.destinationLocation distanceFromLocation:selfLocation] / 1000.0]];
                              }];
                              [self getDirections:selfLocation end:self.destinationLocation];
                          }
                      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                          NSLog(@"Network error: %@", error);
                      }];
    }
}

// Unsubscribe from keyboard show/hide notifications.
- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]
     removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]
     removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)createViews
{
    
    self.mapView = [[MKMapView alloc] init];
    [self.mapView setDelegate:self];
    [self.mapView setShowsUserLocation:YES];
    [self.view addSubview: self.mapView];
    
    self.attendeesView = [[UIView alloc] init];
    [self.attendeesView setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.6]];
    [self.view addSubview:self.attendeesView];
    
    self.currentLocationLabel = [[UILabel alloc] init];
    [self.currentLocationLabel setFont:[UIFont mediumHelveticaWithSize:11]];
    [self.currentLocationLabel setTextAlignment:NSTextAlignmentCenter];
    [self.attendeesView addSubview:self.currentLocationLabel];
    
    self.attendeesLabel = [[UILabel alloc] init];
    [self.attendeesLabel setFont:[UIFont lightHelveticaWithSize:11]];
    [self.attendeesLabel setNumberOfLines:0];
    [self.attendeesLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [self.attendeesLabel setTextAlignment:NSTextAlignmentCenter];
    [self.attendeesView addSubview:self.attendeesLabel];
    
    self.attendeesButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.attendeesView addSubview:self.attendeesButton];
    
    self.composeView = [[BTWTweetComposeView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.composeView setHidden:YES];
    [self.composeView setScrollToTop:NO];
    [self.view addSubview:self.composeView];
}

- (void)setupViews
{
    [self.mapView setFrame:CGRectMake(0,
                                      0,
                                      CGRectGetWidth(self.view.frame),
                                      CGRectGetHeight(self.view.frame))];
    
    [self.attendeesView setFrame:CGRectMake(0,
                                           kNavBarHeight,
                                           CGRectGetWidth(self.view.frame),
                                           kNavBarHeight * 1.5)];
    [self.currentLocationLabel setFrame:CGRectMake(kHorizontalMargin,
                                                   kPadding,
                                                   CGRectGetWidth(self.attendeesView.frame) - 2 * kHorizontalMargin,
                                                   kLineHeight)];
    [self.attendeesLabel setFrame:CGRectMake(kHorizontalMargin,
                                             kPadding + kLineHeight,
                                             CGRectGetWidth(self.attendeesView.frame) - 2 * kHorizontalMargin,
                                             CGRectGetHeight(self.attendeesView.frame) - 2 * kPadding - kLineHeight)];
    [self.attendeesButton setFrame:CGRectMake(0,
                                              0,
                                              CGRectGetWidth(self.attendeesView.frame),
                                              CGRectGetHeight(self.attendeesView.frame))];
}

- (void) setMapCoords
{
    MKMapCamera *camera = [[MKMapCamera alloc] init];
    [camera setCenterCoordinate:self.currentCoordinate];
    [camera setAltitude:3000.0];
    
    [self.mapView setCamera:camera animated:YES];
    
}



#pragma mark - Set dummy map pins
- (void)setDummyMapPins
{
    if (self.mapPins == nil) {
        self.mapPins = [[NSMutableArray alloc]init];
    } else {
        [self.mapView removeAnnotations:self.mapPins];
        [self.mapPins removeAllObjects];
        
    }
    NSLog(@"ID IS: %@", [NSNumber numberWithInteger:[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventID"]integerValue]]);
    NSDictionary *params = @{@"event": @{@"id": [NSNumber numberWithInteger:[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventID"]integerValue]]}};
    [self.httpManager GET:kAttendeeLocations parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"SUCCESSSSSS");
        NSLog(@"JSON: %@", responseObject);
        self.mapPinData = [(NSDictionary *)responseObject objectForKey:@"list"];
        [self setMapPins];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];

    
}

- (void)setPinStatuses
{
    if (self.mapPins == nil) {
        self.mapPins = [[NSMutableArray alloc]init];
    } else {
        [self.mapView removeAnnotations:self.mapPins];
        [self.mapPins removeAllObjects];
        
    }
    NSLog(@"ID IS: %@", [NSNumber numberWithInteger:[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventID"]integerValue]]);
    NSDictionary *params = @{@"event": @{@"id": [NSNumber numberWithInteger:[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventID"]integerValue]]}};
    [self.httpManager GET:kAttendeeLocations parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.mapPinData = [(NSDictionary *)responseObject objectForKey:@"list"];
        [self setMapPins];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
    
}


#pragma mark - Set map pins from mapPinData
-(void) setMapPins
{
    //NSLog(@"setting map pins");
    for (NSDictionary *dict in self.mapPinData) {
        [self addOnePin:dict];
        NSString *name = [dict objectForKey:@"user_name"];
        CLLocationCoordinate2D coords;
        coords.longitude = [[dict objectForKey:@"user_last_long"] doubleValue];
        coords.latitude = [[dict objectForKey:@"user_last_lat"] doubleValue];
        NSString *photo_url = [[self.chat objectForKey:name] objectForKey:@"photo_url"];
        NSLog(@"PHOTO URL IS: %@", photo_url);
        if (photo_url) {
            NSLog(@"AND SO WE ARRIVE HERE!");
            NSString *url = @"http://tsukihi.org/backtier/";
            url = [url stringByAppendingString:photo_url];
            //NSLog(url);
            /*NSURL *imageURL = [NSURL URLWithString:url];
            NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
            UIImage *image = [UIImage imageWithData:imageData];*/
            NSData * imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
            UIImage *image = [UIImage imageWithData: imageData];
            
            [self addPhotoToMap:image :coords];
        }
    }
    
}

#pragma mark - Adds a single map pin
-(void) addOnePin:(NSDictionary *)pinData
{
    //NSLog(pinData[@"user_name"]);
    CLLocationCoordinate2D coords;
    coords.longitude = [pinData[@"user_last_long"] doubleValue];
    coords.latitude = [pinData[@"user_last_lat"] doubleValue];
    GTMapAnnotation *mapPin = [[GTMapAnnotation alloc]init];
    [mapPin setTitle:pinData[@"user_name"]];
    NSString *name = pinData[@"user_name"];
    [mapPin setSubtitle:[[self.chat objectForKey:name] objectForKey:@"text"]];
    [mapPin setCoordinate:coords];
    mapPin.displayType = @"user";
    [self.mapPins addObject:mapPin];
    
    [self.mapView addAnnotation:mapPin];
}

/* Changes colors of pins, but..changes *all* of them.
 
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    GTMapAnnotation *pinAnnotation = (GTMapAnnotation *)annotation;
    MKPinAnnotationView *pinView = [[MKPinAnnotationView alloc] initWithAnnotation:pinAnnotation reuseIdentifier:@"pin"];

    pinView.pinColor = MKPinAnnotationColorGreen;
    
    return pinView;
}
*/

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - photo processing

- (void)addPhotoToMap:(UIImage *)picture :(CLLocationCoordinate2D) coords
{
    /* clear all existing photo pins */
    if (self.photoPins == nil) {
        self.photoPins = [[NSMutableArray alloc]init];
    } else {
        //[self.photoPins removeAllObjects];
    }
    //[self.photoPins addObject:picture];
    // TODO: get photo locations from database
    // Get all photopins from database?
    //self.photoPins = [[NSMutableArray alloc] init];
    //[self.photoPins addObject:picture];
    //for (UIImage * in self.photoPins) {
    [self addOnePhotoPin:picture :coords];
    //}
}
    

-(void) addOnePhotoPin :(UIImage *)picture :(CLLocationCoordinate2D) coords
{
    // create new custom photo pin
    NSLog(@"about to add photo pin");
    GTMapAnnotation *photoPin = [[GTMapAnnotation alloc]init];
    [photoPin setCoordinate:coords];
    NSLog(@"COORDS: %f, %f", self.currentCoordinate.longitude, self.currentCoordinate.latitude);
    photoPin.displayType = @"photo";
    NSLog(@"Added photo pin");
    self.picture = picture; // change to param?
    [self mapView:self.mapView viewForAnnotation:photoPin];
    NSLog(@"Almost there...");
    [self.mapView addAnnotation:photoPin];
}

#pragma mark - MapView Delegate

//- (void)mapView:(MKMapView *)aMapView didUpdateUserLocation:(MKUserLocation *)aUserLocation {
//    MKCoordinateRegion region;
//    MKCoordinateSpan span;
//    span.latitudeDelta = 0.005;
//    span.longitudeDelta = 0.005;
//    CLLocationCoordinate2D location;
//    location.latitude = aUserLocation.coordinate.latitude;
//    location.longitude = aUserLocation.coordinate.longitude;
//    region.span = span;
//    region.center = location;
//    [aMapView setRegion:region animated:YES];
//}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    // If it's a relatively recent event, turn off updates to save power.
    CLLocation* location = [locations lastObject];
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (abs(howRecent) < 15.0) {
        // If the event is recent, do something with it.
        NSLog(@"latitude %+.6f, longitude %+.6f\n",
              location.coordinate.latitude,
              location.coordinate.longitude);
        self.currentCoordinate = location.coordinate;
        
        [self saveLocationUpdateWithCoordinate:self.currentCoordinate];
        
        CLGeocoder *geocode = [[CLGeocoder alloc] init];
        [geocode reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            if(self.eventID == 0 || !self.destinationLocation)
                [self.currentLocationLabel setText:[NSString stringWithFormat:@"Currently at: %@", placemark.name]];
            else
                [self.currentLocationLabel setText:[NSString stringWithFormat:@"%@ ~ %.02f km from destination", placemark.name, [self.destinationLocation distanceFromLocation:location] / 1000.0]];
        }];
        
        //[self setMapCoords];
        //[self setDummyMapPins];
    }
}

- (void)saveLocationUpdateWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    NSLog(@"lattttietttuddee %f\n", coordinate.latitude);
    NSNumber *userID = [[NSUserDefaults standardUserDefaults] objectForKey:@"userID"];
    NSDictionary *params = @{@"user": @{@"id": userID,
                                        @"user_last_lat": [NSNumber numberWithDouble:coordinate.latitude],
                                        @"user_last_long": [NSNumber numberWithDouble:coordinate.longitude]}};
    [self.httpManager GET:kUpdateLocation parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        [self setMapCoords];
        [self setDummyMapPins];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void)startStandardUpdates
{
    NSLog(@"Standard updates started\n");
    // Create the location manager if this object does not
    // already have one.
    if (nil == self.locationManager)
        self.locationManager = [[CLLocationManager alloc] init];
    
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    
    // Set a movement threshold for new events.
    self.locationManager.distanceFilter = 500; // meters
    
    [self.locationManager startUpdatingLocation];
}

//- (MKAnnotationView *)createCustomPhotoPin :(MKMapView *)map viewForAnnotation:(id <MKAnnotation>)annotation :(UIImage *)picture
- (MKAnnotationView *) mapView:(MKMapView *)map viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass: [MKUserLocation class]])
        return nil;
    
    if ([((GTMapAnnotation *)annotation).displayType  isEqual: @"user"])
        return nil;
        
    static NSString *AnnotationViewID = @"annotationViewID";
    
    MKAnnotationView *annotationView = (MKAnnotationView *)[map dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
    
    if (annotationView == nil)
    {
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
    }
    
    // scale picture size
    CGRect rect = CGRectMake(0,0,50,50);
    CGFloat scale = [[UIScreen mainScreen]scale];
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, scale);
    [[UIBezierPath bezierPathWithRoundedRect:rect
                                cornerRadius:25.0] addClip];
    NSLog(@"drawing drawing");
    [self.picture drawInRect:CGRectMake(0,0,rect.size.width,rect.size.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    annotationView.image = newImage;

    annotationView.annotation = annotation;
    //[self.mapView addAnnotation:annotation];
    return annotationView;
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolyline *route = overlay;
        MKPolylineRenderer *routeRenderer = [[MKPolylineRenderer alloc] initWithPolyline:route];
        routeRenderer.strokeColor = [UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:0.3];
        return routeRenderer;
    }
    else return nil;
}

- (void)getDirections:(CLLocation *)start end:(CLLocation *)destination
{
    MKPlacemark *sourcePlacemark = [[MKPlacemark alloc] initWithCoordinate:start.coordinate addressDictionary:@{}];
    MKPlacemark *destinationPlacemark = [[MKPlacemark alloc] initWithCoordinate:destination.coordinate addressDictionary:@{}];
    MKMapItem *startItem = [[MKMapItem alloc] initWithPlacemark:sourcePlacemark];
    MKMapItem *endItem = [[MKMapItem alloc] initWithPlacemark:destinationPlacemark];
    
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    request.source = startItem;
    request.destination = endItem;
    request.requestsAlternateRoutes = NO;
    
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        if (error) {
            NSLog(@"Error : %@", error);
        }
        else {
            [self showRoute: response];
        }
    }];
}

- (void)showRoute:(MKDirectionsResponse *)response
{
    [self.mapView removeOverlays:self.mapView.overlays];
    
    for (MKRoute *route in response.routes) {
        [self.mapView addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
        for (MKRouteStep *step in route.steps) {
            NSLog(@"%@", step.instructions);
        }
    }

}

- (CLLocationCoordinate2D)getCurrentLocation
{
    NSLog(@"current coordinates: %f", self.currentCoordinate.longitude);
    return self.currentCoordinate;
}

#pragma mark - Buttons
- (IBAction)logout:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"userName"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"userID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)showOptions:(id)sender {
    [self.settingsSheet showInView:self.view];
}

#pragma mark - Actionsheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            NSLog(@"Post message");
            [self freezeFrameForPopup];
            break;
        case 1:
            NSLog(@"Set meetup details / Invite friends");
            [self performSegueWithIdentifier:@"pushToNewEvent" sender:self];
            break;
        case 2:
            NSLog(@"View meetup invitations");
            break;
        case 3:
            NSLog(@"Cancel meetup");
            break;
        default:
            break;
    }
}

#pragma mark - Freeze/unfreeze popups

- (void)freezeFrameForPopup
{
    self.hasPopupOpen = YES;
    
    [self.mapView setScrollEnabled:NO];
    [self.mapView setUserInteractionEnabled:NO];
    
    [self.navigationController.navigationItem.rightBarButtonItem setEnabled:NO];
    [self.navigationController.navigationItem.leftBarButtonItem setEnabled:NO];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)), NO, 0);
    
    [self.view drawViewHierarchyInRect:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)) afterScreenUpdates:NO];
    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIImage *blurredSnapshotImage = [snapshotImage applyLightEffect];
    UIGraphicsEndImageContext();
    
    [self.composeView setBlurredBackground:blurredSnapshotImage];
    [self.composeView setEventID:[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventID"]integerValue]];
    
    __weak GTChatViewController *weakSelf = self;
    [self.composeView setEarlyCompletionBlock:^(BOOL success){
        [UIView animateWithDuration:0.3 animations:^{
            [weakSelf.tabBarController.tabBar setAlpha:1.0];
        }];
    }];
    GTCompletionBlock dismissBlock = ^(BOOL success){
        [weakSelf unfreezeFrameForSuccess:success];
    };
    
    self.composeView.completionBlock = dismissBlock;
    self.composeView.delegate = self;
    
    [self.composeView setHidden:NO];
    [self.composeView animateIn];
}

- (void)unfreezeFrameForSuccess:(BOOL)success
{
    self.hasPopupOpen = NO;

    [self.composeView setHidden:YES];
    
    [self.mapView setScrollEnabled:YES];
    [self.navigationController.navigationItem.rightBarButtonItem setEnabled:YES];
    [self.navigationController.navigationItem.leftBarButtonItem setEnabled:YES];
    [self.mapView setUserInteractionEnabled:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"pushToNewEvent"]) {
        GTNewEventTableViewController *eventViewController = segue.destinationViewController;
        eventViewController.delegate = self;
        eventViewController.selectedCoordinates = self.currentCoordinate;
    }
}


@end
