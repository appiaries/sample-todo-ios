//
//  TopViewController.m
//  Todo
//
//  Created by Appiaries Corporation on 12/8/14.
//  Copyright (c) 2014 Appiaries Corporation. All rights reserved.
//

#import "TopViewController.h"
#import "LogInViewController.h"
#import "PreferenceHelper.h"

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

    [self setupView];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gotoLogin)
                                                 name:@"GotoLoginNotification"
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title = @"";
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
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
    [baas.service.facebook logInWithBlock:^(ABResult *ret, ABError *error){
        if (error) {
            if (error.code == ABResponseStatusCodeUnauthorized) {
                // ログインがキャンセルされた場合
                NSLog(@"Facebookアカウントで会員ログイン失敗 [原因:ログインがキャンセルされました。]");
            } else {
                // 認証時にエラーが発生した場合
                NSLog(@"Facebookアカウントで会員ログイン失敗 [原因:%@]", error.localizedDescription);
            }
            return;
        }
        // ログインに成功した場合
        if (ret.code == ABResponseStatusCodeCreated) {
            // サインアップ（会員登録＋ログイン）時
            NSLog(@"Facebookアカウントで会員ログイン成功 [ステータス:%ld, レスポンス:%@]", (long)ret.code, ret.data);
            [self loginSNS:ret.data];

        } else {
            // サインイン（ログイン）時
            NSLog(@"Facebookアカウントで会員ログイン成功 [ステータス:%ld, レスポンス:%@]", (long)ret.code, ret.data);
            [self loginSNS:ret.data];
        }
    } option:ABUserLogInOptionLogInAutomatically];
}

- (IBAction)actionLoginTwitter:(id)sender
{
    [baas.service.twitter logInWithBlock:^(ABResult *ret, ABError *error){
        if (error) {
            if (error.code == ABResponseStatusCodeUnauthorized) {
                // ログインがキャンセルされた場合
                NSLog(@"Twitterアカウントで会員ログイン失敗 [原因:ログインがキャンセルされました。]");
            } else {
                // 認証時にエラーが発生した場合
                NSLog(@"Twitterアカウントで会員ログイン失敗 [原因:%@]", error.localizedDescription);
            }
            return;
        }
        // ログインに成功した場合
        if (ret.code == ABResponseStatusCodeCreated) {
            // サインアップ（会員登録＋ログイン）時
            NSLog(@"Twitterアカウントで会員ログイン成功 [ステータス:%ld, レスポンス:%@]", (long)ret.code, ret.data);
            [self loginSNS:ret.data];

        } else {
            // サインイン（ログイン）時
            NSLog(@"Twitterアカウントで会員ログイン成功 [ステータス:%ld, レスポンス:%@]", (long)ret.code, ret.data);
            [self loginSNS:ret.data];
        }
    } option:ABUserLogInOptionLogInAutomatically];
}

#pragma mark - MISC
- (void)setupView
{
    [[self.btnLogin layer] setCornerRadius:7.0f];
    [[self.btnLogin layer] setMasksToBounds:YES];

    [[self.btnRegister layer] setCornerRadius:7.0f];
    [[self.btnRegister layer] setMasksToBounds:YES];

    int loginType = [[PreferenceHelper sharedPreference] loadLoginType];
    switch (loginType) {
        case 0: //Normal
            self.btnLogin.alpha = 1;
            self.btnRegister.alpha = 1;
            self.btnLoginFacebook.alpha = 0;
            self.btnLoginTwitter.alpha = 0;
            break;
        case 1: //SNS
            self.btnLogin.alpha = 0;
            self.btnRegister.alpha = 0;
            self.btnLoginFacebook.alpha = 1;
            self.btnLoginTwitter.alpha = 1;
            break;
        default:
            self.btnLogin.alpha = 1;
            self.btnRegister.alpha = 1;
            self.btnLoginFacebook.alpha = 1;
            self.btnLoginTwitter.alpha = 1;

            CGRect frame = self.btnLoginFacebook.frame;
            frame.origin.y = 230;
            self.btnLoginFacebook.frame = frame;
            frame.origin.y = 283;
            self.btnLoginTwitter.frame = frame;
            break;
    }
}

- (void)gotoLogin
{
    LogInViewController *loginController = [self.storyboard instantiateViewControllerWithIdentifier:@"LogInView"];
    [self.navigationController pushViewController:loginController animated:YES];
}

- (void)loginSNS:(NSDictionary *)info
{
    //TODO: このあたりのコードの必要性を再検討する
    PreferenceHelper *pref = [PreferenceHelper sharedPreference];
    [pref saveUserId:info[@"_id"]];
    [pref saveToken:info[@"_token"]];
    [pref saveLoginType:1];

    UINavigationController *naviViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"NavigationControllerTaskList"];
    [self presentViewController:naviViewController animated:YES completion:nil];
}

@end
