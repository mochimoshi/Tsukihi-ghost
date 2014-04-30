//
//  GTViewController.m
//  GetThere
//
//  Created by Alex on 4/27/14.
//  Copyright (c) 2014 Chromatiqa. All rights reserved.
//

#import "GTViewController.h"
#import "GTEventMenuTableViewCell.h"



//@interface GTViewController ()<UITableViewDataSource, UITableViewDelegate>

//@property (weak, nonatomic) IBOutlet UITableView *tableView;

//@end

@implementation GTViewController

@synthesize nameField;
@synthesize textField;
@synthesize tableView;

#pragma mark - Setup

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Text field handling
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
    return [self.chat count];
}

- (UITableViewCell*)tableView:(UITableView*)table cellForRowAtIndexPath:(NSIndexPath *)index
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [table dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary* chatMessage = [self.chat objectAtIndex:index.row];
    if (chatMessage != nil) {
        cell.textLabel.text = chatMessage[@"text"];
        cell.detailTextLabel.text = chatMessage[@"name"];
    }
    //static NSString *CellIdentifier = @"mentionsTweetCell";
    //GTEventMenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:index];
    
    return cell;
}


// This method will be called when the user touches on the tableView, at
// which point we will hide the keyboard (if open). This method is called
// because UITouchTableView.m calls nextResponder in its touch handler.
- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    if ([textField isFirstResponder]) {
        [textField resignFirstResponder];
    }
}

@end
