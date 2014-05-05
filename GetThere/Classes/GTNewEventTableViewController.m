//
//  GTNewEventTableViewController.m
//  GetThere
//
//  Created by Alex Yuh-Rern Wang on 5/4/14.
//  Copyright (c) 2014 Chromatiqa. All rights reserved.
//

#import "GTNewEventTableViewController.h"
#import <RETableViewManager/RETableViewManager.h>

@interface GTNewEventTableViewController ()<RETableViewManagerDelegate>

@property (strong, nonatomic) RETableViewManager *manager;
@property (strong, nonatomic) RETableViewSection *eventInfoSection;
@property (strong, nonatomic) RETableViewSection *eventButton;

@property (strong, nonatomic) RETextItem *eventNameItem;
@property (strong, nonatomic) RETextItem *eventLocationItem;
@property (strong, nonatomic) REDateTimeItem *eventStartTimeItem;
@property (strong, nonatomic) REDateTimeItem *eventEndTimeItem;
@property (strong, nonatomic) RELongTextItem *eventNoteItem;
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
    
    self.eventNoteItem = [RELongTextItem itemWithValue:nil placeholder:@"Remember to finish milestone 4"];
    self.eventNoteItem.cellHeight = 88;
    
    
    [section addItem:self.eventNameItem];
    [section addItem:self.eventLocationItem];
    [section addItem:self.eventStartTimeItem];
    [section addItem:self.eventEndTimeItem];
    [section addItem:self.eventNoteItem];
    
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
