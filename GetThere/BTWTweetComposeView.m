//
//  BTWTweetComposeView.m
//  BitTweet
//
//  Created by Alex Yuh-Rern Wang on 12/20/13.
//  Copyright (c) 2013 Chromatiqa. All rights reserved.
//
//  Adapted for Meetup.
//

#import "BTWTweetComposeView.h"

#import "GTConstants.h"
#import "BTWImageViewerView.h"
#import "GTChatService.h"
#import "GTChatViewController.h"

#import "UIFont+BTWFont.h"
#import "UIImage+ImageEffects.h"
#import "UIImage+BTWImage.h"

@interface BTWTweetComposeView()<UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) UIImageView *backgroundImage;
@property (strong, nonatomic) UIImagePickerController *imagePicker;

@property (strong, nonatomic) BTWImageViewerView *imagePreviewer;

@property (strong, nonatomic) UIView *composeBackground;
@property (strong, nonatomic) UITextView *tweetArea;
@property (strong, nonatomic) UILabel *charactersLeft;
@property (strong, nonatomic) UIImage *attachedImage;
@property (strong, nonatomic) UIButton *preview;

@property (strong, nonatomic) UIButton *postButton;
@property (strong, nonatomic) UIButton *cancelButton;
@property (strong, nonatomic) UIButton *photosButton;
@property (strong, nonatomic) UIButton *removeButton;
@property (strong, nonatomic) UIButton *selectCamera;
@property (strong, nonatomic) UIButton *selectRoll;
@property (strong, nonatomic) UILabel *selectFromLabel;
@property (strong, nonatomic) UILabel *replyTweet;

@property (strong, nonatomic) UIView *cameraSourceSelection;

@property (strong, nonatomic) UIActionSheet *draftOptionsSheet;

@property (assign, nonatomic) BOOL didPost;
@property (assign, nonatomic) BOOL isSelectionShowing;
@property (assign, nonatomic) CGFloat keyboardHeight;

@property (assign, nonatomic) NSInteger numberOfLinks;

@end

@implementation BTWTweetComposeView

