//
//  GTViewController.m
//  GetThere
//
//  Created by Alex on 4/27/14.
//  Copyright (c) 2014 Chromatiqa. All rights reserved.
//

#import "GTViewController.h"
#import "GTEventMenuTableViewCell.h"

#import "GTChatViewController.h"

#import <AFNetworking/AFNetworking.h>
#import "GTUtilities.h"

@interface GTViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *events;

@end

@implementation GTViewController

#define kUserEventsLocation @"http://tsukihi.org/backtier/users/get_events"

#pragma mark - Setup

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.title = @"Events";
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self getEvents];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getEvents
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *params = @{@"user": @{@"id": [[NSUserDefaults standardUserDefaults] objectForKey:@"userID"]}};
    [manager GET:kUserEventsLocation parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if([responseObject isKindOfClass:[NSArray class]]) {
            self.events = responseObject;
            [self.tableView reloadData];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network error!" message:@"The server is unavailable at the moment. Sorry!" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
        [alert show];
    }];
}


- (IBAction)logout:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"userName"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"userID"];
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    // We only have one section in our table view.
    return 1;
}

- (NSInteger)tableView:(UITableView*)table numberOfRowsInSection:(NSInteger)section
{
    // This is the number of chat messages.
    return [self.events count];
}

- (UITableViewCell*)tableView:(UITableView*)table cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"eventCell";
    UITableViewCell *cell = [table dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *eventInfo = [self.events objectAtIndex:indexPath.row];
    NSString *start = [eventInfo objectForKey:@"start_time"];
    cell.textLabel.text = [eventInfo objectForKey:@"event_name"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Starts %@ @ %@", [GTUtilities formattedDateStringFromDateString:start], [eventInfo objectForKey:@"location"]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
    [self performSegueWithIdentifier:@"pushToChat" sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"pushToChat"]) {
        GTChatViewController *chatVC = segue.destinationViewController;
        NSDictionary *eventInfo = [self.events objectAtIndex:self.tableView.indexPathForSelectedRow.row];
        chatVC.eventID = [[eventInfo objectForKey:@"id"] integerValue];
    }
}

@end
