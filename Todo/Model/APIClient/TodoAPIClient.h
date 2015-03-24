//
//  TodoAPIClient.h
//  Todo
//
//  Created by Appiaries Corporation on 12/10/14.
//  Copyright (c) 2014 Appiaries Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFHTTPSessionManager.h>

@interface TodoAPIClient : AFHTTPSessionManager
#pragma mark - Properties
@property (nonatomic, readonly) NSString *accessToken;
@property (nonatomic, readonly) NSString *storeToken;
@property (nonatomic, readonly) NSDate *tokenExpireDate;
@property (nonatomic, readonly) NSString *userId;


#pragma mark - Initialization
+ (instancetype)sharedClient;

#pragma mark - Public methods
- (void)saveLogInInfo:(NSDictionary *)data;
- (NSDictionary *)loadLogInInfo;

@end
