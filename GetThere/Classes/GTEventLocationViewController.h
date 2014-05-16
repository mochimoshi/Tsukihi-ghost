//
//  GTEventLocationViewController.h
//  GetThere
//
//  Created by Alex Yuh-Rern Wang on 5/16/14.
//  Copyright (c) 2014 Chromatiqa. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MapKit/MapKit.h>

typedef void (^GTLocationCompletionBlock)();

@protocol GTEventLocatorDelegate <NSObject>

@end

@interface GTEventLocationViewController : UIViewController

@property (assign, nonatomic) id<GTEventLocatorDelegate> delegate;
@property (copy, nonatomic) GTLocationCompletionBlock completionBlock;
@property (assign, nonatomic) CLLocationCoordinate2D center;

@end
