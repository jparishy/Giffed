//
//  LEPreviewContainerView.m
//  Giffed
//
//  Created by Julius Parishy on 1/18/14.
//  Copyright (c) 2014 jp. All rights reserved.
//

#import "LEPreviewContainerView.h"

@implementation LEPreviewContainerView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    CALayer *layer = self.layer;
    layer.shadowColor = [UIColor blackColor].CGColor;
    layer.shadowOpacity = 0.2f;
    layer.shadowRadius = 5.0f;
    layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
}

@end
