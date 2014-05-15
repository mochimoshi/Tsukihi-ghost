//
//  GTChatViewController.m
//  GetThere
//
//  Created by Angela Yeung on 4/29/14.
//  Copyright (c) 2014 Chromatiqa. All rights reserved.
//

#import "GTChatViewController.h"
#import "GTPersonViewController.h"
#import "GTLoginViewController.h"
#import "GTMapAnnotation.h"
#import "GTChatTableViewCell.h"

#import "UILabel+GTLabel.h"
#import "UIFont+BTWFont.h"
#import "GTConstants.h"
#import "GTUtilities.h"

#import <MapKit/MapKit.h>
#import <Firebase/Firebase.h>
#import <CoreLocation/CoreLocation.h>

@interface GTChatViewController ()<UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate,CLLocationManagerDelegate>

/* user info */

@property (strong, nonatomic) MKMapView *mapView;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UITextField *chatInputTextField;
@property (strong, nonatomic) UIButton *chatImagingButton;
@property (strong, nonatomic) UIImageView *previewImage;


@property (strong, nonatomic) UIImagePickerController *imagePicker;


@property (strong, nonatomic) NSMutableArray *chat;
@property (strong, nonatomic) Firebase *firebase;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSMutableArray *mapPinData;

/* location manager */
@property (strong, nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, assign) CLLocationDegrees currentLatitude;
@property (nonatomic, assign) CLLocationDegrees currentLongitude;
@property (strong, nonatomic) NSMutableArray *mapPins;

@property (strong, nonatomic) UIImage *picture;

/* http manager */
@property (strong, nonatomic) AFHTTPRequestOperationManager *httpManager;


@end

@implementation GTChatViewController

#define kFirechatNS @"https://getthere.firebaseio.com/"

#define kAttendeeLocations @"http://tsukihi.org/backtier/events/get_event_attendee_locations"

static const CGFloat kInputHeight = 30;
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
    
    self.chat = [[NSMutableArray alloc] init];
    
    // Initialize the root of our Firebase namespace.
    self.firebase = [[Firebase alloc] initWithUrl:kFirechatNS];
    
    [self.firebase observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        // Add the chat message to the array.
        [self.chat addObject:snapshot.value];
        // Reload the table view so the new message will show up.
        [self.tableView reloadData];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.chat count] - 1 inSection:0]
                              atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }];
    
    // setting up text field response
    [self.chatInputTextField addTarget:self action:@selector(chatInputActive:) forControlEvents:UIControlEventEditingDidBegin];
    
    self.name = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
    

    [self startStandardUpdates];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self createViews];
    [self setupViews];
 
    [self setDummyMapPins];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = 37.4240943;
    coordinate.longitude = -122.1701957;
    
    MKMapCamera *camera = [[MKMapCamera alloc] init];
    [camera setCenterCoordinate:coordinate];
    [camera setAltitude:3000.0];
    
    [self.mapView setCamera:camera animated:YES];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(keyboardWillShow:)
     name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(keyboardWillHide:)
     name:UIKeyboardWillHideNotification object:nil];
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
    self.imagePicker = [[UIImagePickerController alloc] init];
    [self.imagePicker setDelegate:self];
    
    self.mapView = [[MKMapView alloc] init];
    [self.mapView setDelegate:self];
    [self.mapView setShowsUserLocation:YES];
    [self.view addSubview: self.mapView];
    
    self.chatImagingButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.chatImagingButton setTitle:NSLocalizedString(@"Camera", nil) forState:UIControlStateNormal];
    [self.chatImagingButton addTarget:self action:@selector(getCamera:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.chatImagingButton];
    
    self.chatInputTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    [self.chatInputTextField setDelegate:self];
    [self.view addSubview:self.chatInputTextField];
    
    self.tableView = [[UITableView alloc] init];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.view addSubview:self.tableView];
    
    // creating the preview image as transparent
    self.previewImage = [[UIImageView alloc] init];
    [self.previewImage setContentMode:UIViewContentModeScaleAspectFill];
    [self.previewImage setClipsToBounds:YES];
    [self.previewImage setAlpha:0];
    [self.view addSubview:self.previewImage];
    
    self.previewImage.userInteractionEnabled = YES;
    UITapGestureRecognizer *photoMinimize = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(photoTapGesture:)];
    photoMinimize.numberOfTapsRequired = 1;
    [self.previewImage addGestureRecognizer:photoMinimize];
}

