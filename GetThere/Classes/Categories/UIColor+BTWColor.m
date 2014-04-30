//
//  UIColor+BTWColor.h
//  BitTweet
//
//  Created by Alex Yuh-Rern Wang on 12/19/13.
//  Copyright (c) 2013 Chromatiqa. All rights reserved.
//

#import "UIColor+BTWColor.h"

@implementation UIColor (BTWColor)

+ (UIColor *)systemColor
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    return [button titleColorForState:UIControlStateNormal];
}

+ (UIColor *)goldColor
{
    return [UIColor colorWithRed:245.0/255.0 green:205.0/255.0 blue:0.0 alpha:1.0];
}

+ (UIColor *)retweetGreen
{
    return [UIColor colorWithRed:0.376 green:0.60 blue:0.157 alpha:1.0];
}

+ (UIColor *)lightSystemColor
{
    return [UIColor colorWithRed:232.0/255.0 green:243.0/255.0 blue:1.0 alpha:0.7];
}

+ (UIColor *)importantBlackColor
{
    return [UIColor colorWithWhite:0/255.0 alpha:1.0];
}

+ (UIColor *)secondaryBlackColor
{
    return [UIColor colorWithWhite:51.0/255.0 alpha:1.0];
}

+ (UIColor *)tertiaryBlackColor
{
    return [UIColor colorWithWhite:102.0/255.0 alpha:1.0];
}

+ (UIColor *)darkBackgroundColor
{
    return [UIColor colorWithWhite:54.0/255.0 alpha:1.0];
}

+ (UIColor *)importantWhiteColor
{
    return [UIColor colorWithWhite:221.0/255.0 alpha:1.0];
}

+ (UIColor *)secondaryWhiteColor
{
    return [UIColor colorWithWhite:187.0/255.0 alpha:1.0];
}

+ (UIColor *)tertiaryWhiteColor
{
    return [UIColor colorWithWhite:170.0/255.0 alpha:1.0];
}

@end
