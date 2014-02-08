//
//  LEGiffedClient.h
//  Giffed
//
//  Created by Julius Parishy on 1/21/14.
//  Copyright (c) 2014 jp. All rights reserved.
//

#import "AFNetworking/AFNetworking.h"

@interface LEGiffedClient : AFHTTPRequestOperationManager

+ (instancetype)sharedClient;

@end
