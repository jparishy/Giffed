//
//  LEGIFLibrary.m
//  Giffed
//
//  Created by Julius Parishy on 1/21/14.
//  Copyright (c) 2014 jp. All rights reserved.
//

#import "LEGIFLibrary.h"

@implementation LEGIFLibrary

@dynamic entries;

+ (NSString *)libraryDirectoryPath
{
    NSArray *directories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *directory = directories.firstObject;
    NSString *absolutePath = [directory stringByAppendingPathComponent:@"/library/"];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:absolutePath])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:absolutePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return absolutePath;
}

+ (NSString *)pathForLibraryPlist
{
    return [[self libraryDirectoryPath] stringByAppendingPathComponent:@"library.plist"];
}

+ (instancetype)sharedLibrary
{
    static LEGIFLibrary *library = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSString *path = [self pathForLibraryPlist];
        library = [[LEGIFLibrary alloc] initWithPath:path];
    });
    
    return library;
}

- (instancetype)initWithPath:(NSString *)path
{
    if((self = [super init]))
    {
    }
    
    return self;
}

- (LEGIFLibraryEntry *)addEntryWithGIFData:(NSData *)GIFData error:(NSError *__autoreleasing *)error
{
    NSString *filePath = [self randomFilePath];
    [GIFData writeToFile:filePath options:NSDataWritingAtomic error:error];
    if(*error)
    {
        return nil;
    }
    
    LEGIFLibraryEntry *entry = [[LEGIFLibraryEntry alloc] init];
    entry.filePath = filePath;
    entry.createdDate = [NSDate date];
    
    NSArray *entries = self.entries;
    entries = [entries arrayByAddingObject:entry];
    
    [self saveEntries:entries];
    
    return entry;
}

- (NSString *)randomFilePath
{
    NSUUID *uuid = [[NSUUID alloc] init];
    return [[[self.class libraryDirectoryPath] stringByAppendingPathComponent:[uuid UUIDString]] stringByAppendingPathExtension:@"gif"];
}

- (NSArray *)entries
{
    NSString *path = [self.class pathForLibraryPlist];
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    if(!data)
        return @[ ];
    
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

- (void)saveEntries:(NSArray *)entries
{
    NSString *path = [self.class pathForLibraryPlist];
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:entries];
    [data writeToFile:path atomically:YES];
}

- (void)deleteEntry:(LEGIFLibraryEntry *)entryToDelete
{
    NSMutableArray *entries = [[self entries] mutableCopy];
    
    NSInteger indexToRemove = -1;
    NSInteger index = 0;
    for(LEGIFLibraryEntry *entry in entries)
    {
         if([entry.filePath isEqualToString:entry.filePath])
         {
            indexToRemove = index;
            break;
         }
        
         ++index;
    }
    
    if(indexToRemove >= 0)
    {
        [entries removeObjectAtIndex:indexToRemove];
    }
    
    [self saveEntries:entries];
}

@end
