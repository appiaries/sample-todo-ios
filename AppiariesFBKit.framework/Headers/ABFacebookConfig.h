//
// Created by Appiaries Corporation on 15/03/18.
// Copyright (c) 2015 Appiaries Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FBSessionTokenCachingStrategy;

/*!
 Facebook 連携用設定クラス
 
 __See Also__: [アピアリーズドキュメント &raquo; SNS連携](http://docs.appiaries.com/?p=11373)
 */
@interface ABFacebookConfig : NSObject
#pragma mark - Properties
@property (strong, nonatomic) NSString *appID;
@property (strong, nonatomic) NSArray *permissions;
@property (strong, nonatomic) NSString *urlSchemeSuffix;
@property (strong, nonatomic) FBSessionTokenCachingStrategy *tokenCacheStrategy;

#pragma mark - Initialization
+ (instancetype)sharedConfig;

@end