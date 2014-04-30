//
//  GTChatViewController.m
//  GetThere
//
//  Created by Angela Yeung on 4/29/14.
//  Copyright (c) 2014 Chromatiqa. All rights reserved.
//

#import "GTChatViewController.h"

#import <MapKit/MapKit.h>
#import <Firebase/Firebase.h>

@interface GTChatViewController ()<UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *chatInputTextField;

@property (strong, nonatomic) NSMutableArray *chat;
@property (strong, nonatomic) Firebase *firebase;
@property (strong, nonatomic) NSString *name;


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
    }];
    
    self.name = @"Egg Custard";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.chat count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"chatCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary* chatMessage = [self.chat objectAtIndex:indexPath.row];
    if (chatMessage != nil) {
        if ([chatMessage objectForKey:@"image"]){
            UIImage *picture = [UIImage imageWithData:chatMessage[@"image"]];
            // Do stuff here with the picture!
            
        } else {
            cell.textLabel.text = chatMessage[@"text"];
            cell.detailTextLabel.text = chatMessage[@"name"];
        }
    }
    
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if([self.chatInputTextField isFirstResponder]) {
        [self.chatInputTextField resignFirstResponder];
    }
}

#pragma mark - pushPhotoToFirebase

- (void)pushPhotoToFirebase:(UIImage *)picture
{
    if(picture) {
        NSData *imageData = [UIImageJPEGRepresentation(picture, 0.8) base64EncodedDataWithOptions:0];
        [[self.firebase childByAutoId] setValue:@{@"name" : self.name, @"text": @"", @"image":imageData}];
    }
}


#pragma mark - TextField delegate

- (BOOL)textFieldShouldReturn:(UITextField*)aTextField
{
    [aTextField resignFirstResponder];
    
    // This will also add the message to our local array self.chat because
    // the FEventTypeChildAdded event will be immediately fired.
    [[self.firebase childByAutoId] setValue:@{@"name" : self.name, @"text": aTextField.text}];
    
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

- (void)mapView:(MKMapView *)aMapView didUpdateUserLocation:(MKUserLocation *)aUserLocation {
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.005;
    span.longitudeDelta = 0.005;
    CLLocationCoordinate2D location;
    location.latitude = aUserLocation.coordinate.latitude;
    location.longitude = aUserLocation.coordinate.longitude;
    region.span = span;
    region.center = location;
    [aMapView setRegion:region animated:YES];
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
