//
//  BTWImageViewerView.h
//  BitTweet
//
//  Created by Alex Yuh-Rern Wang on 12/26/13.
//  Copyright (c) 2013 Chromatiqa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTConstants.h"

@interface BTWImageViewerView : UIView

@property (copy, nonatomic) GTCompletionBlock dismissBlock;
@property (copy, nonatomic) GTCompletionBlock failureBlock;

- (BOOL)animateInWithBackgroundImage:(UIImage *)image mainImageUrl:(NSURL *)imageURL;
- (void)animateInWithBackgroundImage:(UIImage *)image mainImage:(UIImage *)mainImage;

@end
