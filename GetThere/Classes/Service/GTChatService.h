//
//  GTChatService.h
//  GetThere
//
//  Created by Angela Yeung on 5/13/14.
//  Copyright (c) 2014 Chromatiqa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface GTChatService : NSObject

typedef void (^GTSuccessBlock)(id responseObject);
typedef void (^GTFailureBlock)(NSError *error);

+ (GTChatService *)sharedChatService;

- (void) pushStatus:(NSString *)status event:(NSInteger)eventID success:(GTSuccessBlock)success failure:(GTFailureBlock)failure;
- (void) pushStatus:(NSString *)status image:(UIImage *)image event:(NSInteger)eventID location:(CLLocationCoordinate2D)coordinate success:(GTSuccessBlock)success failure:(GTFailureBlock)failure;

@end
