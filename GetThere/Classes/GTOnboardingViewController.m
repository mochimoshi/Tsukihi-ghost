//
//  GTOnboardingViewController.m
//  GetThere
//
//  Created by Alex Yuh-Rern Wang on 5/22/14.
//  Copyright (c) 2014 Chromatiqa. All rights reserved.
//

#import "GTOnboardingViewController.h"

#import "UIFont+BTWFont.h"
#import "UILabel+GTLabel.h"
#import "UIColor+BTWColor.h"
#import "GTConstants.h"

@interface GTOnboardingViewController ()

@property (strong, nonatomic) UIScrollView *scrollView;

@end

@implementation GTOnboardingViewController

static const NSInteger kNumberOfPages = 3;
static const CGFloat kStatusBarHeight = 20;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupViews];
    [self createFirstPage];
    [self createSecondPage];
    [self createThirdPage];
}

- (void)setupViews
{
    CGRect boundFrames = [[UIScreen mainScreen] bounds];
    self.scrollView = [[UIScrollView alloc] initWithFrame:boundFrames];
    [self.scrollView setBackgroundColor:[UIColor blackColor]];
    
    [self.scrollView setContentSize:CGSizeMake(CGRectGetWidth(boundFrames) * kNumberOfPages, CGRectGetHeight(boundFrames))];
    [self.scrollView setPagingEnabled:YES];
    [self.view addSubview:self.scrollView];
}

- (void)createFirstPage
{
    UILabel *welcome = [[UILabel alloc] initWithFrame:CGRectMake(0, kStatusBarHeight, CGRectGetWidth(self.view.frame), kLineHeight)];
    [welcome setText:NSLocalizedString(@"Hello!", nil)];
    [welcome setFont:[UIFont thinHelveticaWithSize:32]];
    [welcome setTextAlignment:NSTextAlignmentCenter];
    [welcome setTextColor:[UIColor whiteColor]];
    [welcome sizeToFitReexpandToWidth:CGRectGetWidth(self.view.frame)];
    [self.scrollView addSubview:welcome];
    
    UIImageView *p1Image = [[UIImageView alloc] initWithFrame:CGRectMake(kHorizontalMargin,
                                                                         CGRectGetMaxY(welcome.frame) + kPadding,
                                                                         CGRectGetWidth(self.view.frame) - 2 * kHorizontalMargin,
                                                                         CGRectGetWidth(self.view.frame) - 2 * kHorizontalMargin)];
    [p1Image setImage:[UIImage imageNamed:@"Onboarding_P1.png"]];
    [p1Image setContentMode:UIViewContentModeScaleAspectFit];
    [self.scrollView addSubview:p1Image];
    
    UILabel *page1Description = [[UILabel alloc] initWithFrame:CGRectMake(kHorizontalMargin,
                                                                          CGRectGetMaxY(p1Image.frame) + kPadding,
                                                                          CGRectGetWidth(self.view.frame) - 2 * kHorizontalMargin,
                                                                          kLineHeight)];
    [page1Description setText: NSLocalizedString(@"Meetup is about using microlocation sharing to meet and schedule activities with your friends conveniently!", nil)];
    [page1Description setNumberOfLines:0];
    [page1Description setLineBreakMode:NSLineBreakByWordWrapping];
    [page1Description setFont:[UIFont thinHelveticaWithSize:20]];
    [page1Description setTextColor:[UIColor whiteColor]];
    [page1Description setTextAlignment:NSTextAlignmentCenter];
    [page1Description sizeToFitReexpandToWidth:CGRectGetWidth(self.view.frame) - 2 * kHorizontalMargin];
    [self.scrollView addSubview:page1Description];
}

