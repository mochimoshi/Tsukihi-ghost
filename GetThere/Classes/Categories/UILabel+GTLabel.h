//
//  UILabel+GTLabel.h
//  GetThere
//
//  Created by Alex Yuh-Rern Wang on 4/30/14.
//  Copyright (c) 2014 Chromatiqa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (GTLabel)

- (void)sizeToFitWithExpectedWidth:(CGFloat)width;
- (void)sizeToFitReexpandToWidth:(CGFloat)width;

@end
