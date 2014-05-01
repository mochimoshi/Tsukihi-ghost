//
//  GTChatTableViewCell.h
//  GetThere
//
//  Created by Alex Yuh-Rern Wang on 4/30/14.
//  Copyright (c) 2014 Chromatiqa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GTChatTableViewCell : UITableViewCell

@property (strong, nonatomic) UILabel *message;
@property (strong, nonatomic) UILabel *usernameLabel;
@property (strong, nonatomic) UILabel *timestampLabel;
@property (strong, nonatomic) UIImageView *locationImageView;

- (void)repositionCellItems;

@end
