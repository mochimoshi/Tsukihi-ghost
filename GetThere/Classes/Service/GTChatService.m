//
//  GTChatService.m
//  GetThere
//
//  Created by Angela Yeung on 5/13/14.
//  Copyright (c) 2014 Chromatiqa. All rights reserved.
//

#import "GTChatService.h"

#import <AFNetworking/AFNetworking.h>

@implementation GTChatService

+ (GTChatService *)sharedChatService {
    static GTChatService *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[[self class]alloc]init];
    });
    return sharedInstance;
}

- (void)getChatSinceID:(NSString *)chatID event:(NSString *)event success:(GTSuccessBlock)success failure:(GTFailureBlock)failure
{
    
}

- (void)getChatMaxID:(NSString *)chatID event:(NSString *)event success:(GTSuccessBlock)success failure:(GTFailureBlock)failure
{
    
}

- (void)getChatSinceID:(NSString *)chatID maxID:(NSString *)maxID event:(NSString *)event success:(GTSuccessBlock)success failure:(GTFailureBlock)failure
{
    
}

@end