- (void)setupViews
{
    [self.mapView setFrame:CGRectMake(0,
                                      kNavBarHeight,
                                      CGRectGetWidth(self.view.frame),
                                      CGRectGetHeight(self.view.frame) / 2.0 - kNavBarHeight)];
    
    CGRect buttonFrame = [self.chatImagingButton frame];
    buttonFrame.origin.x = kHorizontalMargin;
    buttonFrame.origin.y = CGRectGetHeight(self.view.frame) - kVerticalMargin - kInputHeight;
    [self.chatImagingButton setFrame:buttonFrame];
    [self.chatImagingButton sizeToFit];
    
    [self.chatInputTextField setFrame:CGRectMake(CGRectGetMaxX(self.chatImagingButton.frame) + kPadding,
                                                CGRectGetMinY(self.chatImagingButton.frame),
                                                CGRectGetWidth(self.view.frame) - CGRectGetMaxX(self.chatImagingButton.frame) - kPadding - 2 * kHorizontalMargin,
                                                 kInputHeight)];
    [self.tableView setFrame:CGRectMake(0,
                                        CGRectGetHeight(self.mapView.frame) + kNavBarHeight,
                                        CGRectGetWidth(self.view.frame),
                                        CGRectGetHeight(self.view.frame) - CGRectGetHeight(self.mapView.frame) - kNavBarHeight - kInputHeight - kVerticalMargin)];
    [self.previewImage setFrame:self.tableView.frame];
}

- (void) setMapCoords
{
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = self.currentLatitude;
    coordinate.longitude = self.currentLongitude;
    
    MKMapCamera *camera = [[MKMapCamera alloc] init];
    [camera setCenterCoordinate:coordinate];
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

    NSDictionary *params = @{@"event": @{@"id": @"1"}};
    [self.httpManager GET:kAttendeeLocations parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        /*global_userInfo = [(NSDictionary *)responseObject objectForKey:@"user"];
        global_userId = [global_userInfo objectForKey:@"id"];*/
        self.mapPinData = [(NSDictionary *)responseObject objectForKey:@"list"];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];

    [self setMapPins];
}

#pragma mark - Set map pins from mapPinData
-(void) setMapPins
{
    for (NSDictionary *dict in self.mapPinData) {
        [self addOnePin:dict];
    }
}

