//
//  GTPersonViewController.h
//  GetThere
//
//  Created by Angela Yeung on 5/5/14.
//  Copyright (c) 2014 Chromatiqa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface GTPersonViewController : UIViewController

@property (assign, nonatomic) CLLocationCoordinate2D centerCoordinate;
@property (strong, nonatomic) NSString *userName;

@end