static const CGFloat kComposeHeight = 190;
static const CGFloat kTweetMargin = 8;
static const NSInteger kTweetLimit = 280;
static const CGFloat kCharLeftWidth = 30;
static const CGFloat kSelectionY = 600;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        [self setClipsToBounds:NO];
        
        self.isSelectionShowing = NO;
        self.numberOfLinks = 0;
        
        self.imagePicker = [[UIImagePickerController alloc] init];
        self.imagePicker.delegate = self;
        
        [self setBackgroundColor:[UIColor clearColor]];
        
        self.backgroundImage = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        [self.backgroundImage setContentMode:UIViewContentModeScaleAspectFill];
        [self.backgroundImage setAlpha:0.0];
        [self addSubview:self.backgroundImage];
        
        self.composeBackground = [[UIView alloc] initWithFrame:CGRectMake(kHorizontalMargin,
                                                                          -kComposeHeight - kVerticalMargin,
                                                                          CGRectGetWidth(self.frame) - 2 * kHorizontalMargin,
                                                                          kComposeHeight)];
        [self.composeBackground setBackgroundColor:[UIColor colorWithWhite:0.95 alpha:0.9]];
        [self.composeBackground.layer setCornerRadius:10.0];
        [self.composeBackground setClipsToBounds:YES];
        [self addSubview:self.composeBackground];
        
        self.postButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.postButton setTitle:NSLocalizedString(@"Post", nil) forState:UIControlStateNormal];
        [self.postButton sizeToFit];
        [self.postButton setEnabled:NO];
        CGRect postButtonFrame = [self.postButton frame];
        postButtonFrame.origin.x = CGRectGetWidth(self.composeBackground.frame) - kTweetMargin - CGRectGetWidth(postButtonFrame);
        postButtonFrame.origin.y = kTweetMargin;
        [self.postButton setFrame:postButtonFrame];
        [self.postButton addTarget:self action:@selector(post) forControlEvents:UIControlEventTouchUpInside];
        [self.composeBackground addSubview:self.postButton];
        
        self.cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.cancelButton setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
        [self.cancelButton sizeToFit];
        CGRect cancelButtonFrame = [self.cancelButton frame];
        cancelButtonFrame.origin.x = kTweetMargin;
        cancelButtonFrame.origin.y = kTweetMargin;
        [self.cancelButton setFrame:cancelButtonFrame];
        [self.cancelButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        [self.composeBackground addSubview:self.cancelButton];
        
        UILabel *composeTitle = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                          kPadding,
                                                                          kComposeHeight,
                                                                          CGRectGetHeight(self.cancelButton.frame))];
        [composeTitle setText:NSLocalizedString(@"Compose message", nil)];
        [composeTitle setFont:[UIFont mediumHelveticaWithSize:16]];
        [composeTitle sizeToFit];
        [composeTitle setFrame:CGRectMake((CGRectGetWidth(self.composeBackground.frame) - CGRectGetWidth(composeTitle.frame)) / 2.0,
                                          CGRectGetMinY(self.cancelButton.frame),
                                          CGRectGetWidth(composeTitle.frame),
                                          CGRectGetHeight(self.cancelButton.frame))];
        [self.composeBackground addSubview:composeTitle];
        
        UIView *dividerLine = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                       CGRectGetMaxY(self.cancelButton.frame) + kTweetMargin,
                                                                       CGRectGetWidth(self.composeBackground.frame),
                                                                       1)];
        [dividerLine setBackgroundColor:[UIColor darkGrayColor]];
        [self.composeBackground addSubview:dividerLine];
        
        self.photosButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.photosButton setTitle:NSLocalizedString(@"Camera", nil) forState:UIControlStateNormal];
        [self.photosButton sizeToFit];
        CGRect photoFrame = [self.photosButton frame];
        photoFrame.origin.x = kTweetMargin;
        photoFrame.origin.y = CGRectGetHeight(self.composeBackground.frame) - kTweetMargin - CGRectGetHeight(photoFrame);
        [self.photosButton setFrame:photoFrame];
        [self.photosButton setAlpha:1.0];
        [self.photosButton addTarget:self action:@selector(showCameraSelection) forControlEvents:UIControlEventTouchUpInside];
        [self.composeBackground addSubview:self.photosButton];
        
        self.charactersLeft = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.composeBackground.frame) - kTweetMargin - kCharLeftWidth,
                                                                        CGRectGetMinY(self.photosButton.frame),
                                                                        kCharLeftWidth,
                                                                        CGRectGetHeight(self.photosButton.frame))];
        [self.charactersLeft setFont:[UIFont lightHelveticaWithSize:14]];
        [self.charactersLeft setText:[NSString stringWithFormat:@"%ld", (long)kTweetLimit]];
        [self.charactersLeft setTextColor:[UIColor darkTextColor]];
        [self.charactersLeft setTextAlignment:NSTextAlignmentRight];
        [self.composeBackground addSubview:self.charactersLeft];
        
        self.replyTweet = [[UILabel alloc] initWithFrame:CGRectMake(kTweetMargin,
                                                                    CGRectGetMaxY(dividerLine.frame) + kTweetMargin,
                                                                    CGRectGetWidth(self.composeBackground.frame) - 2 * kTweetMargin,
                                                                    0)];
        [self.replyTweet setTextColor:[UIColor darkGrayColor]];
        [self.replyTweet setFont:[UIFont lightHelveticaWithSize:10]];
        [self.replyTweet setNumberOfLines:3];
        [self.replyTweet setLineBreakMode:NSLineBreakByWordWrapping];
        [self.composeBackground addSubview:self.replyTweet];
        
        self.tweetArea = [[UITextView alloc] initWithFrame:CGRectMake(5,
                                                                      CGRectGetMaxY(dividerLine.frame) + kTweetMargin,
                                                                      CGRectGetWidth(self.composeBackground.frame) - 2 * 5,
                                                                      CGRectGetMinY(self.charactersLeft.frame) - kTweetMargin * 2 - CGRectGetMaxY(dividerLine.frame))];
        [self.tweetArea setDelegate:self];
        [self.tweetArea setBackgroundColor:[UIColor clearColor]];
        [self.tweetArea setFont:[UIFont lightHelveticaWithSize:14]];
        [self.composeBackground addSubview:self.tweetArea];
        
        self.cameraSourceSelection = [[UIView alloc] initWithFrame:CGRectMake(kHorizontalMargin, kSelectionY, CGRectGetWidth(self.composeBackground.frame), CGRectGetHeight(self.cancelButton.frame))];
        [self.cameraSourceSelection setBackgroundColor:[self.composeBackground backgroundColor]];
        [self.cameraSourceSelection.layer setCornerRadius:[self.composeBackground.layer cornerRadius]];
        [self addSubview:self.cameraSourceSelection];
        
        self.selectFromLabel = [[UILabel alloc] initWithFrame:CGRectMake(kTweetMargin,
                                                                             0,
                                                                             CGRectGetWidth(self.cameraSourceSelection.frame),
                                                                             CGRectGetHeight(self.cameraSourceSelection.frame))];
        [self.selectFromLabel setText:NSLocalizedString(@"Via", nil)];
        [self.selectFromLabel setFont:[UIFont helveticaWithSize:14]];
        [self.selectFromLabel sizeToFit];
        CGRect selectLabelFrame = [self.selectFromLabel frame];
        selectLabelFrame.size.height = CGRectGetHeight(self.cameraSourceSelection.frame);
        [self.selectFromLabel setFrame:selectLabelFrame];
        [self.cameraSourceSelection addSubview:self.selectFromLabel];
        
        self.selectCamera = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.selectCamera setTitle:NSLocalizedString(@"Camera", nil) forState:UIControlStateNormal];
        [self.selectCamera sizeToFit];
        [self.selectCamera setFrame:CGRectMake(CGRectGetMaxX(self.selectFromLabel.frame) + kPadding,
                                          0,
                                          CGRectGetWidth(self.selectCamera.frame),
                                          CGRectGetHeight(self.cameraSourceSelection.frame))];
        [self.selectCamera addTarget:self action:@selector(getCamera) forControlEvents:UIControlEventTouchDown];
        [self.cameraSourceSelection addSubview:self.selectCamera];
        
        self.selectRoll = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.selectRoll setTitle:NSLocalizedString(@"Library", nil) forState:UIControlStateNormal];
        [self.selectRoll sizeToFit];
        [self.selectRoll setFrame:CGRectMake(CGRectGetMaxX(self.selectCamera.frame) + kPadding,
                                        0,
                                        CGRectGetWidth(self.selectRoll.frame),
                                        CGRectGetHeight(self.cameraSourceSelection.frame))];
        [self.selectRoll addTarget:self action:@selector(getCameraRoll) forControlEvents:UIControlEventTouchDown];
        [self.cameraSourceSelection addSubview:self.selectRoll];
        
        UIButton *cancelCamera = [UIButton buttonWithType:UIButtonTypeSystem];
        [cancelCamera setTitle:NSLocalizedString(@"Dismiss", nil) forState:UIControlStateNormal];
        [cancelCamera sizeToFit];
        [cancelCamera setFrame:CGRectMake(CGRectGetWidth(self.cameraSourceSelection.frame) - kTweetMargin - CGRectGetWidth(cancelCamera.frame),
                                          0,
                                          CGRectGetWidth(cancelCamera.frame),
                                          CGRectGetHeight(self.cameraSourceSelection.frame))];
        [cancelCamera addTarget:self action:@selector(dismissCameraSelection) forControlEvents:UIControlEventTouchUpInside];
        [self.cameraSourceSelection addSubview:cancelCamera];
        
        self.preview = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.preview setFrame:CGRectMake(kTweetMargin * 3,
                                          CGRectGetMinY(self.photosButton.frame),
                                          CGRectGetHeight(self.photosButton.frame),
                                          CGRectGetHeight(self.photosButton.frame))];
        [[self.preview imageView] setContentMode:UIViewContentModeScaleAspectFill];
        [[self.preview imageView] setClipsToBounds:YES];
        [self.preview addTarget:self action:@selector(didTapImagePreview:) forControlEvents:UIControlEventTouchUpInside];
        [self.preview setAlpha:0.0];
        [self.preview setHidden:YES];
        [self.preview.layer setCornerRadius:4.0];
        [self.preview setClipsToBounds:YES];
        [self.composeBackground addSubview:self.preview];
        
        self.removeButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.removeButton setTitle:NSLocalizedString(@"Clear image", nil) forState:UIControlStateNormal];
        [self.removeButton sizeToFit];
        [self.removeButton setFrame:CGRectMake(kTweetMargin * 3,
                                               0,
                                               CGRectGetWidth(self.removeButton.frame),
                                               CGRectGetHeight(self.selectFromLabel.frame))];
        [self.removeButton setAlpha:0.0];
        [self.removeButton addTarget:self action:@selector(cancelImage) forControlEvents:UIControlEventTouchUpInside];
        [self.cameraSourceSelection addSubview:self.removeButton];
        
        CGSize mainSize = [[UIScreen mainScreen] bounds].size;
        self.imagePreviewer = [[BTWImageViewerView alloc] initWithFrame:CGRectMake(0, 20, mainSize.width, mainSize.height)];
        [self.imagePreviewer setClipsToBounds:NO];
        [self addSubview:self.imagePreviewer];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:@"UIKeyboardWillShowNotification"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardDidHide:)
                                                     name:@"UIKeyboardDidHideNotification"
                                                   object:nil];
        
        [self setAlpha:0.0];
    }
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.tweetArea setDelegate:nil];
    [self.imagePicker setDelegate:nil];
}

