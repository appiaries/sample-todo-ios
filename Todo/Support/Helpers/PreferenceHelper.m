//
//  PreferenceHelper.m
//  Todo
//
//  Created by Appiaries Corporation on 12/10/14.
//  Copyright (c) 2014 Appiaries Corporation. All rights reserved.
//

#import "PreferenceHelper.h"

/**
* UserDefaults key
*/
//static NSString *const kUserDefaultsKeyAccessToken     = @"TODOAccessToken";
//static NSString *const kUserDefaultsKeyStoreToken      = @"TODOStoreToken";
//static NSString *const kUserDefaultsKeyTokenExpireDate = @"TODOTokenExpireDate";
static NSString *const kPreferenceStoreTokenKey = @"TodoStoreToken";
static NSString *const kPreferenceUserIdKey     = @"TodoUserId";
static NSString *const kPreferenceLoginTypeKey  = @"TypeLogin"; //NOTE: 0:通常ログイン, 1:SNSログイン(Twitter or Facebook)

@interface PreferenceHelper ()
#pragma mark - Properties (Private)
@property (nonatomic, readwrite) NSString *accessToken;
@property (nonatomic, readwrite) NSString *storeToken;
//@property (nonatomic, readwrite) NSDate *tokenExpireDate;
@property (nonatomic, readwrite) NSString *userId;
@end


@implementation PreferenceHelper

#pragma mark - Initialization
+ (instancetype)sharedPreference
{
    static PreferenceHelper *_sharedPreference = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedPreference = [[PreferenceHelper alloc] initSharedPreference];
    });
    return _sharedPreference;
}

- (instancetype)initSharedPreference
{
    if (self = [super init]) { }
    return self;
}

- (id)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - Private methods
/*
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
*/
/*
- (void)saveLogInInfo:(NSDictionary *)data
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    [userDefaults removeObjectForKey:kPreferenceStoreTokenKey];
    [userDefaults removeObjectForKey:kPreferenceUserIdKey];
    [userDefaults synchronize];

    [userDefaults setObject:data[@"_token"] forKey:kPreferenceStoreTokenKey];
    [userDefaults setObject:data[@"user_id"] forKey:kPreferenceUserIdKey];
    [userDefaults setObject:data[@"type"] forKey:kPreferenceLoginTypeKey];
    [userDefaults synchronize];
}

- (NSDictionary *)loadLogInInfo
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.storeToken = [userDefaults objectForKey:kPreferenceStoreTokenKey];
    self.userId = [userDefaults objectForKey:kPreferenceUserIdKey];
    
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    
    [data setValue:self.storeToken forKey:@"_token"];
    [data setValue:self.userId forKey:@"user_id"];
    [data setValue:[userDefaults objectForKey:@"TypeLogin"] forKey:@"type"];

    return data;
}
*/

- (NSString *)loadUserId {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kPreferenceUserIdKey];
}
- (void)saveUserId:(NSString *)userId {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:userId forKey:kPreferenceUserIdKey];
}

- (NSString *)loadToken {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kPreferenceStoreTokenKey];
}
- (void)saveToken:(NSString *)token {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:token forKey:kPreferenceStoreTokenKey];
}

- (int)loadLoginType {
    NSNumber *val = [[NSUserDefaults standardUserDefaults] objectForKey:kPreferenceLoginTypeKey];
    if (val) {
        return [val intValue];
    } else {
        return -1;
    }
}
- (void)saveLoginType:(int)type {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (type == 0 || type == 1) {
        [defaults setInteger:type forKey:kPreferenceLoginTypeKey];
    } else {
        [defaults setInteger:-1 forKey:kPreferenceLoginTypeKey];
    }
}

@end
