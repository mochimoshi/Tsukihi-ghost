//
//  GTChatService.h
//  GetThere
//
//  Created by Angela Yeung on 5/13/14.
//  Copyright (c) 2014 Chromatiqa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GTChatService : NSObject

typedef void (^GTSuccessBlock)(id responseObject);
typedef void (^GTFailureBlock)(NSError *error);

+ (GTChatService *)sharedChatService;

- (void) getChatSinceID:(NSString *)chatID event:(NSString *)event success:(GTSuccessBlock)success failure:(GTFailureBlock)failure;
- (void) getChatMaxID:(NSString *)chatID event:(NSString *)event success:(GTSuccessBlock)success failure:(GTFailureBlock)failure;
- (void) getChatSinceID:(NSString *)chatID maxID: (NSString *)maxID event:(NSString *)event success:(GTSuccessBlock)success failure:(GTFailureBlock)failure;

@end