- (void)setBlurredBackground:(UIImage *)background
{
    [self.backgroundImage setImage:background];
}

- (void)setInitialText:(NSString *)initialText
{
    [self.tweetArea setText:initialText];
    [self textViewDidChange:self.tweetArea];
}

- (void)setSelectedRange:(NSRange)range
{
    double delayInSeconds = 0.6;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //code to be executed on the main queue after delay
        [self.tweetArea setSelectedRange:range];
    });
}

- (void)setScrollToTop:(BOOL)scrolls
{
    [self.tweetArea setScrollsToTop:scrolls];
}

- (void)setReplyTo:(NSString *)tweet
{
    [self.replyTweet setText:tweet];
    [self.replyTweet sizeToFit];
    
    CGRect tweetAreaFrame = [self.tweetArea frame];
    tweetAreaFrame.size.height -= (CGRectGetHeight(self.replyTweet.frame));
    tweetAreaFrame.origin.y += (CGRectGetHeight(self.replyTweet.frame));
    [self.tweetArea setFrame:tweetAreaFrame];
}

- (void)animateIn
{
    [self setAlpha:1.0];
    [self textViewDidChange:self.tweetArea];
    [self.tweetArea becomeFirstResponder];
}

- (void)animateOut
{
    [self.tweetArea resignFirstResponder];
    self.earlyCompletionBlock(self.didPost);
    [UIView animateWithDuration:0.5 animations:^{
        [self.backgroundImage setAlpha:0.0];
        CGRect composeFrame = [self.composeBackground frame];
        composeFrame.origin.y = -200;
        [self.composeBackground setFrame:composeFrame];
        [self.charactersLeft setText:[NSString stringWithFormat:@"%ld", (long)kTweetLimit]];
        [self changeCharactersLeftColor:kTweetLimit];
        [self.removeButton setAlpha:0.0];
        
        if(self.isSelectionShowing) {
            self.isSelectionShowing = NO;
            CGRect selectionFrame = [self.cameraSourceSelection frame];
            selectionFrame.origin.y = kSelectionY;
            [self.cameraSourceSelection setFrame:selectionFrame];
        }
    } completion:^(BOOL finished) {
        self.completionBlock(self.didPost);
        
        [self resetFrames];
    }];
}

