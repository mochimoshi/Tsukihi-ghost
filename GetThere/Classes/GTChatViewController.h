//
//  GTChatViewController.h
//  GetThere
//
//  Created by Angela Yeung on 4/29/14.
//  Copyright (c) 2014 Chromatiqa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface GTChatViewController : UIViewController

@property (assign, nonatomic) NSInteger eventID;

- (CLLocationCoordinate2D) getCurrentLocation;

@end
