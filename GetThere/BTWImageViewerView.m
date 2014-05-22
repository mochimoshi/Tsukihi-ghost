//
//  BTWImageViewerView.m
//  BitTweet
//
//  Created by Alex Yuh-Rern Wang on 12/26/13.
//  Copyright (c) 2013 Chromatiqa. All rights reserved.
//

#import "BTWImageViewerView.h"

#import <SDWebImage/UIImageView+WebCache.h>

@interface BTWImageViewerView()<UIScrollViewDelegate>

@property (strong, nonatomic) UIImageView *background;
@property (strong, nonatomic) UIImageView *mainImageView;
@property (strong, nonatomic) UIScrollView *scrollView;

@property (assign, nonatomic) CGFloat scale;

@end

@implementation BTWImageViewerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.background = [[UIImageView alloc] initWithFrame:CGRectMake(-20, -20, CGRectGetWidth(self.frame) * 1.3, CGRectGetHeight(self.frame) * 1.3)];
        [self.background setContentMode:UIViewContentModeScaleAspectFill];
        [self addSubview:self.background];
        
        self.scrollView = [[UIScrollView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        [self.scrollView setScrollsToTop:NO];
        [self.scrollView setBackgroundColor:[UIColor clearColor]];
        [self.scrollView setBounces:YES];
        [self.scrollView setDelegate:self];
        [self addSubview:self.scrollView];
        
        UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [doneButton setTitle:NSLocalizedString(@"Dismiss", nil) forState:UIControlStateNormal];
        [doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [doneButton setBackgroundColor:[UIColor colorWithWhite:0.1 alpha:0.2]];
        [doneButton addTarget:self action:@selector(animateOut) forControlEvents:UIControlEventTouchUpInside];
        [doneButton sizeToFit];
        
        CGRect doneFrame = [doneButton frame];
        doneFrame.origin.x = CGRectGetWidth(self.frame) - CGRectGetWidth(doneFrame) - kHorizontalMargin;
        doneFrame.origin.y = kVerticalMargin;
        [doneButton setFrame:doneFrame];
        
        self.mainImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.scrollView addSubview:self.mainImageView];
        
        [self addSubview:doneButton];
        
        UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewDoubleTapped:)];
        doubleTapRecognizer.numberOfTapsRequired = 2;
        doubleTapRecognizer.numberOfTouchesRequired = 1;
        [self.scrollView addGestureRecognizer:doubleTapRecognizer];
        
        UITapGestureRecognizer *doubleTouchRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewDoubleTouched:)];
        doubleTouchRecognizer.numberOfTapsRequired = 2;
        doubleTouchRecognizer.numberOfTouchesRequired = 2;
        [self.scrollView addGestureRecognizer:doubleTouchRecognizer];
        
        [self setAlpha:0.0];
    }
    return self;
}

- (void)dealloc
{
    [self.scrollView setDelegate:nil];
}

- (void)animateInWithBackgroundImage:(UIImage *)image mainImage:(UIImage *)mainImage
{
    [self.background setImage:image];
    
    CGFloat maxSide = MAX(mainImage.size.width, mainImage.size.height);
    self.scale = MIN((CGRectGetWidth(self.frame) - kHorizontalMargin) / maxSide, 1);
    
    [self.scrollView setContentSize:CGSizeMake(MAX(mainImage.size.width, CGRectGetWidth(self.frame)), MAX(mainImage.size.height, CGRectGetHeight(self.frame)))];
    
    [self.mainImageView setFrame:CGRectMake(0, 0, mainImage.size.width, mainImage.size.height)];
    [self.mainImageView setImage:mainImage];
    
    [self.scrollView setMinimumZoomScale:self.scale];
    [self.scrollView setMaximumZoomScale:1.3];
    [self.scrollView setZoomScale:self.scale];
    [self centerScrollViewContents];
    
    [self animateIn];
}

- (BOOL)animateInWithBackgroundImage:(UIImage *)image mainImageUrl:(NSURL *)imageURL
{
    [self.background setImage:image];
    
    __block BOOL isSuccessful = YES;
    __weak BTWImageViewerView *weakSelf = self;
    
    [self.mainImageView setImageWithURL:imageURL completed:^(UIImage *mainImage, NSError *error, SDImageCacheType cacheType) {
        if(mainImage) {
            CGFloat maxSide = MAX(mainImage.size.width, mainImage.size.height);
            weakSelf.scale = MIN((CGRectGetWidth(weakSelf.frame) - kHorizontalMargin) / maxSide, 1);
            
            [weakSelf.scrollView setContentSize:CGSizeMake(MAX(mainImage.size.width, CGRectGetWidth(weakSelf.frame)), MAX(mainImage.size.height, CGRectGetHeight(weakSelf.frame)))];
            
            [weakSelf.mainImageView setFrame:CGRectMake(0, 0, mainImage.size.width, mainImage.size.height)];
            
            [weakSelf.scrollView setMinimumZoomScale:weakSelf.scale];
            [weakSelf.scrollView setMaximumZoomScale:1.3];
            [weakSelf.scrollView setZoomScale:weakSelf.scale];
            [weakSelf centerScrollViewContents];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf animateIn];
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf animateOut];
                weakSelf.failureBlock(YES);
            });
            isSuccessful = NO;
        }
    }];
    return isSuccessful;
}

- (void)animateIn
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    [UIView animateWithDuration:0.3 animations:^{
        [self setAlpha:1.0];
    } completion:^(BOOL finished) {
        [self setHidden:NO];
    }];
}

- (void)animateOut
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    self.dismissBlock(YES);
    [UIView animateWithDuration:0.3 animations:^{
        [self setAlpha:0.0];
    } completion:^(BOOL finished) {
        [self.scrollView setZoomScale:1];
        [self.scrollView setMinimumZoomScale:1];
        [self.scrollView setMaximumZoomScale:1.3];
        
        [self setHidden:YES];
    }];
}

- (void)centerScrollViewContents {
    CGSize boundsSize = self.scrollView.bounds.size;
    CGRect contentsFrame = self.mainImageView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    self.mainImageView.frame = contentsFrame;
}

#pragma mark - Scrollview Delegates

- (void)scrollViewDoubleTapped:(UITapGestureRecognizer*)recognizer {
    // 1
    CGPoint pointInView = [recognizer locationInView:self.mainImageView];
    
    // 2
    CGFloat newZoomScale = self.scrollView.zoomScale * 1.5f;
    newZoomScale = MIN(newZoomScale, self.scrollView.maximumZoomScale);
    
    // 3
    CGSize scrollViewSize = self.scrollView.bounds.size;
    
    CGFloat w = scrollViewSize.width / newZoomScale;
    CGFloat h = scrollViewSize.height / newZoomScale;
    CGFloat x = pointInView.x - (w / 2.0f);
    CGFloat y = pointInView.y - (h / 2.0f);
    
    CGRect rectToZoomTo = CGRectMake(x, y, w, h);
    
    // 4
    [self.scrollView zoomToRect:rectToZoomTo animated:YES];
}

- (void)scrollViewDoubleTouched:(UITapGestureRecognizer*)recognizer {
    CGFloat newZoomScale = self.scrollView.zoomScale * 0.67f;
    newZoomScale = MAX(newZoomScale, self.scrollView.minimumZoomScale);
    
    [self.scrollView setZoomScale:newZoomScale animated:YES];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.mainImageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    // The scroll view has zoomed, so we need to re-center the contents
    [self centerScrollViewContents];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
