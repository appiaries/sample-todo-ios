//
//  AppDelegate.m
//  Todo
//
//  Created by Appiaries Corporation on 14/10/14.
//  Copyright (c) 2014 Appiaries Corporation. All rights reserved.
//

#import "AppDelegate.h"
#import "Task.h"
#import "User.h"

@implementation AppDelegate

#pragma mark - Application lifecycle
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //>> Twitter Configurations
    baas.config.twitter.consumerKey    = kTwitterConsumerKey;
    baas.config.twitter.consumerSecret = kTwitterConsumerSecret;
    //>> Facebook Configurations
    //baas.config.facebook.appID         = kFacebookAppID;
    baas.config.facebook.permissions     = kFacebookPermissions;
    baas.config.facebook.urlSchemeSuffix = kFacebookUrlSchemeSuffix;
    //>> カスタム・ユーザクラスを指定
//    baas.config.userClass = [User class];
    // SDKの初期化
    baas.config.datastoreID      = kDatastoreID;
    baas.config.applicationID    = kApplicationID;
    baas.config.applicationToken = kApplicationToken;
    [baas activate];

    [baas registerClasses:@[[Task class], [User class]]];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    // Facebook連携用リクエストを捕捉する
    return [baas.service.facebook handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    // Facebook連携用リクエストを捕捉する
    return [baas.service.facebook handleOpenURL:url];
}


@end
