//
//  GTUtilities.m
//  GetThere
//
//  Created by Alex Yuh-Rern Wang on 4/30/14.
//  Copyright (c) 2014 Chromatiqa. All rights reserved.
//

#import "GTUtilities.h"

@implementation GTUtilities

+ (NSString *)formattedDateStringFromDateString:(NSString *)dateString
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setLocale:[NSLocale localeWithLocaleIdentifier:@"en-us"]];
    [dateFormat setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [dateFormat setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS'Z'"];
    return [GTUtilities formattedDateStringFromDate:[dateFormat dateFromString:dateString]];
}

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
