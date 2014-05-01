//
//  GTChatViewController.m
//  GetThere
//
//  Created by Angela Yeung on 4/29/14.
//  Copyright (c) 2014 Chromatiqa. All rights reserved.
//

#import "GTChatViewController.h"
#import "GTMapAnnotation.h"
#import "GTChatTableViewCell.h"

#import "UILabel+GTLabel.h"
#import "UIFont+BTWFont.h"
#import "GTConstants.h"
#import "GTUtilities.h"

#import <MapKit/MapKit.h>
#import <Firebase/Firebase.h>

@interface GTChatViewController ()<UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *chatInputTextField;

@property (strong, nonatomic) UIImagePickerController *imagePicker;

@property (strong, nonatomic) NSMutableArray *chat;
@property (strong, nonatomic) Firebase *firebase;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSMutableArray *mapPinData;

@end

@implementation GTChatViewController

#define kFirechatNS @"https://getthere.firebaseio.com/"

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialize array that will store chat messages.
    self.chat = [[NSMutableArray alloc] init];
    
    // Initialize the root of our Firebase namespace.
    self.firebase = [[Firebase alloc] initWithUrl:kFirechatNS];
    
    [self.firebase observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        // Add the chat message to the array.
        [self.chat addObject:snapshot.value];
        // Reload the table view so the new message will show up.
        [self.tableView reloadData];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.chat count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }];
    
    self.imagePicker = [[UIImagePickerController alloc] init];
    [self.imagePicker setDelegate:self];
    
    self.name = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setDummyMapPins];
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = 37.4240943;
    coordinate.longitude = -122.1701957;

    MKMapCamera *camera = [[MKMapCamera alloc] init];
    [camera setCenterCoordinate:coordinate];
    [camera setAltitude:3000.0];

    [self.mapView setCamera:camera animated:YES];
}


#pragma mark - Set dummy map pins
- (void)setDummyMapPins
{
    // Sorry..super disgusting dummy array
    self.mapPinData = [[NSMutableArray alloc] initWithArray:@[@{@"title":@"Jason Jong", @"subtitle": @"Gelato Classico: 0.5 mi away", @"longitude":[NSNumber numberWithDouble:     -122.163283], @"latitude":[NSNumber numberWithDouble:37.446097]},
        @{@"title":@"Angela Yeung", @"subtitle":@"Meyer Library: 0.3 mi away" , @"longitude":[NSNumber numberWithDouble:-122.167474], @"latitude":[NSNumber numberWithDouble:37.425956]},
        @{@"title":@"Alex Wang", @"subtitle":@"On the move: 0.1 mi away" , @"longitude":[NSNumber numberWithDouble:-122.165388], @"latitude":[NSNumber numberWithDouble:37.427577]}]];
    
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
    CLLocationCoordinate2D coords;
    coords.latitude = [pinData[@"latitude"] doubleValue];
    coords.longitude = [pinData[@"longitude"] doubleValue];
    
    GTMapAnnotation *mapPin = [[GTMapAnnotation alloc]init];
    [mapPin setTitle:pinData[@"title"]];
    [mapPin setSubtitle:pinData[@"subtitle"]];
    [mapPin setCoordinate:coords];
    
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

#pragma mark - Keyboard handling

// Subscribe to keyboard show/hide notifications.
- (void)viewWillAppear:(BOOL)animated
{
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
            [cell.locationImageView setImage:picture];
            [cell.timestampLabel setText:chatMessage[@"timestamp"]];
        } else {
            [cell.message setText: chatMessage[@"text"]];
            [cell.usernameLabel setText: chatMessage[@"name"]];
            [cell.locationImageView setImage:nil];
            [cell.timestampLabel setText:chatMessage[@"timestamp"]];
        }
    }
    
    [cell repositionCellItems];
    
    return cell;
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
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
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