#pragma mark - Adds a single map pin
-(void) addOnePin:(NSDictionary *)pinData
{
    /*CLLocationCoordinate2D coords;
    coords.latitude = [pinData[@"latitude"] doubleValue];
    coords.longitude = [pinData[@"longitude"] doubleValue];
    
    GTMapAnnotation *mapPin = [[GTMapAnnotation alloc]init];
    [mapPin setTitle:pinData[@"title"]];
    [mapPin setSubtitle:pinData[@"subtitle"]];
    [mapPin setCoordinate:coords];
    [self.mapPins addObject:mapPin];
    
    [self.mapView addAnnotation:mapPin];*/
    CLLocationCoordinate2D coords;
    coords.latitude = [pinData[@"user_last_lat"] doubleValue];
    coords.longitude = [pinData[@"user_last_long"] doubleValue];
    
    GTMapAnnotation *mapPin = [[GTMapAnnotation alloc]init];
    [mapPin setTitle:pinData[@"user_name"]];
    [mapPin setSubtitle:pinData[@""]];
    [mapPin setCoordinate:coords];
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

#pragma mark - TableView delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *chatMessage = [self.chat objectAtIndex:indexPath.row];
    if ([chatMessage objectForKey:@"image"]) {
        return kCellMargin * 2 + kChatImageDimension + kPadding * 3 + kLineHeight * 2;
    }
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame) - 2 * kHorizontalMargin, kHorizontalMargin)];
    [label setFont:[UIFont lightHelveticaWithSize:12.0]];
    [label setText:chatMessage[@"text"]];
    [label setLineBreakMode:NSLineBreakByWordWrapping];
    [label setNumberOfLines:0];
    [label sizeToFitWithExpectedWidth:CGRectGetWidth(self.view.frame) - 2 * kCellMargin];
    
    return kCellMargin * 2 + kPadding * 3 + kLineHeight * 2 + CGRectGetHeight(label.frame);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.chat count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"chatCell";
    GTChatTableViewCell *cell = (GTChatTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[GTChatTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary* chatMessage = [self.chat objectAtIndex:indexPath.row];
    if (chatMessage) {
        if ([chatMessage objectForKey:@"image"]){
            NSData *picData = [[NSData alloc] initWithBase64EncodedString:chatMessage[@"image"] options:0];
            UIImage *picture = [UIImage imageWithData:picData];
            
            [cell.usernameLabel setText: chatMessage[@"name"]];
            [cell.message setText: @""];
            
            [cell.locationImageView setBackgroundImage:picture forState:UIControlStateNormal];
            [cell.locationImageView addTarget:self action:@selector(expandPhoto:) forControlEvents:UIControlEventTouchUpInside];


            [cell.timestampLabel setText:chatMessage[@"timestamp"]];
        } else {
            [cell.message setText: chatMessage[@"text"]];
            [cell.usernameLabel setText: chatMessage[@"name"]];
            [cell.locationImageView setBackgroundImage:nil forState:UIControlStateNormal];
            [cell.timestampLabel setText:chatMessage[@"timestamp"]];
        }
    }
    
    [cell repositionCellItems];
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"pushToPerson"]) {
        GTPersonViewController *controller = (GTPersonViewController *)segue.destinationViewController;
        controller.mapView = self.mapView;
        controller.sender = sender;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*NSLog(@"hello");
    GTPersonViewController * flipViewController = [[GTPersonViewController alloc] initWithNibName:@"flip" bundle:[NSBundle mainBundle]];
    [self.view addSubview:flipViewController.view];*/
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
    [self performSegueWithIdentifier:@"pushToPerson" sender:cell];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if([self.chatInputTextField isFirstResponder]) {
        [self.chatInputTextField resignFirstResponder];
    }
}

#pragma mark - pushPhotoToFirebase

- (void)pushPhotoToFirebase:(UIImage *)picture
{
    if(picture) {
        NSData *imageData = UIImageJPEGRepresentation(picture, 0.8);
        [[self.firebase childByAutoId] setValue:@{@"name" : self.name, @"timestamp": [GTUtilities formattedDateStringFromDate:[NSDate date]], @"text": @"", @"image":[imageData base64EncodedStringWithOptions:0]}];
    }
}

- (void)addPhotoToMap:(UIImage *)picture
{
    // create new custom map pin
    CLLocationCoordinate2D coords;
    coords.latitude = self.currentLatitude;
    coords.longitude = self.currentLongitude;
    
    GTMapAnnotation *mapPin = [[GTMapAnnotation alloc]init];
    [mapPin setTitle:@"photo1"];
    [mapPin setSubtitle:@"blahdibah"];
    [mapPin setCoordinate:coords];
    [self.mapPins addObject:mapPin];
    self.picture = picture;
    [self mapView:self.mapView viewForAnnotation:mapPin];
    
    [self.mapView addAnnotation:mapPin];
}


#pragma mark - TextField delegate

- (BOOL)textFieldShouldReturn:(UITextField*)aTextField
{
    if ([aTextField.text length] == 0) {
        return NO;
    }
    [aTextField resignFirstResponder];
    
    // This will also add the message to our local array self.chat because
    // the FEventTypeChildAdded event will be immediately fired.
    [[self.firebase childByAutoId] setValue:@{@"name" : self.name,  @"timestamp": [GTUtilities formattedDateStringFromDate:[NSDate date]], @"text": aTextField.text}];
    
    [aTextField setText:@""];
    return NO;
}


