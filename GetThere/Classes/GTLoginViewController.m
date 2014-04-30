//
//  GTLoginViewController.m
//  GetThere
//
//  Created by Alex Yuh-Rern Wang on 4/29/14.
//  Copyright (c) 2014 Chromatiqa. All rights reserved.
//

#import "GTLoginViewController.h"

@interface GTLoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *nameField;

@end

@implementation GTLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.nameField.layer setBorderColor:[UIColor colorWithWhite:1.0 alpha:0.4].CGColor];
    [self.nameField.layer setBorderWidth:1.0];
    [self.nameField.layer setCornerRadius:4.0];
    [self.nameField setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:@"Enter your name to continue"
                                                                             attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:1.0 alpha:0.4]}]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didTapLogin:(id)sender
{
    if([self.nameField.text length] > 0) {
        [[NSUserDefaults standardUserDefaults] setObject:self.nameField.text forKey:@"userName"];
        [self performSegueWithIdentifier:@"loginModalSegue" sender:nil];
        return;
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                    message:@"Please enter a name."
                                                   delegate:nil
                                          cancelButtonTitle:@"Okay!"
                                          otherButtonTitles:nil];
    [alert show];
}

- (IBAction)resignResponder:(id)sender
{
    [self.nameField resignFirstResponder];
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