- (void)resetFrames
{
    CGRect previewFrame = [self.preview frame];
    previewFrame.origin.x = kTweetMargin * 3;
    [self.preview setFrame:previewFrame];
    [self.preview setHidden:YES];
    [self.removeButton setAlpha:0.0];
    
    CGRect removeFrame = [self.removeButton frame];
    removeFrame.origin.x = kTweetMargin * 3;
    [self.removeButton setFrame:removeFrame];
    [self.photosButton setAlpha:1.0];
    
    CGRect photosButtonFrame = [self.photosButton frame];
    photosButtonFrame.origin.x = kTweetMargin;
    [self.photosButton setFrame:photosButtonFrame];
    
    CGRect tweetAreaFrame = [self.tweetArea frame];
    tweetAreaFrame.size.height += (CGRectGetHeight(self.replyTweet.frame));
    tweetAreaFrame.origin.y = (CGRectGetMinY(self.replyTweet.frame));
    [self.tweetArea setFrame:tweetAreaFrame];
    
    CGRect replyTweetFrame = [self.replyTweet frame];
    replyTweetFrame.size.height = 0;
    [self.replyTweet setFrame:replyTweetFrame];
    
    [self.selectFromLabel setAlpha:1.0];
    [self.selectCamera setAlpha:1.0];
    [self.selectRoll setAlpha:1.0];
    
    [self setAlpha:0.0];
}

