//
//  LEGiffedClient.m
//  Giffed
//
//  Created by Julius Parishy on 1/21/14.
//  Copyright (c) 2014 jp. All rights reserved.
//

#import "LEGiffedClient.h"

@implementation LEGiffedClient

- (instancetype)init
{
#if LE_GIFFED_PRODUCTION
    NSURL *baseURL = [NSURL URLWithString:@""];
#else
    NSURL *baseURL = [NSURL URLWithString:@"http://gifify-tyty.herokuapp.com/"];
#endif

    if((self = [super initWithBaseURL:baseURL]))
    {
        self.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
    
    return self;
}

+ (instancetype)sharedClient
{
    static LEGiffedClient *client = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        client = [[LEGiffedClient alloc] init];
    });
    
    return client;
}

@end
