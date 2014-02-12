//
//  LEViewController.m
//  Giffed
//
//  Created by Julius Parishy on 1/18/14.
//  Copyright (c) 2014 jp. All rights reserved.
//

#import "LEViewController.h"

#import "LERecordingView.h"

#import "LEGiffedClient.h"
#import "LEGIFLibrary.h"

typedef NS_ENUM(NSInteger, LERecordingMode)
{
    LERecordingModeInactive,
    LERecordingModeRecording,
    LERecordingModePreview
};

@interface LEViewController ()

@property (nonatomic, weak) IBOutlet UIButton *button;

@property (nonatomic, weak) IBOutlet UIButton *flipButton;

@property (nonatomic, weak) IBOutlet UIButton *saveButton;
@property (nonatomic, weak) IBOutlet UIButton *discardButton;

@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *buttonWidthConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *buttonHeightConstraint;

@property (nonatomic, weak) IBOutlet LERecordingView *recordingView;

@property (nonatomic, assign) BOOL inPreviewMode;

@property (nonatomic, strong) UIDynamicAnimator *animator;

@property (nonatomic, assign) CGRect originalDiscardFrame;
@property (nonatomic, assign) CGRect originalSaveFrame;

@end

@implementation LEViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Giffed", nil);
    
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.recordingView.superview];
    
    self.originalDiscardFrame = self.discardButton.frame;
    self.originalSaveFrame    = self.saveButton.frame;
    
    self.activityIndicator.alpha = 0.0f;
    self.inPreviewMode = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.recordingView ensureConnectionIsActive];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button state management

- (IBAction)recordButtonPressedDown:(UIButton *)button
{
    if(self.inPreviewMode)
        return;
    
    [self updateTitleForButton:button recording:YES];
    
    [self.recordingView startRecording];
}

- (IBAction)recordButtonReleased:(UIButton *)button
{
    [self.recordingView finishRecording];
    self.inPreviewMode = YES;
    
    // File reading hack.
    double delayInSeconds = 0.25f;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));

    __weak typeof(self) weakSelf = self;
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf.recordingView togglePreview];
    });
    
    [self animateConfirmationButtonsOnScreen];
}

- (void)toggleRecordingView
{
    [self.recordingView togglePreview];
    
    self.inPreviewMode = !self.inPreviewMode;
}

- (IBAction)flipCameraPressed:(UIButton *)button
{
    [self.recordingView toggleCameras];
}

- (IBAction)savePressed:(UIButton *)button
{
    NSData *data = [self.recordingView dataForLastRecording];
    
    __weak typeof(self) weakSelf = self;
    [self sendSaveRequestWithMovieData:data completion:^(NSData *responseData, NSError *error) {
        
        __strong typeof(self) strongSelf = weakSelf;
        if(error)
        {
            [strongSelf handleError:error];
        }
        else
        {
            [strongSelf saveConvertedGIFWithData:responseData];
        }
        
        [strongSelf endActionProgress];
    }];
    
    [self startActionProgress];
}

- (IBAction)discardPressed:(UIButton *)button
{
    [self toggleRecordingView];
    [self animateConfirmationButtonsOffScreen];
}

- (void)animateConfirmationButtonsOnScreen
{
    [self.animator removeAllBehaviors];
    
    CGFloat margin = 20.0f;
    
    CGPoint discardPosition = self.discardButton.center;
    discardPosition.x = margin + (CGRectGetWidth(self.discardButton.frame) / 2.0f);
    
    CGPoint savePosition = self.discardButton.center;
    savePosition.x = CGRectGetWidth(self.view.bounds) - margin - (CGRectGetWidth(self.saveButton.frame) / 2.0f);
    
    UISnapBehavior *discardSnap = [[UISnapBehavior alloc] initWithItem:self.discardButton snapToPoint:discardPosition];
    UISnapBehavior *saveSnap = [[UISnapBehavior alloc] initWithItem:self.saveButton snapToPoint:savePosition];
    
    [self.animator addBehavior:discardSnap];
    [self.animator addBehavior:saveSnap];
}

- (void)animateConfirmationButtonsOffScreen
{
    [self.animator removeAllBehaviors];
    
    UIGravityBehavior *gravity = [[UIGravityBehavior alloc] initWithItems:@[ self.discardButton, self.saveButton ]];
    
    __weak typeof(self) weakSelf = self;
    gravity.action = ^{
        
        __strong typeof(self) strongSelf = weakSelf;
        
        BOOL done = YES;
        
        NSArray *views = @[ strongSelf.discardButton, strongSelf.saveButton ];
        for(UIView *view in views)
        {
            if(CGRectGetMinY(view.frame) < CGRectGetMaxY(view.superview.bounds))
            {
                done = NO;
                break;
            }
        }
        
        if(done)
        {
            [strongSelf.animator removeAllBehaviors];
            
            strongSelf.discardButton.frame = strongSelf.originalDiscardFrame;
            strongSelf.saveButton.frame    = strongSelf.originalSaveFrame;
        }
    };
    
    [self.animator addBehavior:gravity];
}

