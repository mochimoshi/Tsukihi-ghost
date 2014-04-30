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


@interface GTViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *eventDetails;

@property (strong, nonatomic) NSArray *eventNames;

@end

@implementation GTViewController




#pragma mark - Setup

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.eventNames = @[@"TCS Night Market", @"Dinner with Mom", @"DMV Driving Test"];
    self.eventDetails = @[@"6:00PM Today-White Plaza, Stanford", @"8:00PM Tomorrow-Crepevine", @"10:00AM Thursday-Los Altos DMV"];
    self.title = @"Events";
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Text field handling

// This method is called when the user enters text in the text field.
// We add the chat message to our Firebase.


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    // We only have one section in our table view.
    return 1;
}

- (NSInteger)tableView:(UITableView*)table numberOfRowsInSection:(NSInteger)section
{
    // This is the number of chat messages.
    return [self.eventNames count];
}

- (UITableViewCell*)tableView:(UITableView*)table cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"eventCell";
    UITableViewCell *cell = [table dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    

    cell.textLabel.text = [self.eventNames objectAtIndex: indexPath.row];
    cell.detailTextLabel.text = [self.eventDetails objectAtIndex: indexPath.row];

    //static NSString *CellIdentifier = @"mentionsTweetCell";
    //GTEventMenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:index];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"pushToChat" sender:nil];
}

@end
