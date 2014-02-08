//
//  LEImgurClient.m
//  Giffed
//
//  Created by Julius Parishy on 1/21/14.
//  Copyright (c) 2014 jp. All rights reserved.
//

#import "LEImgurClient.h"

@interface LEImgurClient ()

@property (nonatomic, copy) NSString *clientID;
@property (nonatomic, copy) NSString *clientSecret;

@end

@implementation LEImgurClient

- (instancetype)init
{
    NSURL *baseURL = [NSURL URLWithString:@"https://api.imgur.com/3/"];

    if((self = [super initWithBaseURL:baseURL]))
    {
        self.clientID = @"af19c7e74b92d04";
        
        NSString *authorizationHeaderValue = [NSString stringWithFormat:@"Client-ID %@", self.clientID];
        [self.requestSerializer setValue:authorizationHeaderValue forHTTPHeaderField:@"Authorization"];
    }
    
    return self;
}

+ (instancetype)sharedClient
{
    static LEImgurClient *client = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        client = [[LEImgurClient alloc] init];
    });
    
    return client;
}

- (void)uploadGIFWithData:(NSData *)data success:(void (^)(NSString *))success failure:(void (^)(NSError *))failure
{
    [self POST:@"upload.json" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        [formData appendPartWithFileData:data name:@"image" fileName:@"image" mimeType:@"application/octet-stream"];
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if(success)
        {
            NSString *url = responseObject[@"data"][@"link"];
            success(url);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if(failure)
        {
            failure(error);
        }
    }];
}

@end