- (void)createSecondPage
{
    CGFloat offset = CGRectGetWidth(self.view.frame);
    
    UILabel *welcome = [[UILabel alloc] initWithFrame:CGRectMake(offset, kStatusBarHeight, CGRectGetWidth(self.view.frame), kLineHeight)];
    [welcome setText:NSLocalizedString(@"Check statuses quickly", nil)];
    [welcome setFont:[UIFont thinHelveticaWithSize:32]];
    [welcome setTextAlignment:NSTextAlignmentCenter];
    [welcome setTextColor:[UIColor whiteColor]];
    [welcome sizeToFitReexpandToWidth:CGRectGetWidth(self.view.frame)];
    [self.scrollView addSubview:welcome];
    
    UIImageView *p2Image = [[UIImageView alloc] initWithFrame:CGRectMake(kHorizontalMargin + offset,
                                                                         CGRectGetMaxY(welcome.frame) + kPadding,
                                                                         CGRectGetWidth(self.view.frame) - 2 * kHorizontalMargin,
                                                                         CGRectGetWidth(self.view.frame) - 2 * kHorizontalMargin)];
    [p2Image setImage:[UIImage imageNamed:@"Onboarding_P2.png"]];
    [p2Image setContentMode:UIViewContentModeScaleAspectFit];
    [self.scrollView addSubview:p2Image];
    
    UILabel *page2Description = [[UILabel alloc] initWithFrame:CGRectMake(kHorizontalMargin + offset,
                                                                          CGRectGetMaxY(p2Image.frame) + kPadding,
                                                                          CGRectGetWidth(self.view.frame) - 2 * kHorizontalMargin,
                                                                          kLineHeight)];
    [page2Description setText: NSLocalizedString(@"Check on the status of attendees along with their current location to estimate arrival times!", nil)];
    [page2Description setNumberOfLines:0];
    [page2Description setLineBreakMode:NSLineBreakByWordWrapping];
    [page2Description setFont:[UIFont thinHelveticaWithSize:20]];
    [page2Description setTextColor:[UIColor whiteColor]];
    [page2Description setTextAlignment:NSTextAlignmentCenter];
    [page2Description sizeToFitReexpandToWidth:CGRectGetWidth(self.view.frame) - 2 * kHorizontalMargin];
    [self.scrollView addSubview:page2Description];
}

- (void)createThirdPage
{
    CGFloat offset = CGRectGetWidth(self.view.frame) * 2;
    
    UILabel *welcome = [[UILabel alloc] initWithFrame:CGRectMake(offset, kStatusBarHeight, CGRectGetWidth(self.view.frame), kLineHeight)];
    [welcome setText:NSLocalizedString(@"Update your information", nil)];
    [welcome setFont:[UIFont thinHelveticaWithSize:32]];
    [welcome setTextAlignment:NSTextAlignmentCenter];
    [welcome setTextColor:[UIColor whiteColor]];
    [welcome sizeToFitReexpandToWidth:CGRectGetWidth(self.view.frame)];
    [self.scrollView addSubview:welcome];
    
    UIImageView *p3Image = [[UIImageView alloc] initWithFrame:CGRectMake(kHorizontalMargin + offset,
                                                                         CGRectGetMaxY(welcome.frame) + kPadding,
                                                                         CGRectGetWidth(self.view.frame) - 2 * kHorizontalMargin,
                                                                         CGRectGetWidth(self.view.frame) - 2 * kHorizontalMargin)];
    [p3Image setImage:[UIImage imageNamed:@"Onboarding_P3.png"]];
    [p3Image setContentMode:UIViewContentModeScaleAspectFit];
    [self.scrollView addSubview:p3Image];
    
    UILabel *page3Description = [[UILabel alloc] initWithFrame:CGRectMake(kHorizontalMargin + offset,
                                                                          CGRectGetMaxY(p3Image.frame) + kPadding,
                                                                          CGRectGetWidth(self.view.frame) - 2 * kHorizontalMargin,
                                                                          kLineHeight)];
    [page3Description setText: NSLocalizedString(@"Managing your meetup is fast and easy by tapping the actions button! Post photos to share exactly where you are, anytime.", nil)];
    [page3Description setNumberOfLines:0];
    [page3Description setLineBreakMode:NSLineBreakByWordWrapping];
    [page3Description setFont:[UIFont thinHelveticaWithSize:20]];
    [page3Description setTextColor:[UIColor whiteColor]];
    [page3Description setTextAlignment:NSTextAlignmentCenter];
    [page3Description sizeToFitReexpandToWidth:CGRectGetWidth(self.view.frame) - 2 * kHorizontalMargin];
    [self.scrollView addSubview:page3Description];
    
    UIButton *getStarted = [UIButton buttonWithType:UIButtonTypeSystem];
    [getStarted setTitle:NSLocalizedString(@"Let's start!", nil) forState:UIControlStateNormal];
    [getStarted setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [getStarted setBackgroundColor:[UIColor retweetGreen]];
    [getStarted setFrame:CGRectMake(offset + kHorizontalMargin,
                                    CGRectGetHeight(self.view.frame) - kVerticalMargin - 2 * kLineHeight,
                                    CGRectGetWidth(self.view.frame) - 2 * kHorizontalMargin,
                                    2 * kLineHeight)];
    [getStarted addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:getStarted];
}

- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
