//
//  GTUtilities.m
//  GetThere
//
//  Created by Alex Yuh-Rern Wang on 4/30/14.
//  Copyright (c) 2014 Chromatiqa. All rights reserved.
//

#import "GTUtilities.h"

@implementation GTUtilities

+ (NSString *)formattedDateStringFromDate:(NSDate *)date
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setLocale:[NSLocale localeWithLocaleIdentifier:[[NSLocale preferredLanguages] firstObject]]];
    [dateFormat setTimeStyle:NSDateFormatterShortStyle];
    [dateFormat setDateStyle:NSDateFormatterLongStyle];
    [dateFormat setTimeZone:[NSTimeZone systemTimeZone]];
    return [dateFormat stringFromDate:date];
}

@end
