//
//  GTConstants.h
//  GetThere
//
//  Created by Alex Yuh-Rern Wang on 4/29/14.
//  Copyright (c) 2014 Chromatiqa. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^GTCompletionBlock)(BOOL success);

@interface GTConstants : NSObject

extern CGFloat kCellMargin;
extern CGFloat kHorizontalMargin;
extern CGFloat kVerticalMargin;

extern CGFloat kLineHeight;

extern CGFloat kPadding;

extern CGFloat kChatImageDimension;
extern CGFloat kMaxImageSize;

@end
