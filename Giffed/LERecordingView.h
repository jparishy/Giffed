//
//  LERecordingView.h
//  Giffed
//
//  Created by Julius Parishy on 1/18/14.
//  Copyright (c) 2014 jp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LERecordingView : UIView

@property (nonatomic, strong, readonly) NSData *dataForLastRecording;

- (void)ensureConnectionIsActive;

- (void)startRecording;
- (void)finishRecording;

- (void)toggleCameras;
- (void)togglePreview;

@end
