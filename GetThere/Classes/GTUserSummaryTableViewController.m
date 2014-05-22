//
//  GTUserSummaryTableViewController.m
//  GetThere
//
//  Created by Alex Yuh-Rern Wang on 5/22/14.
//  Copyright (c) 2014 Chromatiqa. All rights reserved.
//

#import "GTUserSummaryTableViewController.h"

#import <RETableViewManager/RETableViewManager.h>
#import <RETableViewManager/RETableViewOptionsController.h>

@interface GTUserSummaryTableViewController ()<RETableViewManagerDelegate>

@end

@implementation GTUserSummaryTableViewController

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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
