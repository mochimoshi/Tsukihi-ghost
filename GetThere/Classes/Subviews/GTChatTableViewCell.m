//
//  GTChatTableViewCell.m
//  GetThere
//
//  Created by Alex Yuh-Rern Wang on 4/30/14.
//  Copyright (c) 2014 Chromatiqa. All rights reserved.
//

#import "GTChatTableViewCell.h"

#import "GTConstants.h"

#import "UIFont+BTWFont.h"
#import "UIColor+BTWColor.h"
#import "UILabel+GTLabel.h"

@implementation GTChatTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        self.usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(kCellMargin, kCellMargin, CGRectGetWidth(self.frame) - 2 * kCellMargin, kLineHeight)];
        [self.usernameLabel setFont:[UIFont lightHelveticaWithSize:14.0]];
        [self.contentView addSubview:self.usernameLabel];
        
        self.message = [[UILabel alloc] initWithFrame:CGRectMake(kCellMargin, kCellMargin, CGRectGetWidth(self.frame) - 2 * kCellMargin, kLineHeight)];
        [self.message setFont:[UIFont lightHelveticaWithSize:12.0]];
        [self.message setLineBreakMode:NSLineBreakByWordWrapping];
        [self.message setNumberOfLines:0];
        [self.contentView addSubview:self.message];
        
        self.timestampLabel = [[UILabel alloc] initWithFrame:CGRectMake(kCellMargin, kCellMargin, CGRectGetWidth(self.frame) - 2 * kCellMargin, kLineHeight)];
        [self.timestampLabel setFont:[UIFont lightHelveticaWithSize:10.0]];
        [self.timestampLabel setTextColor:[UIColor secondaryBlackColor]];
        [self.contentView addSubview:self.timestampLabel];
        
        self.locationImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kCellMargin, kCellMargin, kChatImageDimension, kChatImageDimension)];
        [self.locationImageView setContentMode:UIViewContentModeScaleAspectFill];
        [self.locationImageView setClipsToBounds:YES];
        [self.contentView addSubview:self.locationImageView];
    }
    return self;
}

- (void)repositionCellItems
{
    [self.message sizeToFitWithExpectedWidth:CGRectGetWidth(self.frame) - 2 * kCellMargin];
    
    CGFloat expectedY = 0;
    
    if(!self.locationImageView.image) {
        CGRect messageFrame = self.message.frame;
        messageFrame.origin.y = CGRectGetMaxY(self.usernameLabel.frame) + kPadding;
        [self.message setFrame: messageFrame];
        
        CGRect imageFrame = self.locationImageView.frame;
        imageFrame.size.height = 0;
        [self.locationImageView setFrame:imageFrame];
        
        expectedY = CGRectGetMaxY(self.message.frame);
    }
    else {
        CGRect messageFrame = self.message.frame;
        messageFrame.size.height = 0;
        [self.message setFrame:messageFrame];
        
        CGRect imageFrame = self.locationImageView.frame;
        imageFrame.origin.y = CGRectGetMaxY(self.usernameLabel.frame) + kPadding;
        imageFrame.size.height = kChatImageDimension;
        [self.locationImageView setFrame:imageFrame];
        
        expectedY = CGRectGetMaxY(self.locationImageView.frame);
    }
    CGRect timestampFrame = self.timestampLabel.frame;
    timestampFrame.origin.y = expectedY + kPadding;
    [self.timestampLabel setFrame:timestampFrame];
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
