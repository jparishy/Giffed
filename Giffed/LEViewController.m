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

@property (nonatomic, weak) IBOutlet UIButton *previewButton;
@property (nonatomic, weak) IBOutlet UIButton *flipButton;
@property (nonatomic, weak) IBOutlet UIButton *saveButton;

@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *buttonWidthConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *buttonHeightConstraint;

@property (nonatomic, weak) IBOutlet LERecordingView *recordingView;

@property (nonatomic, assign) BOOL inPreviewMode;

@end

@implementation LEViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.activityIndicator.alpha = 0.0f;
    
    self.inPreviewMode = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
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

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - Button state management

- (IBAction)recordButtonPressedDown:(UIButton *)button
{
    [self updateTitleForButton:button recording:YES];
    
    [self.recordingView startRecording];
}

- (IBAction)recordButtonReleased:(UIButton *)button
{
    [self updateTitleForButton:button recording:NO];
    
    [self.recordingView finishRecording];
    
    // File reading hack.
    double delayInSeconds = 0.25f;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));

    __weak typeof(self) weakSelf = self;
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf toggleRecordingView];
    });
}

- (IBAction)previewButtonPressed:(UIButton *)button
{
    [self toggleRecordingView];
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
        [self.previewButton setTitle:NSLocalizedString(@"Close", nil) forState:UIControlStateNormal];
    }
    else
    {
        [self.previewButton setTitle:NSLocalizedString(@"Preview", nil) forState:UIControlStateNormal];
    }
    
    self.saveButton.hidden = !self.inPreviewMode;
    self.flipButton.hidden = self.inPreviewMode;
    
    self.button.enabled = !self.inPreviewMode;
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
    
    self.previewButton.enabled = NO;
    self.saveButton.enabled = NO;
    self.button.enabled = NO;
}

- (void)endActionProgress
{
    [UIView animateWithDuration:0.25f animations:^{
        
        self.activityIndicator.alpha = 0.0f;
    }];
    
    [self.activityIndicator stopAnimating];
    
    self.previewButton.enabled = YES;
    self.saveButton.enabled = YES;
    self.button.enabled = YES;
}

#pragma mark - Constraints manamagement

- (void)updateViewConstraints
{
    [super updateViewConstraints];
    
    [self updateButtonLayoutConstraints];
}

- (void)updateButtonLayoutConstraints
{
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    const CGFloat baseWidth = (CGRectGetHeight(screenBounds) - CGRectGetWidth(screenBounds)) / 2.0f;
    const CGFloat baseHeight = CGRectGetWidth(screenBounds);
    
    if(UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
    {
        self.buttonHeightConstraint.constant = baseHeight;
        self.buttonWidthConstraint.constant = baseWidth;
    }
    else
    {\
        self.buttonWidthConstraint.constant = baseHeight;
        self.buttonHeightConstraint.constant = baseWidth;
    }
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
