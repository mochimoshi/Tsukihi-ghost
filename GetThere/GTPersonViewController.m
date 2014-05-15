//
//  GTPersonViewController.m
//  GetThere
//
//  Created by Angela Yeung on 5/5/14.
//  Copyright (c) 2014 Chromatiqa. All rights reserved.
//

#import "GTPersonViewController.h"
#import "GTChatTableViewCell.h"
#import <CoreLocation/CoreLocation.h>

@interface GTPersonViewController ()

@property (weak, nonatomic) IBOutlet UILabel *personName;
@property (weak, nonatomic) IBOutlet UILabel *personInfo;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;


@end

@implementation GTPersonViewController

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
    [self.mapView setCenterCoordinate:self.centerCoordinate animated:YES];
    // Do any additional setup after loading the view from its nib.
    self.personName.text = self.userName;
    self.personInfo.text = @"Last seen at LOCATION";
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
