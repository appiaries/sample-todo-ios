//
// Created by Appiaries Corporation on 15/03/18.
// Copyright (c) 2015 Appiaries Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppiariesSDK/ABConstants.h>
#import <AppiariesFBKit/ABFBConstants.h>


@class ABFacebookConfig;
@class ABError;
@class FBSession;
@class FBAccessTokenData;

/*
 Facebook 連携用クライアント

 __See Also__: [アピアリーズドキュメント &raquo; SNS連携](http://docs.appiaries.com/?p=11373)
 */
@interface ABFacebookClient : NSObject
#pragma mark - Properties
/*
 Facebook 設定
 */
@property (weak, nonatomic) ABFacebookConfig *config;
/*
 Facebook セッション
 */
@property (weak, nonatomic) FBSession *session;

#pragma mark - Initialization
/*
 ABFacebookClient のシングルトン・インスタンスを返す
 @discussion ABFacebookClient のシングルトン・インスタンスを返します。
 @return ABFacebookClient のシングルトン・インスタンス
 */
+ (instancetype)sharedClient;

#pragma mark - Public methods
- (void)requestAuthDataWithPermissions:(NSArray *)permissions completionHandler:(ABResultBlock)handler option:(ABUserLogInOption)option;
- (void)requestAuthDataWithAccessToken:(FBAccessTokenData *)accessTokenData completionHandler:(ABResultBlock)handler option:(ABUserLogInOption)option;
- (void)verifyAccessToken:(NSString *)accessToken expirationDate:(NSDate *)expirationDate facebookId:(NSString *)facebookId handler:(void(^)(BOOL isValid, ABError *error))handler option:(ABUserLogInOption)option;

@end