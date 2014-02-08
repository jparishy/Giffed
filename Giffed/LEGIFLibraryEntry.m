//
//  LEGIFLibraryEntry.m
//  Giffed
//
//  Created by Julius Parishy on 1/21/14.
//  Copyright (c) 2014 jp. All rights reserved.
//

#import "LEGIFLibraryEntry.h"

@implementation LEGIFLibraryEntry

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if((self = [super init]))
    {
        _filePath = [aDecoder decodeObjectForKey:@"filePath"];
        _createdDate = [aDecoder decodeObjectForKey:@"createdDate"];
        _caption = [aDecoder decodeObjectForKey:@"caption"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.filePath forKey:@"filePath"];
    [aCoder encodeObject:self.createdDate forKey:@"createdDate"];
    [aCoder encodeObject:self.caption forKey:@"caption"];
}

@end
