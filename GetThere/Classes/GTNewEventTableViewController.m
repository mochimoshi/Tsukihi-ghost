//
//  GTNewEventTableViewController.m
//  GetThere
//
//  Created by Alex Yuh-Rern Wang on 5/4/14.
//  Copyright (c) 2014 Chromatiqa. All rights reserved.
//

#import "GTNewEventTableViewController.h"

#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

#import <RETableViewManager/RETableViewManager.h>
#import <RETableViewManager/RETableViewOptionsController.h>

#import <AFNetworking/AFNetworking.h>

#import "GTUtilities.h"
#import "GTEventLocationViewController.h"
#import "GTChatViewController.h"

@interface GTNewEventTableViewController ()<RETableViewManagerDelegate, GTEventLocatorDelegate>

@property (strong, nonatomic) RETableViewManager *manager;
@property (strong, nonatomic) RETableViewSection *eventInfoSection;
@property (strong, nonatomic) RETableViewSection *eventInviteSection;
@property (strong, nonatomic) RETableViewSection *eventButton;

@property (strong, nonatomic) RETextItem *eventNameItem;
@property (strong, nonatomic) RETableViewItem *eventLocationItem;
@property (strong, nonatomic) REDateTimeItem *eventStartTimeItem;
@property (strong, nonatomic) REMultipleChoiceItem *eventInviteesItem;

@property (assign, nonatomic) CLLocationCoordinate2D center;

@property (strong, nonatomic) GTEventLocationViewController *locationViewController;

@end

@implementation GTNewEventTableViewController

#define kNewEventURL @"http://tsukihi.org/backtier/events/create"
#define kUpdateEventURL @"http://tsukihi.org/backtier/events/update"

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.selectedLocationName = nil;
    self.locationViewController = [[GTEventLocationViewController alloc] init];
    
    self.manager = [[RETableViewManager alloc] initWithTableView:self.tableView delegate:self];
    self.eventInfoSection = [self buildEventSection];
    self.eventInviteSection = [self buildInviteSection];
    self.eventButton = [self buildButton];
}

- (RETableViewSection *)buildEventSection
{
    RETableViewSection *section = [RETableViewSection sectionWithHeaderTitle:@"Event information"];
    [self.manager addSection:section];
    
    self.eventNameItem = [RETextItem itemWithTitle:@"Name" value:nil placeholder:[NSString stringWithFormat:@"Meetup @ %@", [GTUtilities formattedDateStringFromDate:[NSDate date]]]];
    
    GTNewEventTableViewController *weakself = self;
    
    self.eventLocationItem = [[RETableViewItem alloc] initWithTitle:@"Location" accessoryType:UITableViewCellAccessoryDisclosureIndicator selectionHandler:^(RETableViewItem *item) {
        [item deselectRowAnimated:YES];
        
        self.locationViewController.delegate = self;
        self.locationViewController.completionBlock = ^{
            weakself.center = weakself.locationViewController.center;
            item.detailLabelText = weakself.selectedLocationName;
            [item reloadRowWithAnimation:UITableViewRowAnimationNone];
        };
        
        [self.navigationController pushViewController:self.locationViewController animated:YES];
    }];
    self.eventLocationItem.style = UITableViewCellStyleValue1;
    self.eventLocationItem.detailLabelText = @"Current location";

    self.eventStartTimeItem = [REDateTimeItem itemWithTitle:@"Start time" value:[NSDate date] placeholder:nil format:@"MM/dd/yyyy hh:mm a" datePickerMode:UIDatePickerModeDateAndTime];
    
    [self.eventStartTimeItem setMinuteInterval:15];
    
    // Use inline date picker in iOS 7
    if (REUIKitIsFlatMode()) {
        self.eventStartTimeItem.inlineDatePicker = YES;
    }
    
    
    [section addItem:self.eventNameItem];
    [section addItem:self.eventLocationItem];
    [section addItem:self.eventStartTimeItem];
    
    return section;
}

- (RETableViewSection *)buildInviteSection
{
    __weak GTNewEventTableViewController *weakSelf = self;
    
    RETableViewSection *section = [RETableViewSection sectionWithHeaderTitle:@"Invitations"];
    [self.manager addSection:section];
    
    self.eventInviteesItem = [REMultipleChoiceItem itemWithTitle:@"Invite..." value:nil selectionHandler:^(REMultipleChoiceItem *item) {
        [item deselectRowAnimated:YES];
        
        // Generate sample options
        //
        NSMutableArray *options = [[NSMutableArray alloc] initWithArray:@[@"Jessica Liu", @"Angela Yeung"]];
        
        // Present options controller
        //
        RETableViewOptionsController *optionsController = [[RETableViewOptionsController alloc] initWithItem:item options:options multipleChoice:YES completionHandler:^{
            [item reloadRowWithAnimation:UITableViewRowAnimationNone];
        }];
        
        // Adjust styles
        //
        optionsController.delegate = weakSelf;
        optionsController.style = section.style;
        if (weakSelf.tableView.backgroundView == nil) {
            optionsController.tableView.backgroundColor = weakSelf.tableView.backgroundColor;
            optionsController.tableView.backgroundView = nil;
        }
        
        // Push the options controller
        //
        [weakSelf.navigationController pushViewController:optionsController animated:YES];
    }];
    
    [section addItem:self.eventInviteesItem];
    
    return section;
}

- (RETableViewSection *)buildButton
{
    RETableViewSection *section = [RETableViewSection section];
    [self.manager addSection:section];
    
    RETableViewItem *buttonItem = [RETableViewItem itemWithTitle:@"Create meetup!" accessoryType:UITableViewCellAccessoryNone selectionHandler:^(RETableViewItem *item) {
        item.title = @"Submitting...";
        [item reloadRowWithAnimation:UITableViewRowAnimationAutomatic];
        
        NSDictionary *eventDictionary = @{@"event": @{@"user_id" : [[NSUserDefaults standardUserDefaults] valueForKey:@"userID"],
                                                      @"event_name": (self.eventNameItem.value) ? self.eventNameItem.value : [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Meetup @ ", nil), [GTUtilities formattedDateStringFromDate:self.eventStartTimeItem.value]],
                                                      @"start_time": self.eventStartTimeItem.value,
                                                        @"latitude": [NSNumber numberWithFloat:self.selectedCoordinates.latitude],
                                                       @"longitude": [NSNumber numberWithFloat:self.selectedCoordinates.longitude],
                                                     @"invitee_ids": @[@1, @2, @3]}};
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager GET:kNewEventURL parameters:eventDictionary success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"RESPONSE: %@", responseObject);
            //[[NSUserDefaults standardUserDefaults] setValue:[responseObject objectForKey:@"event_id"] forKey:@"eventID"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"PopulateUserLocations" object:self userInfo:responseObject];
            
            GTChatViewController *chatViewController = (GTChatViewController *)self.delegate;
            chatViewController.eventID = [[responseObject objectForKey:@"event_id"] integerValue];
            [self.navigationController popViewControllerAnimated:YES];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops! Network connectivity issue."
                                                            message:@"The event cannot be submitted at the moment. Please try again shortly!"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Okay"
                                                  otherButtonTitles: nil];
            [alert show];
            NSLog(@"Error: %@", error.localizedDescription);
            item.title = NSLocalizedString(@"Update meetup!", nil);
            [item reloadRowWithAnimation:UITableViewRowAnimationAutomatic];
        }];
    }];
    buttonItem.textAlignment = NSTextAlignmentCenter;
    [section addItem:buttonItem];
    
    return section;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    self.delegate = nil;
}
@end
