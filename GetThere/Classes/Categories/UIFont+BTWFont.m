//
//  UIFont+BTWFont.m
//  BitTweet
//
//  Created by Alex Yuh-Rern Wang on 12/16/13.
//  Copyright (c) 2013 Chromatiqa. All rights reserved.
//

#import "UIFont+BTWFont.h"

@implementation UIFont (BTWFont)

+ (UIFont *)mediumHelveticaWithSize:(CGFloat)size {
    return [UIFont fontWithName:@"HelveticaNeue-Medium" size:size];
}

+ (UIFont *)helveticaWithSize:(CGFloat)size {
    return [UIFont fontWithName:@"HelveticaNeue" size:size];
}

+ (UIFont *)lightHelveticaWithSize:(CGFloat)size {
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:size];
}

+ (UIFont *)lightItalicsHelveticaWithSize:(CGFloat)size
{
    return [UIFont fontWithName:@"HelveticaNeue-LightItalic" size:size];
}

+ (UIFont *)thinHelveticaWithSize:(CGFloat)size {
    return [UIFont fontWithName:@"HelveticaNeue-Thin" size:size];
}

+ (UIFont *)ultraLightHelveticaWithSize:(CGFloat)size {
    return [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:size];
}

@end
