//
//  UILabel+GTLabel.m
//  GetThere
//
//  Created by Alex Yuh-Rern Wang on 4/30/14.
//  Copyright (c) 2014 Chromatiqa. All rights reserved.
//

#import "UILabel+GTLabel.h"

@implementation UILabel (GTLabel)

- (void)sizeToFitWithExpectedWidth:(CGFloat)width
{
    CGRect labelFrame = [self frame];
    labelFrame.size.width = width;
    [self setFrame:labelFrame];
    [self sizeToFit];
}

- (void)sizeToFitReexpandToWidth:(CGFloat)width
{
    [self sizeToFit];
    CGRect labelFrame = [self frame];
    labelFrame.size.width = width;
    [self setFrame:labelFrame];
}

@end
