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

@interface GTNewEventTableViewController ()<RETableViewManagerDelegate>

@property (strong, nonatomic) RETableViewManager *manager;
@property (strong, nonatomic) RETableViewSection *eventInfoSection;
@property (strong, nonatomic) RETableViewSection *eventInviteSection;
@property (strong, nonatomic) RETableViewSection *eventButton;

@property (strong, nonatomic) RETextItem *eventNameItem;
@property (strong, nonatomic) RETextItem *eventLocationItem;
@property (strong, nonatomic) REDateTimeItem *eventStartTimeItem;
@property (strong, nonatomic) REDateTimeItem *eventEndTimeItem;
@property (strong, nonatomic) RELongTextItem *eventNoteItem;
@property (strong, nonatomic) REMultipleChoiceItem *eventInviteesItem;
@end

@implementation GTNewEventTableViewController

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
    
    self.manager = [[RETableViewManager alloc] initWithTableView:self.tableView delegate:self];
    self.eventInfoSection = [self buildEventSection];
    self.eventInviteSection = [self buildInviteSection];
    self.eventButton = [self buildButton];
}

- (RETableViewSection *)buildEventSection
{
    RETableViewSection *section = [RETableViewSection sectionWithHeaderTitle:@"Event information"];
    [self.manager addSection:section];
    
    self.eventNameItem = [RETextItem itemWithTitle:@"Name" value:nil placeholder:@"CS247 Project Meeting"];
    self.eventLocationItem = [RETextItem itemWithTitle:@"Location" value:nil placeholder:@"Huang Basement"];

    self.eventStartTimeItem = [REDateTimeItem itemWithTitle:@"Start time" value:[NSDate date] placeholder:nil format:@"MM/dd/yyyy hh:mm a" datePickerMode:UIDatePickerModeDateAndTime];
    self.eventEndTimeItem = [REDateTimeItem itemWithTitle:@"End time" value:[NSDate date] placeholder:nil format:@"MM/dd/yyyy hh:mm a" datePickerMode:UIDatePickerModeDateAndTime];
    
    // Use inline date picker in iOS 7
    if (REUIKitIsFlatMode()) {
        self.eventStartTimeItem.inlineDatePicker = YES;
        self.eventEndTimeItem.inlineDatePicker = YES;
    }
    
    self.eventNoteItem = [RELongTextItem itemWithValue:nil placeholder:@"Put event notes here! e.g. Aim to finish milestone 4"];
    self.eventNoteItem.cellHeight = 88;
    
    
    [section addItem:self.eventNameItem];
    [section addItem:self.eventLocationItem];
    [section addItem:self.eventStartTimeItem];
    [section addItem:self.eventEndTimeItem];
    [section addItem:self.eventNoteItem];
    
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
        NSMutableArray *options = [[NSMutableArray alloc] initWithArray:@[@"Charles Chen", @"Fran Guo", @"Kosaki Onodera", @"Jessica Liu", @"Pearle Lun", @"Victoria Wang", @"James Wu", @"Angela Yeung"]];
        
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
@end
