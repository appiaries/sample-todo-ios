//
// Created by Appiaries Corporation on 15/03/18.
// Copyright (c) 2015 Appiaries Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppiariesSDK/ABConstants.h>
#import <AppiariesFBKit/ABFBConstants.h>

/*!
 Facebook サービス
 
 __See Also__: [アピアリーズドキュメント &raquo; SNS連携](http://docs.appiaries.com/?p=11373)
 */
@interface ABFacebookService : NSObject

#pragma mark - Initialization
+ (instancetype)sharedService;

#pragma mark - Log-In
/** @name Public methods (LogIn) */
- (void)logInWithTarget:(id)target selector:(SEL)selector;
- (void)logInWithTarget:(id)target selector:(SEL)selector option:(ABUserLogInOption)option;
- (void)logInWithBlock:(ABResultBlock)block;
- (void)logInWithBlock:(ABResultBlock)block option:(ABUserLogInOption)option;
- (void)logInWithPermissions:(NSArray *)permissions target:(id)target selector:(SEL)selector;
- (void)logInWithPermissions:(NSArray *)permissions target:(id)target selector:(SEL)selector option:(ABUserLogInOption)option;
- (void)logInWithPermissions:(NSArray *)permissions block:(ABResultBlock)block;
- (void)logInWithPermissions:(NSArray *)permissions block:(ABResultBlock)block option:(ABUserLogInOption)option;
- (void)logInWithFacebookId:(NSString *)facebookId accessToken:(NSString *)accessToken expirationDate:(NSDate *)expirationDate target:(id)target selector:(SEL)selector;
- (void)logInWithFacebookId:(NSString *)facebookId accessToken:(NSString *)accessToken expirationDate:(NSDate *)expirationDate target:(id)target selector:(SEL)selector option:(ABUserLogInOption)option;
- (void)logInWithFacebookId:(NSString *)facebookId accessToken:(NSString *)accessToken expirationDate:(NSDate *)expirationDate block:(ABResultBlock)block;
- (void)logInWithFacebookId:(NSString *)facebookId accessToken:(NSString *)accessToken expirationDate:(NSDate *)expirationDate block:(ABResultBlock)block option:(ABUserLogInOption)option;

#pragma mark - Handle Open URL
- (BOOL)handleOpenURL:(NSURL *)url;

@end