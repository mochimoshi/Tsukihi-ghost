//
//  BTWTweetComposeView.h
//  BitTweet
//
//  Created by Alex Yuh-Rern Wang on 12/20/13.
//  Copyright (c) 2013 Chromatiqa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTConstants.h"

@protocol BTWTweetComposeViewDelegate <NSObject>

@end

@interface BTWTweetComposeView : UIView

@property (copy, nonatomic) GTCompletionBlock completionBlock;
@property (copy, nonatomic) GTCompletionBlock earlyCompletionBlock;
@property (assign, nonatomic) id<BTWTweetComposeViewDelegate> delegate;

@property (strong, nonatomic) UIButton *draftsButton;

@property (strong, nonatomic) NSString *replyID;

- (void) setInitialText:(NSString *)initialText;
- (void) setSelectedRange:(NSRange)range;
- (void) setBlurredBackground:(UIImage *)background;
- (void) animateIn;
- (void) setScrollToTop:(BOOL)scrolls;
- (void) setReplyTo:(NSString *)tweet;

@end
