//
//  AccountSettingViewController.m
//  Todo
//
//  Created by Appiaries Corporation on 12/11/14.
//  Copyright (c) 2014 Appiaries Corporation. All rights reserved.
//

#import "AccountSettingViewController.h"
#import "MBProgressHUD.h"
#import "User.h"
#import "Validator.h"
#import "UIAlertView+SHAlertViewBlocks.h"

@implementation AccountSettingViewController

static NSString *const INVALID_INFORMATION = @"入力された内容に誤りがあります。";

#pragma mark - Initialization
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

    User *user = (User *)baas.session.user;

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [baas.user fetch:user block:^(ABResult *ret, ABError *err){
        [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
        if (err == nil) {
            User *fetched = ret.data;
            if (fetched != nil) {
                self.txtLogInMail.text = fetched.email;
                self.lbUserID.text = fetched.loginId;
                self.txtPassword.text = @"******";
                self.txtPassword.secureTextEntry = YES;
            }
        } else {
            NSLog(@"get user failed");
        }
    }];
}

#pragma mark - Actions
- (IBAction)actionOK:(id)sender
{
    if (![self validate]) return;
    //TODO: password == "******" のチェック

    User *user = (User *)[baas.session.user copy];

    NSString *email = self.txtLogInMail.text;
    if (![user.email isEqualToString:email]) {
        user.email = email;
    }
    NSString *password = self.txtPassword.text;
    user.password = password;

    [user saveWithBlock:^(ABResult *ret, ABError *err){
        [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
        if (err == nil) {
            User *updated = ret.data;
            if (updated != nil) {
                //TODO: このあたりのチェックの意図がよくわからない
                NSString *emailInSession = baas.session.user.email;
                if (![emailInSession isEqualToString:self.txtLogInMail.text]) {
                    [[UIAlertView SH_alertViewWithTitle:@"ご確認"
                                            andMessage:@"ご案内のためのメールが送信されました。ご確認ください。"
                                          buttonTitles:nil cancelTitle:@"OK"
                                             withBlock:^(NSInteger buttonIndex){
                                                 if (buttonIndex == 0) {
                                                     [self.navigationController popToRootViewControllerAnimated:NO];
                                                     [[NSNotificationCenter defaultCenter] postNotificationName:@"BackToLoginNotification" object:self];
                                                 }
                                             }
                    ] show];
                } else {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"BackToLoginNotification" object:self];
                }
            }
        } else {
            [self.lbError setText:INVALID_INFORMATION];
        }
    }];
}

#pragma mark - UITextField delegates
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.txtPassword.text = @"";
    return YES;
}

#pragma mark - Keyboard handlers
- (void)dismissKeyboard
{
    [self.txtLogInMail resignFirstResponder];
    [self.txtPassword resignFirstResponder];
}

#pragma mark - MISC
- (void)setupView
{
    self.txtPassword.delegate = self;

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}

- (BOOL)validate
{
    [self.lbError setText:@""];
    self.txtLogInMail.layer.borderColor = [UIColor blackColor].CGColor;
    self.txtPassword.layer.borderColor = [UIColor blackColor].CGColor;

    self.txtLogInMail.layer.borderWidth = 0;
    self.txtPassword.layer.borderWidth  = 0;

    BOOL retFlag = YES;

    ABError *err = nil;

    //valid email
    err = [Validator validateFor:@"Email"
                           value:self.txtLogInMail.text
                           rules:@[@(ValidationRuleRequired), @(ValidationRuleEmail)]
                        ruleArgs:@{@(ValidationRuleRequired):@{@"msg":INVALID_INFORMATION}, @(ValidationRuleEmail):@{@"msg":INVALID_INFORMATION}}];
    if (err) {
        [self.lbError setText:INVALID_INFORMATION];
        self.txtLogInMail.layer.borderColor = [UIColor redColor].CGColor;
        self.txtLogInMail.layer.borderWidth = 1.0;
        retFlag = NO;
    }

    //valid password
    err = [Validator validateFor:@"Password"
                           value:self.txtPassword.text
                           rules:@[@(ValidationRuleRequired), @(ValidationRulePassword)]
                        ruleArgs:@{@(ValidationRuleRequired):@{@"msg":INVALID_INFORMATION}, @(ValidationRulePassword):@{@"msg":@"パスワードは8桁から20桁である必要があります。"}}];
    if (err) {
        [self.lbError setText:INVALID_INFORMATION];
        self.txtPassword.layer.borderColor = [UIColor redColor].CGColor;
        self.txtPassword.layer.borderWidth = 1.0;
        retFlag = NO;
    }

    //valid email & password combination
    NSString *emailInSession = baas.session.user.email;
    if ([self.txtLogInMail.text isEqualToString:emailInSession]
     && [self.txtPassword.text isEqualToString:@"******"]) {
        [self.lbError setText:INVALID_INFORMATION];
        self.txtLogInMail.layer.borderColor = [UIColor redColor].CGColor;
        self.txtLogInMail.layer.borderWidth = 1.0;
        self.txtPassword.layer.borderColor = [UIColor redColor].CGColor;
        self.txtPassword.layer.borderWidth = 1.0;
        retFlag = NO;
    }

    return retFlag;
}

@end
