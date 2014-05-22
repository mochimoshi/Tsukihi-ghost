//
//  GTNewEventTableViewController.h
//  GetThere
//
//  Created by Alex Yuh-Rern Wang on 5/4/14.
//  Copyright (c) 2014 Chromatiqa. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GTNewEventDelegate <NSObject>

@end

@interface GTNewEventTableViewController : UITableViewController

@property (assign, nonatomic) id<GTNewEventDelegate> delegate;

@end
