//
//  LEGIFLibrary.h
//  Giffed
//
//  Created by Julius Parishy on 1/21/14.
//  Copyright (c) 2014 jp. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LEGIFLibraryEntry.h"

@interface LEGIFLibrary : NSObject

+ (instancetype)sharedLibrary;

@property (nonatomic, strong, readonly) NSArray *entries;

- (LEGIFLibraryEntry *)addEntryWithGIFData:(NSData *)GIFData error:(NSError **)error;

- (void)deleteEntry:(LEGIFLibraryEntry *)entry;

@end