#pragma mark - Actions

- (void)didTapImagePreview:(id)sender
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)), NO, 0);
    
    [self drawViewHierarchyInRect:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)) afterScreenUpdates:NO];
    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIImage *blurredSnapshotImage = [snapshotImage applyDarkEffect];
    UIGraphicsEndImageContext();
    
    [self.tweetArea resignFirstResponder];
    
    __weak BTWTweetComposeView *weakSelf = self;
    [self bringSubviewToFront:self.imagePreviewer];
    [self.imagePreviewer setDismissBlock:^(BOOL finished) {
        [weakSelf.tweetArea becomeFirstResponder];
    }];
    [self.imagePreviewer setHidden:NO];
    [self.imagePreviewer animateInWithBackgroundImage:blurredSnapshotImage mainImage:self.attachedImage];
}

- (void)showCameraSelection
{
    [self.tweetArea setSelectedTextRange:nil];
    [self.tweetArea resignFirstResponder];
    [self.tweetArea becomeFirstResponder];
    
    self.isSelectionShowing = YES;
    [self bringSubviewToFront:self.cameraSourceSelection];
    [UIView animateWithDuration:0.3 animations:^{
        CGRect composeFrame = [self.composeBackground frame];
        composeFrame.origin.y = ((CGRectGetHeight([[UIScreen mainScreen] bounds]) - (self.keyboardHeight)) - (kComposeHeight + kPadding + CGRectGetHeight(self.cameraSourceSelection.frame))) / 2.0;
        [self.composeBackground setFrame:composeFrame];
        
        CGRect selectionFrame = [self.cameraSourceSelection frame];
        selectionFrame.origin.y = CGRectGetMaxY(self.composeBackground.frame);
        [self.cameraSourceSelection setFrame:selectionFrame];
        
        [self.photosButton setAlpha:0.0];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            CGRect selectionFrame = [self.cameraSourceSelection frame];
            selectionFrame.origin.y += kPadding;
            [self.cameraSourceSelection setFrame:selectionFrame];
        } completion:^(BOOL finished) {
            [self.tweetArea setSelectedRange:NSMakeRange([[self.tweetArea text] length], 0)];
        }];
    }];
}

