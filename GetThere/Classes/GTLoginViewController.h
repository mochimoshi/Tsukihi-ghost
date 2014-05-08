//
//  GTLoginViewController.h
//  GetThere
//
//  Created by Alex Yuh-Rern Wang on 4/29/14.
//  Copyright (c) 2014 Chromatiqa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AFNetworking/AFNetworking.h>
#import "GTChatViewController.h"

@interface GTLoginViewController : UIViewController

/*@property (strong, nonatomic) NSDictionary* userInfo;
@property (strong, nonatomic) NSMutableString *userId;*/

extern NSDictionary* global_userInfo;
extern NSMutableString *global_userId;

@end
