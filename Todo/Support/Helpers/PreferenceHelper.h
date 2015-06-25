//
//  PreferenceHelper.h
//  Todo
//
//  Created by Appiaries Corporation on 12/10/14.
//  Copyright (c) 2014 Appiaries Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFHTTPSessionManager.h>

@interface PreferenceHelper : NSObject

+ (id)sharedPreference;

//- (void)saveLogInInfo:(NSDictionary *)data;
//- (NSDictionary *)loadLogInInfo;

- (NSString *)loadUserId;
- (void)saveUserId:(NSString *)userId;

- (NSString *)loadToken;
- (void)saveToken:(NSString *)token;

- (int)loadLoginType;
- (void)saveLoginType:(int)type;

@end