- (void)updateTitleForButton:(UIButton *)button recording:(BOOL)recording
{
    button.titleLabel.numberOfLines = 0;
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    NSString *title = nil;
    
    if(recording)
    {
        title = NSLocalizedString(@"Recording", nil);
    }
    else
    {
        title = NSLocalizedString(@"Hold to Record", nil);
    }
    
    [self updateButton:button withTitleForAllStates:title];
}

- (void)updateButton:(UIButton *)button withTitleForAllStates:(NSString *)title
{
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateHighlighted];
    [button setTitle:title forState:UIControlStateSelected];
    [button setTitle:title forState:UIControlStateDisabled];
}

- (void)setInPreviewMode:(BOOL)inPreviewMode
{
    _inPreviewMode = inPreviewMode;
    
    if(self.inPreviewMode)
    {
        NSString *recordTitle = NSLocalizedString(@"Is it a keeper?", nil);
        [self updateButton:self.button withTitleForAllStates:recordTitle];
        
        self.button.enabled = NO;
    }
    else
    {
        [self updateTitleForButton:self.button recording:NO];
        
        self.button.enabled = YES;
    }
    
    UIColor *buttonBackgroundColor = [UIColor colorWithRed:0.0f green:(103.0f/255.0f) blue:(221.0f/255.0f) alpha:1.0f];
    if(self.inPreviewMode)
    {
        buttonBackgroundColor = [buttonBackgroundColor colorWithAlphaComponent:0.5f];
    }
    
    [UIView animateWithDuration:1.0f animations:^{
        
        self.button.backgroundColor = buttonBackgroundColor;
    }];
        
    [UIView animateWithDuration:0.4f animations:^{
        
        self.flipButton.alpha = self.inPreviewMode ? 0.0f : 1.0f;
    }];
}

- (void)handleError:(NSError *)error
{
    NSString *title = NSLocalizedString(@"Oh noes", nil);
    
    NSString *staticMessage = NSLocalizedString(@"There was a problem talking to the web server :( Here's there error if it's of any use to you:", nil);
    NSString *message = [NSString stringWithFormat:@"%@\nn\n%@", staticMessage, error.localizedDescription];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"Otay", nil) otherButtonTitles:nil];
    [alertView show];
}

- (void)startActionProgress
{
    [UIView animateWithDuration:0.25f animations:^{
        
        self.activityIndicator.alpha = 1.0f;
    }];
    
    [self.activityIndicator startAnimating];
    
    self.saveButton.enabled = NO;
    self.button.enabled = NO;
}

- (void)endActionProgress
{
    [UIView animateWithDuration:0.25f animations:^{
        
        self.activityIndicator.alpha = 0.0f;
    }];
    
    [self.activityIndicator stopAnimating];
    
    self.saveButton.enabled = YES;
    self.button.enabled = YES;
    
    [self animateConfirmationButtonsOffScreen];
}

- (void)sendSaveRequestWithMovieData:(NSData *)movieData completion:(void(^)(NSData *responseData, NSError *error))completion
{
    LEGiffedClient *client = [LEGiffedClient sharedClient];
    [client POST:@"gifify" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    
        [formData appendPartWithFileData:movieData name:@"video" fileName:@"gifmovie.mov" mimeType:@"video/quicktime"];
        
    } success:^(AFHTTPRequestOperation *operation, NSData *responseData) {
        
        if(completion)
        {
            completion(responseData, nil);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if(completion)
        {
            completion(nil, error);
        }
    }];
}

- (void)saveConvertedGIFWithData:(NSData *)data
{
    NSError *error = nil;
    [[LEGIFLibrary sharedLibrary] addEntryWithGIFData:data error:&error];
    
    if(error)
    {
        [self handleError:error];
    }
    
    NSString *title = NSLocalizedString(@"Done", nil);
    NSString *message = NSLocalizedString(@"Your GIF was saved to the library.", nil);
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"Yay", nil) otherButtonTitles:nil];
    [alertView show];
    
    if(self.inPreviewMode)
    {
        [self toggleRecordingView];
    }
}

@end
