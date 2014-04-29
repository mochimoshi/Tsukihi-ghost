//
//  GTEventMenuTableViewCell.m
//  GetThere
//
//  Created by Alex Yuh-Rern Wang on 4/28/14.
//  Copyright (c) 2014 Chromatiqa. All rights reserved.
//

#import "GTEventMenuTableViewCell.h"

@implementation GTEventMenuTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
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
