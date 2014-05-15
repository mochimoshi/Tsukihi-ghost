//
//  GTRegistrationTableViewController.m
//  GetThere
//
//  Created by Alex Yuh-Rern Wang on 5/15/14.
//  Copyright (c) 2014 Chromatiqa. All rights reserved.
//

#import "GTRegistrationTableViewController.h"

#import <RETableViewManager/RETableViewManager.h>
#import <RETableViewManager/RETableViewOptionsController.h>

@interface GTRegistrationTableViewController ()

@property (strong, nonatomic) RETableViewManager *manager;
@property (strong, nonatomic) RETableViewSection *userInfoSection;
@property (strong, nonatomic) RETableViewSection *userButton;

@property (strong, nonatomic) RETextItem *userNameItem;
@property (strong, nonatomic) RETextItem *userPhoneItem;
@property (strong, nonatomic) RETextItem *userEmailItem;
@property (strong, nonatomic) RETextItem *userPasswordItem;

@end

@implementation GTRegistrationTableViewController

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
    self.userInfoSection = [self buildUserInfoSection];
    self.userButton = [self buildButton];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (RETableViewSection *)buildUserInfoSection
{
    RETableViewSection *section = [RETableViewSection sectionWithHeaderTitle:@"User information"];
    [self.manager addSection:section];
    
    self.userNameItem = [RETextItem itemWithTitle:@"Name" value:nil placeholder:@"John Doe"];
    self.userPhoneItem = [RETextItem itemWithTitle:@"Phone" value:nil placeholder:@"15105551234"];
    self.userEmailItem = [RETextItem itemWithTitle:@"E-mail" value:nil placeholder:@"jdoe@example.cc"];
    self.userPasswordItem = [RETextItem itemWithTitle:@"Password" value:@"password"];
    [self.userPasswordItem setSecureTextEntry:YES];
    
    [section addItem:self.userNameItem];
    [section addItem:self.userPhoneItem];
    [section addItem:self.userEmailItem];
    [section addItem:self.userPasswordItem];
    
    return section;
}

- (RETableViewSection *)buildButton
{
    RETableViewSection *section = [RETableViewSection section];
    [self.manager addSection:section];
    
    RETableViewItem *buttonItem = [RETableViewItem itemWithTitle:@"Register!" accessoryType:UITableViewCellAccessoryNone selectionHandler:^(RETableViewItem *item) {
        item.title = @"Submitting...";
        [item reloadRowWithAnimation:UITableViewRowAnimationAutomatic];
        
//        NSDictionary *eventDictionary = @{@"user": @{@"user_id" : [[NSUserDefaults standardUserDefaults] valueForKey:@"userID"],
//                                                      @"event_name": self.eventNameItem.value,
//                                                      @"location": self.eventLocationItem.value,
//                                                      @"start_time": self.eventStartTimeItem.value,
//                                                      @"end_time": self.eventEndTimeItem.value,
//                                                      @"invitee_ids": @[@1, @2, @3],
//                                                      @"notes": self.eventNoteItem.value}};
//        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//        [manager GET:kNewEventURL parameters:eventDictionary success:^(AFHTTPRequestOperation *operation, id responseObject) {
//            [self dismissViewControllerAnimated:YES completion:nil];
//        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops! Network connectivity issue."
//                                                            message:@"The event cannot be submitted at the moment. Please try again shortly!"
//                                                           delegate:nil
//                                                  cancelButtonTitle:@"Okay"
//                                                  otherButtonTitles: nil];
//            [alert show];
//            NSLog(@"Error: %@", error.localizedDescription);
//            item.title = @"Create meetup!";
//            [item reloadRowWithAnimation:UITableViewRowAnimationAutomatic];
//        }];
    }];
    buttonItem.textAlignment = NSTextAlignmentCenter;
    [section addItem:buttonItem];
    
    RETableViewItem *cancelItem = [RETableViewItem itemWithTitle:@"Cancel" accessoryType:UITableViewCellAccessoryNone selectionHandler:^(RETableViewItem *item) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    [cancelItem setTextAlignment:NSTextAlignmentCenter];
    [section addItem:cancelItem];
    
    return section;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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