-(void)dismissCameraSelection
{
    [self.tweetArea setSelectedTextRange:nil];
    [self.tweetArea resignFirstResponder];
    [self.tweetArea becomeFirstResponder];
    
    self.isSelectionShowing = NO;
    [UIView animateWithDuration:0.5 animations:^{
        CGRect composeFrame = [self.composeBackground frame];
        composeFrame.origin.y = ((CGRectGetHeight([[UIScreen mainScreen] bounds]) - (self.keyboardHeight)) - (kComposeHeight)) / 2.0;
        [self.composeBackground setFrame:composeFrame];
        
        CGRect selectionFrame = [self.cameraSourceSelection frame];
        selectionFrame.origin.y = kSelectionY;
        [self.cameraSourceSelection setFrame:selectionFrame];
        
        [self.photosButton setAlpha:1.0];
        
        CGRect cameraButtonFrame = [self.photosButton frame];
        if(self.attachedImage) {
            cameraButtonFrame.origin.x = CGRectGetMaxX(self.preview.frame) + kPadding;
        }
        else {
            cameraButtonFrame.origin.x = kTweetMargin;
        }
        [self.photosButton setFrame:cameraButtonFrame];
    } completion:^(BOOL finished) {
        [self.tweetArea setSelectedRange:NSMakeRange([[self.tweetArea text] length], 0)];
    }];
}
     
- (void)getCamera
{
    if(self.delegate) {
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        UIViewController *timeline = (UIViewController *)self.delegate;
        [timeline presentViewController:self.imagePicker animated:YES completion:nil];
    }
}

- (void)getCameraRoll
{
    if(self.delegate) {
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        UIViewController *timeline = (UIViewController *)self.delegate;
        [timeline presentViewController:self.imagePicker animated:YES completion:nil];
    }
}

- (void)dismiss
{
    self.didPost = NO;
    [self animateOut];
    [self.preview setImage:nil forState:UIControlStateNormal];
    self.attachedImage = nil;
}

#pragma mark - Twitter post

- (void)post
{
    NSLog(@"IS IT GETTING HERE at all?");

    [self.postButton setEnabled:NO];
    GTChatViewController *chatViewController = (GTChatViewController *)self.delegate;
    
    GTSuccessBlock finishBlock = ^(id responseObject) {
        [self.tweetArea setText:@""];
        NSLog(@"IS IT GETTING HERE TO ANIMATE OUT?");
        self.didPost = YES;
        [self.preview setImage:nil forState:UIControlStateNormal];
        self.attachedImage = nil;
        [self animateOut];
    };
    GTFailureBlock failBlock = ^(NSError *error) {
        NSLog(@"Network error: %@", error.localizedDescription);
        [self.postButton setEnabled:YES];
    };
    
    GTChatService *service = [GTChatService sharedChatService];
    
    if(self.attachedImage == nil) {
        NSLog(@"Wwe are not gonna finish");
        [service pushStatus:self.tweetArea.text
                      event:self.eventID
                    success:finishBlock
                    failure:failBlock];
        
        [self.tweetArea setText:@""];
        NSLog(@"IS IT GETTING HERE TO ANIMATE OUT?");
        self.didPost = YES;
        [self.preview setImage:nil forState:UIControlStateNormal];
        self.attachedImage = nil;
        [self animateOut];
    }
    else {
        NSLog(@"AGGHGHGHGHGGHGH");
        [service pushStatus:self.tweetArea.text
                      image:self.attachedImage
                      event:self.eventID
                   location:[chatViewController getCurrentLocation]
                    success:finishBlock
                    failure:failBlock];
        
        [self.tweetArea setText:@""];
        NSLog(@"IS IT GETTING HERE TO ANIMATE OUT?");
        self.didPost = YES;
        [self.preview setImage:nil forState:UIControlStateNormal];
        self.attachedImage = nil;
        [self animateOut];
        
        [chatViewController addPhotoToMap:self.attachedImage];
    }
}

#pragma mark - Other visual tweaks

- (void)changeCharactersLeftColor:(NSInteger)textLength
{
    if(textLength < 0) {
        [self.charactersLeft setTextColor:[UIColor redColor]];
        [self.postButton setEnabled:NO];
    }
    else {
        [self.charactersLeft setTextColor:[UIColor darkTextColor]];
        if(textLength >= kTweetLimit) {
            [self.postButton setEnabled:NO];
        }
        else {
            [self.postButton setEnabled:YES];
        }
    }
}

