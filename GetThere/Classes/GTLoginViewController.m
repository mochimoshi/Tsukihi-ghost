//
//  GTLoginViewController.m
//  GetThere
//
//  Created by Alex Yuh-Rern Wang on 4/29/14.
//  Copyright (c) 2014 Chromatiqa. All rights reserved.
//

#import "GTLoginViewController.h"
#import "GTOnboardingViewController.h"

@interface GTLoginViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (strong, nonatomic) AFHTTPRequestOperationManager *httpManager;


@end

@implementation GTLoginViewController

#define kLoginURL @"http://tsukihi.org/backtier/users/login"

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
    [self.nameField setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:@"Username"
                                                                             attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:1.0 alpha:0.4]}]];
    
    [self.passwordField.layer setBorderColor:[UIColor colorWithWhite:1.0 alpha:0.4].CGColor];
    [self.passwordField.layer setBorderWidth:1.0];
    [self.passwordField.layer setCornerRadius:4.0];
    [self.passwordField setAttributedPlaceholder:[[NSAttributedString alloc] initWithString:@"Password"
                                                                             attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:1.0 alpha:0.4]}]];
    if (self.httpManager == nil) {
         self.httpManager = [AFHTTPRequestOperationManager manager];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"userID"]) {
        [self performSegueWithIdentifier:@"loginModalSegue" sender:nil];
        return;
    }
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"])
    {
        // app already launched
    }
    else
    {
        
        GTOnboardingViewController *onboard = [[GTOnboardingViewController alloc] init];
        [self presentViewController:onboard animated:YES completion:nil];
        // This is the first launch ever
    }
}

- (IBAction)didTapLogin:(id)sender
{
    [self sendLoginQuery];
}
            
- (void)setUserInfo
{
    [self.nameField setText:@""];
    [self.passwordField setText:@""];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    [self performSegueWithIdentifier:@"loginModalSegue" sender:nil];
}


- (void)sendLoginQuery
{
    if ([self.nameField.text length] > 0) {
        NSDictionary *params = @{@"user": @{@"user_name": [self.nameField.text lowercaseString], @"password": self.passwordField.text}};
        [self.httpManager GET:kLoginURL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"JSON: %@", responseObject);
            [[NSUserDefaults standardUserDefaults] setValue:[[responseObject objectForKey:@"user"] objectForKey: @"user_name"] forKey:@"userName"];
            [[NSUserDefaults standardUserDefaults] setValue:[[responseObject objectForKey:@"user"] objectForKey:@"id"] forKey:@"userID"];
            [self setUserInfo];
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
             (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                            message:@"Username / password is incorrect."
                                                           delegate:nil
                                                  cancelButtonTitle:@"Okay"
                                                  otherButtonTitles:nil];
            [alert show];
        }];
    }
}

- (IBAction)resignResponder:(id)sender
{
    [self.nameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
}

#pragma mark - TextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField*)aTextField
{
    [aTextField resignFirstResponder];
    
    [self didTapLogin:nil];
    return NO;
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
