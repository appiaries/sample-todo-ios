//
//  TopViewController.m
//  Todo
//
//  Created by Appiaries Corporation on 12/8/14.
//  Copyright (c) 2014 Appiaries Corporation. All rights reserved.
//

#import "TopViewController.h"
#import <AppiariesSDK/APISTwitterUtils.h>
#import "LogInViewController.h"
#import "TodoAPIClient.h"


@implementation TopViewController

#pragma mark - initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];

    [[self.btnLogin layer] setCornerRadius:7.0f];
    [[self.btnLogin layer] setMasksToBounds:YES];
    
    [[self.btnRegister layer] setCornerRadius:7.0f];
    [[self.btnRegister layer] setMasksToBounds:YES];
    
    NSDictionary *info = [[TodoAPIClient sharedClient]loadLogInInfo];
    
    if (info[@"type"] != nil) {
        if ([info[@"type"] integerValue] == 0) {
            self.btnLogin.alpha = 1;
            self.btnRegister.alpha = 1;
            self.btnLoginFacebook.alpha = 0;
            self.btnLoginTwitter.alpha = 0;
        } else if ([info[@"type"] integerValue] == 1) {
            self.btnLoginFacebook.alpha = 1;
            self.btnLoginTwitter.alpha = 1;
            self.btnLogin.alpha = 0;
            self.btnRegister.alpha = 0;
        }
    } else {
        self.btnLogin.alpha = 1;
        self.btnRegister.alpha = 1;
        self.btnLoginFacebook.alpha = 1;
        self.btnLoginTwitter.alpha = 1;
        
        CGRect frame = self.btnLoginFacebook.frame;
        frame.origin.y = 230;
        self.btnLoginFacebook.frame = frame;
        frame.origin.y = 283;
        self.btnLoginTwitter.frame = frame;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gotoLogin)
                                                 name:@"GotoLoginNotification"
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.title = @"";
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.title = @"戻る";
}

#pragma mark - Memory management
- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Actions
- (IBAction)actionLoginFaceBook:(id)sender
{
    // 会員ログイン(SNS連携)APIの実行
    [APISFacebookUtils logInWithPermissions:@[@"email"]
                                  autoLogin:YES // 自動ログインフラグ (YES=自動ログインする)
                                     target:self
                                   selector:@selector(didLogInFacebook:error:)];
}

- (IBAction)actionLoginTwitter:(id)sender
{
    // 会員ログイン(SNS連携)APIの実行
    [APISTwitterUtils logInWithAutoLogin:YES // 自動ログインフラグ (YES=自動ログインする)
                                    target:self
                                  selector:@selector(didLogInTwitter:error:)];
}

#pragma mark - API Callback handlers
// 会員ログイン(SNS連携)APIコールバックハンドラ
- (void)didLogInFacebook:(APISResponseObject *)response error:(NSError *)error
{
    if (error) {
        if (error.code == APISResponseStatusCodeUnauthorized) {
            // ログインがキャンセルされた場合
            NSLog(@"Facebookアカウントで会員ログイン失敗 [原因:ログインがキャンセルされました。]");
        } else {
            // 認証時にエラーが発生した場合
            NSLog(@"Facebookアカウントで会員ログイン失敗 [原因:%@]", error.localizedDescription);
        }
        return;
    }
    // ログインに成功した場合
    if (response.statusCode == APISResponseStatusCodeCreated) {
        // サインアップ（会員登録＋ログイン）時
        NSLog(@"Facebookアカウントで会員ログイン成功 [ステータス:%ld, レスポンス:%@, ロケーション:%@]",
              (long)response.statusCode, response.data, response.location);
        [self loginSNS:response.data];
        
    } else {
        // サインイン（ログイン）時
        NSLog(@"Facebookアカウントで会員ログイン成功 [ステータス:%ld, レスポンス:%@]",
              (long)response.statusCode, response.data);
        [self loginSNS:response.data];
    }
}

// 会員ログイン(SNS連携)APIコールバックハンドラ
- (void)didLogInTwitter:(APISResponseObject *)response error:(NSError *)error
{
    if (error) {
        if (error.code == APISResponseStatusCodeUnauthorized) {
            // ログインがキャンセルされた場合
            NSLog(@"Twitterアカウントで会員ログイン失敗 [原因:ログインがキャンセルされました。]");
        } else {
            // 認証時にエラーが発生した場合
            NSLog(@"Twitterアカウントで会員ログイン失敗 [原因:%@]", error.localizedDescription);
        }
        return;
    }
    // ログインに成功した場合
    if (response.statusCode == APISResponseStatusCodeCreated) {
        // サインアップ（会員登録＋ログイン）時
        NSLog(@"Twitterアカウントで会員ログイン成功 [ステータス:%ld, レスポンス:%@, ロケーション:%@]",
              (long)response.statusCode, response.data, response.location);
        [self loginSNS:response.data];

    } else {
        // サインイン（ログイン）時
        NSLog(@"Twitterアカウントで会員ログイン成功 [ステータス:%ld, レスポンス:%@]",
              (long)response.statusCode, response.data);
        [self loginSNS:response.data];
    }
}

#pragma mark - MISC
- (void)gotoLogin
{
    LogInViewController *loginController = [self.storyboard instantiateViewControllerWithIdentifier:@"LogInView"];
    [self.navigationController pushViewController:loginController animated:YES];
}

- (void)loginSNS:(NSDictionary *)info
{
    NSDictionary *dictionary = @{
            @"user_id" : info[@"_id"],
            @"_token"  : info[@"_token"],
            @"type"    : @1
    };
    [[TodoAPIClient sharedClient] saveLogInInfo:dictionary];
    UINavigationController *naviViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"NavigationControllerDailyList"];
    [self presentViewController:naviViewController animated:YES completion:nil];
}

@end