// Setup keyboard handlers to slide the view containing the table view and
// text field upwards when the keyboard shows, and downwards when it hides.
- (void)keyboardWillShow:(NSNotification*)notification
{
    [self moveView:[notification userInfo] up:YES];
}

- (void)keyboardWillHide:(NSNotification*)notification
{
    [self moveView:[notification userInfo] up:NO];
}

- (void)moveView:(NSDictionary*)userInfo up:(BOOL)up
{
    CGRect keyboardEndFrame;
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey]
     getValue:&keyboardEndFrame];
    
    UIViewAnimationCurve animationCurve;
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey]
     getValue:&animationCurve];
    
    NSTimeInterval animationDuration;
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey]
     getValue:&animationDuration];
    
    // Get the correct keyboard size to we slide the right amount.
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    CGRect keyboardFrame = [self.view convertRect:keyboardEndFrame toView:nil];
    int y = keyboardFrame.size.height * (up ? -1 : 1);
    self.view.frame = CGRectOffset(self.view.frame, 0, y);
    
    [UIView commitAnimations];
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

#pragma mark - PhotoPicker Delegate

- (IBAction)getCamera:(id)sender
{
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:self.imagePicker animated:YES completion:nil];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *img = [info objectForKey:UIImagePickerControllerOriginalImage];
    UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil);
    [self pushPhotoToFirebase:img];
    [self addPhotoToMap:img];
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
}

// expand photo to bottom half of screen when clicked on
- (void)expandPhoto:(id)sender
{
    NSLog(@"button was clicked");
    UIButton *img = (UIButton *) sender;
    [self.previewImage setImage:img.currentBackgroundImage];
    [self.previewImage setAlpha:1.0];
    [self.chatInputTextField resignFirstResponder];
}

- (void)chatInputActive:(id)sender
{
    NSLog(@"text input active");
    if (self.previewImage.alpha == 1.0) {
        [UIView animateWithDuration:0.3 animations:^{
            [self.previewImage setAlpha: 0.0];
        }];
    }
}

- (void)photoTapGesture: (id)sender
{
    NSLog(@"photo tapped");
    if (self.previewImage.alpha == 1.0) {
        [UIView animateWithDuration:0.3 animations:^{
            [self.previewImage setAlpha: 0.0];
        }];
    }
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
    // If it's a relatively recent event, turn off updates to save power.
    CLLocation* location = [locations lastObject];
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (abs(howRecent) < 15.0) {
        // If the event is recent, do something with it.
        NSLog(@"latitude %+.6f, longitude %+.6f\n",
              location.coordinate.latitude,
              location.coordinate.longitude);
        self.currentLatitude = location.coordinate.latitude;
        self.currentLongitude = location.coordinate.longitude;
        [self saveLocationUpdate :self.currentLatitude :self.currentLongitude];
        [self setMapCoords];
        [self setDummyMapPins];
    }
}

- (void)saveLocationUpdate:(CLLocationDegrees)lat :(CLLocationDegrees)lon
{
    NSNumber *userID = [[NSUserDefaults standardUserDefaults] objectForKey:@"userID"];
    NSDictionary *params = @{@"user": @{@"user_id": userID,
                                        @"user_last_lat": [NSNumber numberWithDouble:lat],
                                        @"user_last_lon": [NSNumber numberWithDouble:lon]}};
    [self.httpManager GET:@"http://tsukihi.org/backtier/users/update_location" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
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

- (MKAnnotationView *)mapView:(MKMapView *)map viewForAnnotation:(id <MKAnnotation>)annotation
{
    static NSString *AnnotationViewID = @"annotationViewID";
    
    MKAnnotationView *annotationView = (MKAnnotationView *)[map dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
    
    if (annotationView == nil)
    {
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
    }
    
    annotationView.image = self.picture;
    annotationView.annotation = annotation;
    
    return annotationView;
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
