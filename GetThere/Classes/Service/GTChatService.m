//
//  GTChatService.m
//  GetThere
//
//  Created by Angela Yeung on 5/13/14.
//  Copyright (c) 2014 Chromatiqa. All rights reserved.
//

#import "GTChatService.h"
#import "GTConstants.h"

#import <AFNetworking/AFNetworking.h>

@implementation GTChatService

#define kMessageLocation @"http://tsukihi.org/backtier/messages/create"
#define kPhotoLocation @"http://tsukihi.org/backtier/messages/create"

+ (GTChatService *)sharedChatService {
    static GTChatService *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[[self class]alloc]init];
    });
    return sharedInstance;
}

- (void)pushStatus:(NSString *)status event:(NSInteger)eventID success:(GTSuccessBlock)success failure:(GTFailureBlock)failure
{
    NSNumber *userID = [[NSUserDefaults standardUserDefaults] objectForKey:@"userID"];
    NSDictionary *params = @{@"user_id": userID,
                             @"text": status,
                             @"event_id": [[NSUserDefaults standardUserDefaults] objectForKey:@"eventID"]};
    AFHTTPRequestOperationManager *httpManager = [AFHTTPRequestOperationManager manager];
    [httpManager GET:kMessageLocation parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void)pushStatus:(NSString *)status image:(UIImage *)image event:(NSInteger)eventID location:(CLLocationCoordinate2D)coordinate success:(GTSuccessBlock)success failure:(GTFailureBlock)failure
{
    if(image) {
        NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
        NSNumber *userID = [[NSUserDefaults standardUserDefaults] objectForKey:@"userID"];
        NSDictionary *params = @{@"user_id": userID,
                                 @"event_id": [[NSUserDefaults standardUserDefaults] objectForKey:@"eventID"],
                                 @"latitude": [NSNumber numberWithDouble:coordinate.latitude],
                                 @"longitude": [NSNumber numberWithDouble:coordinate.longitude]};
        AFHTTPRequestOperationManager *httpManager = [AFHTTPRequestOperationManager manager];
        [httpManager POST:kPhotoLocation parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileData:imageData name:@"filename" fileName:@"photo_" mimeType:@"image/jpeg"];
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            // NSLog(@"JSON: %@", responseObject);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
    }
}

@end
