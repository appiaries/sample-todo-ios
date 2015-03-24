//
//  AppDelegate.m
//  Todo
//
//  Created by Appiaries Corporation on 14/10/14.
//  Copyright (c) 2014 Appiaries Corporation. All rights reserved.
//

#import "TodoDelegate.h"
#import <AppiariesSDK/APISTwitterUtils.h>

@implementation TodoDelegate

#pragma mark - Application lifecycle
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // セッションの初期化
    [[APISSession sharedSession] configureWithDatastoreId:TODOAPISDatastoreId  // アピアリーズのデータストアID
                                            applicationId:TODOAPISAppId        // アピアリーズのアプリID
                                         applicationToken:TODOAPISAppToken];   // アピアリーズのアプリトークン
    // APISFacebookUtilsの初期化
    [APISFacebookUtils initializeFacebook];
    
    // APISTwitterUtilsの初期化
    [APISTwitterUtils initializeWithConsumerKey:TODOTwitterKey      // Twitter Appsサイトで登録したアプリのコンシューマ・キー
                                 consumerSecret:TODOTwitterSecret]; // Twitter Appsサイトで登録したアプリのコンシューマ・シークレット

    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    // Facebook連携用リクエストを捕捉する
    return [APISFacebookUtils handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    // Facebook連携用リクエストを捕捉する
    return [APISFacebookUtils handleOpenURL:url];
}

@end
