//
//  LERecordingView.m
//  Giffed
//
//  Created by Julius Parishy on 1/18/14.
//  Copyright (c) 2014 jp. All rights reserved.
//

#import "LERecordingView.h"

#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface LERecordingView () <AVCaptureFileOutputRecordingDelegate>

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureConnection *captureConnection;

@property (nonatomic, strong) AVCaptureDevice *backFacingCamera;
@property (nonatomic, strong) AVCaptureDevice *frontFacingCamera;

@property (nonatomic, strong) AVCaptureDeviceInput *activeDeviceInput;

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) AVCaptureMovieFileOutput *fileOutput;

@property (nonatomic, strong) MPMoviePlayerController *playerController;

@end

@implementation LERecordingView

@dynamic dataForLastRecording;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self initializeCaptureSession];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self initializeCaptureSession];
}

- (NSData *)dataForLastRecording
{
    return [NSData dataWithContentsOfFile:[self currentVideoPath]];
}

- (void)initializeCaptureSession
{
    self.captureSession = [[AVCaptureSession alloc] init];
    
    [self initializeCameraReferences];
    [self initializePreviewLayer];
    
    [self initializeCaptureConnection];
    
    [self beginRecordingWithDevice:self.backFacingCamera];
}

- (void)initializeCameraReferences
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    for(AVCaptureDevice *device in devices)
    {
        if(device.position == AVCaptureDevicePositionBack)
        {
            self.backFacingCamera = device;
        }
        else if(device.position == AVCaptureDevicePositionFront)
        {
            self.frontFacingCamera = device;
        }
    }
}

- (void)initializePreviewLayer
{
    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
    self.previewLayer.frame = self.bounds;
    
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    [self.layer addSublayer:self.previewLayer];
}

- (void)initializeCaptureConnection
{
    self.captureConnection = self.previewLayer.connection;
    self.captureConnection.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
    
    self.fileOutput = [[AVCaptureMovieFileOutput alloc] init];
    [self.captureSession addOutput:self.fileOutput];
}

- (void)beginRecordingWithDevice:(AVCaptureDevice *)device
{
    [self.captureSession stopRunning];
    
    if(self.activeDeviceInput)
    {
        [self.captureSession removeInput:self.activeDeviceInput];
    }
    
    NSError *error = nil;
    self.activeDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if(error)
    {
        NSLog(@"Error: %@", error);
        return;
    }
    
    [self.captureSession addInput:self.activeDeviceInput];
    
    self.captureSession.sessionPreset = AVCaptureSessionPreset640x480;
    
    [self ensureConnectionIsActive];
}

- (void)ensureConnectionIsActive
{
    [self.captureSession startRunning];
}

- (NSString *)currentVideoPath
{
    NSArray *directories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *directory = directories.firstObject;
    NSString *absolutePath = [directory stringByAppendingPathComponent:@"/current.mov"];
    
    return absolutePath;
}

- (void)startRecording
{
    NSString *path = [self currentVideoPath];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:path])
    {
        NSError *error = nil;
        [fileManager removeItemAtPath:path error:&error];
        if(error)
        {
            NSLog(@"Error: %@", error);
        } 
    }
    
    NSURL *url = [NSURL fileURLWithPath:path];
    [self.fileOutput startRecordingToOutputFileURL:url recordingDelegate:self];
}

- (void)finishRecording
{
    [self.fileOutput stopRecording];
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    NSLog(@"Error: %@", error);
}

- (void)toggleCameras
{
    BOOL isBackFacing = (self.activeDeviceInput.device == self.backFacingCamera);
    [self.captureSession stopRunning];
    
    if(isBackFacing)
    {
        [self beginRecordingWithDevice:self.frontFacingCamera];
    }
    else
    {
        [self beginRecordingWithDevice:self.backFacingCamera];
    }
}

- (void)togglePreview
{
    if(self.playerController)
    {
        [self.playerController.view removeFromSuperview];
        self.playerController = nil;
    }
    else
    {
        NSURL *url = [NSURL fileURLWithPath:[self currentVideoPath]];
        self.playerController = [[MPMoviePlayerController alloc] initWithContentURL:url];
        
        self.playerController.movieSourceType = MPMovieSourceTypeFile;
        self.playerController.repeatMode = MPMovieRepeatModeOne;
        self.playerController.controlStyle = MPMovieControlStyleNone;
        self.playerController.scalingMode = MPMovieScalingModeAspectFill;
        self.playerController.allowsAirPlay = NO;
        
        self.playerController.view.frame = self.bounds;
        [self addSubview:self.playerController.view];
        
        [self.playerController play];
    }
}

@end
