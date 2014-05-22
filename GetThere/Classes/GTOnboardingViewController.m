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
    
    UILabel *page1Description = [[UILabel alloc] initWithFrame:CGRectMake(kHorizontalMargin,
                                                                          CGRectGetMaxY(welcome.frame) + kPadding,
                                                                          CGRectGetWidth(self.view.frame) - 2 * kHorizontalMargin,
                                                                          kLineHeight)];
    [page1Description setText: NSLocalizedString(@"Meetup is about using microlocation sharing to meet and schedule activities with your friends conveniently!", nil)];
    [page1Description setNumberOfLines:0];
    [page1Description setLineBreakMode:NSLineBreakByWordWrapping];
    [page1Description setFont:[UIFont lightHelveticaWithSize:16]];
    [page1Description setTextColor:[UIColor whiteColor]];
    [page1Description sizeToFitReexpandToWidth:CGRectGetWidth(self.view.frame) - 2 * kHorizontalMargin];
    [self.scrollView addSubview:page1Description];
}

- (void)createSecondPage
{
    CGFloat offset = CGRectGetWidth(self.view.frame);
}

- (void)createThirdPage
{
    CGFloat offset = CGRectGetWidth(self.view.frame) * 2;
    
    UIButton *getStarted = [UIButton buttonWithType:UIButtonTypeSystem];
    [getStarted setTitle:NSLocalizedString(@"Let's start!", nil) forState:UIControlStateNormal];
    [getStarted setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [getStarted setBackgroundColor:[UIColor retweetGreen]];
    [getStarted setFrame:CGRectMake(offset + kHorizontalMargin,
                                    CGRectGetHeight(self.view.frame) - kVerticalMargin - 2 * kLineHeight,
                                    CGRectGetWidth(self.view.frame) - 2 * kHorizontalMargin,
                                    2 * kLineHeight)];
    [self.scrollView addSubview:getStarted];
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
