//
//  LEGIFLibraryEntry.h
//  Giffed
//
//  Created by Julius Parishy on 1/21/14.
//  Copyright (c) 2014 jp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LEGIFLibraryEntry : NSObject<NSCoding>

@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, strong) NSDate *createdDate;

@property (nonatomic, copy) NSString *caption;

@end
