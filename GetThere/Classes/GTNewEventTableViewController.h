//
//  GTNewEventTableViewController.h
//  GetThere
//
//  Created by Alex Yuh-Rern Wang on 5/4/14.
//  Copyright (c) 2014 Chromatiqa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@protocol GTNewEventDelegate <NSObject>

@end

@interface GTNewEventTableViewController : UITableViewController

@property (assign, nonatomic) id<GTNewEventDelegate> delegate;
@property (strong, nonatomic) NSString *selectedLocationName;
@property (strong, nonatomic) NSString *selectedLocationAddress;
@property (assign, nonatomic) CLLocationCoordinate2D selectedCoordinates;

@end
