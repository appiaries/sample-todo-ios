//
//  TodoAPIClient.m
//  Todo
//
//  Created by Appiaries Corporation on 12/10/14.
//  Copyright (c) 2014 Appiaries Corporation. All rights reserved.
//

#import "TodoAPIClient.h"

/**
 * UserDefaults key
 */
static NSString *const kUserDefaultsKeyAccessToken     = @"TODOAccessToken";
static NSString *const kUserDefaultsKeyStoreToken      = @"TODOStoreToken";
static NSString *const kUserDefaultsKeyTokenExpireDate = @"TODOTokenExpireDate";
static NSString *const kTodoUserDefaultKeyStoreToken   = @"TodoStoreToken";
static NSString *const kTodoUserDefaultKeyUserId       = @"TodoUserId";
static NSString *const kTodoUserDefaultKeyTypeLogin    = @"TypeLogin";


@interface TodoAPIClient ()
#pragma mark - Properties (Private)
@property (nonatomic, readwrite) NSString *accessToken;
@property (nonatomic, readwrite) NSString *storeToken;
@property (nonatomic, readwrite) NSDate *tokenExpireDate;
@property (nonatomic, readwrite) NSString *userId;
@end


@implementation TodoAPIClient

#pragma mark - Initialization
+ (instancetype)sharedClient
{
    static TodoAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.HTTPAdditionalHeaders = @{ @"Accept" : @"application/json" };
        _sharedClient = [[TodoAPIClient alloc] initWithSessionConfiguration:configuration];
        //reachability
        [_sharedClient.reachabilityManager startMonitoring];
        
        //Tokenの呼び出し
        [_sharedClient loadCredential];
    });
    
    //共通処理
    if (_sharedClient != nil) {
    }
    
    return _sharedClient;
}

- (id)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - Private methods
- (void)saveCredential
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:self.accessToken forKey:kUserDefaultsKeyAccessToken];
    [userDefaults setObject:self.storeToken forKey:kUserDefaultsKeyStoreToken];
    [userDefaults setObject:self.tokenExpireDate forKey:kUserDefaultsKeyTokenExpireDate];
    [userDefaults synchronize];
}

- (void)loadCredential
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.accessToken = [userDefaults objectForKey:kUserDefaultsKeyAccessToken];
    self.storeToken = [userDefaults objectForKey:kUserDefaultsKeyStoreToken];
    self.tokenExpireDate = [userDefaults objectForKey:kUserDefaultsKeyTokenExpireDate];
}

- (void)removeCredential
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:kUserDefaultsKeyAccessToken];
    [userDefaults removeObjectForKey:kUserDefaultsKeyStoreToken];
    [userDefaults removeObjectForKey:kUserDefaultsKeyTokenExpireDate];
    [userDefaults synchronize];
}

- (void)saveLogInInfo:(NSDictionary *)data
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults removeObjectForKey:kTodoUserDefaultKeyStoreToken];
    [userDefaults removeObjectForKey:kTodoUserDefaultKeyUserId];
    [userDefaults synchronize];

    [userDefaults setObject:data[@"_token"] forKey:kTodoUserDefaultKeyStoreToken];
    [userDefaults setObject:data[@"user_id"] forKey:kTodoUserDefaultKeyUserId];
    [userDefaults setObject:data[@"type"] forKey:kTodoUserDefaultKeyTypeLogin];
    [userDefaults synchronize];
}

- (NSDictionary *)loadLogInInfo
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.storeToken = [userDefaults objectForKey:kTodoUserDefaultKeyStoreToken];
    self.userId = [userDefaults objectForKey:kTodoUserDefaultKeyUserId];
    
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    
    [data setValue:self.storeToken forKey:@"_token"];
    [data setValue:self.userId forKey:@"user_id"];
    [data setValue:[userDefaults objectForKey:@"TypeLogin"] forKey:@"type"];

    return data;
}

@end
