//
//  LEImgurClient.h
//  Giffed
//
//  Created by Julius Parishy on 1/21/14.
//  Copyright (c) 2014 jp. All rights reserved.
//

#import "AFNetworking/AFNetworking.h"

@interface LEImgurClient : AFHTTPRequestOperationManager

+ (instancetype)sharedClient;

- (void)uploadGIFWithData:(NSData *)data success:(void(^)(NSString *url))success failure:(void(^)(NSError *error))failure;

@end