- (void) cancelImage
{
    self.attachedImage = nil;
    [UIView animateWithDuration:0.5 animations:^{
        [self.selectFromLabel setAlpha:1.0];
        [self.selectCamera setAlpha:1.0];
        [self.selectRoll setAlpha:1.0];
        [self.preview setAlpha:0.0];
        [self.preview setHidden:YES];
        CGRect previewFrame = [self.preview frame];
        previewFrame.origin.x = kTweetMargin * 3;
        [self.preview setFrame:previewFrame];
        [self.removeButton setAlpha:0.0];
        CGRect removeFrame = [self.removeButton frame];
        removeFrame.origin.x = kTweetMargin * 3;
        [self.removeButton setFrame:removeFrame];
    } completion:^(BOOL finished) {
        [self.preview setImage:nil forState:UIControlStateNormal];
        [self textViewDidChange:self.tweetArea];
    }];
}

#pragma mark - Imagepicker delegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
    [self.tweetArea becomeFirstResponder];
    [self showCameraSelection];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.attachedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    UIImageWriteToSavedPhotosAlbum(self.attachedImage, nil, nil, nil);

    self.attachedImage = [self.attachedImage resizedImageToFitInSize:CGSizeMake(kMaxImageSize, kMaxImageSize) scaleIfSmaller:NO];
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
    [self.tweetArea becomeFirstResponder];
    [self.preview setHidden:NO];
    [self.preview setImage:self.attachedImage forState:UIControlStateNormal];
    [self.charactersLeft setText: [NSString stringWithFormat:@"%ld", (long)(kTweetLimit - [[self.tweetArea text] length])]];
    [self.postButton setEnabled:YES];
    [UIView animateWithDuration:0.5 animations:^{
        [self.selectFromLabel setAlpha:0.0];
        [self.selectCamera setAlpha:0.0];
        [self.selectRoll setAlpha:0.0];
        [self.photosButton setAlpha:0.0];
        [self.preview setAlpha:1.0];
        CGRect previewFrame = [self.preview frame];
        previewFrame.origin.x = kTweetMargin;
        [self.preview setFrame:previewFrame];
        [self.removeButton setAlpha:1.0];
        CGRect removeFrame = [self.removeButton frame];
        removeFrame.origin.x = kTweetMargin;
        [self.removeButton setFrame:removeFrame];
    } completion:^(BOOL finished){

    }];
    [self showCameraSelection];
}

#pragma mark - Textview delegate

- (void)textViewDidChange:(UITextView *)textView
{
    NSInteger textLength = [[textView text] length];
    if(textLength > 0 && textLength <= kTweetLimit)
        [self.postButton setEnabled:YES];
    else
        [self.postButton setEnabled:NO];
    NSInteger charactersLeft = kTweetLimit - textLength;
    charactersLeft = [self detectLinksInText:[textView text] charactersLeft:charactersLeft];
    
    [self changeCharactersLeftColor:charactersLeft];
    [self.charactersLeft setText: [NSString stringWithFormat:@"%ld", (long)(charactersLeft)]];
}


#pragma mark - Notifications

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    self.keyboardHeight = kbSize.height;
    
    if(!self.isSelectionShowing) {
        [UIView animateWithDuration:0.8 animations:^{
            [self.backgroundImage setAlpha:1.0];
            CGRect composeFrame = [self.composeBackground frame];
            composeFrame.origin.y = ((CGRectGetHeight([[UIScreen mainScreen] bounds]) - (kbSize.height)) - kComposeHeight) / 2.0;
            [self.composeBackground setFrame:composeFrame];
        }];
    }
}

- (void)keyboardDidHide:(NSNotification *)notification
{
    
}

#pragma mark - URL detection

- (NSInteger) detectLinksInText:(NSString *)text charactersLeft:(NSInteger)charLeft
{
    NSDataDetector* detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
    NSArray* matches = [detector matchesInString:text options:0 range:NSMakeRange(0, [text length])];
    self.numberOfLinks = [matches count];
    for(NSTextCheckingResult *result in matches) {
        NSString *substring = [text substringWithRange:[result range]];
        charLeft += [substring length];
    }
    return charLeft;
}

@end
