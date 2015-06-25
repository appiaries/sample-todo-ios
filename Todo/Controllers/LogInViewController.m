//
//  ViewController.m
//  Todo
//
//  Created by Appiaries Corporation on 14/10/14.
//  Copyright (c) 2014 Appiaries Corporation. All rights reserved.
//

#import "LogInViewController.h"
#import "MBProgressHUD.h"
#import "User.h"
#import "PreferenceHelper.h"
#import "Validator.h"


@implementation LogInViewController
@synthesize tfID, tfPassWord, btnLogIn, lbErrMessage;

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupView];
}

#pragma mark - Actions
- (IBAction)logIn:(id)sender
{
    NSString *loginId = tfID.text;
    NSString *password = tfPassWord.text;

    if ([self validateAccountWithId:loginId andPassWord:password]) {

        User *user = [User user];
        user.loginId  = loginId;
        user.password = password;

        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [user logInWithBlock:^(ABResult *ret, ABError *err){
            [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
            if (err == nil) {
                User *loggedIn = ret.data;
                UINavigationController *naviViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"NavigationControllerTaskList"];
                [self presentViewController:naviViewController animated:YES completion:nil];
                //TODO: このあたりのコードの必要性を考える
                PreferenceHelper *pref = [PreferenceHelper sharedPreference];
                [pref saveUserId:loggedIn.ID];
                [pref saveToken:baas.session.token];
                [pref saveLoginType:0];
            } else {
                [lbErrMessage setText:err.localizedDescription];
            }
        } option:ABUserLogInOptionLogInAutomatically];

    } else {
        [lbErrMessage setText:@"入力された内容に誤りがあります。"];
    }
}

#pragma mark - Keyboard handlers
- (void)dismissKeyboard
{
    [tfID resignFirstResponder];
    [tfPassWord resignFirstResponder];
}

#pragma mark - UITextField delegates
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self logIn:nil];
    return NO;
}

#pragma mark - MISC
- (BOOL)validateAccountWithId:(NSString *)strID andPassWord:(NSString *)strPassWord
{
    [lbErrMessage setText:@""];
    tfID.delegate = self;
    tfID.layer.borderColor = [UIColor blackColor].CGColor;
    tfPassWord.layer.borderColor = [UIColor blackColor].CGColor;
    tfID.layer.borderWidth = 0;
    tfPassWord.layer.borderWidth = 0;

    BOOL retFlag = YES;

    //valid do not input ID
    if (strID == nil || [strID length] == 0 ) {
        NSLog(@"ID is blank");
        tfID.layer.borderColor = [UIColor redColor].CGColor;
        tfID.layer.borderWidth = 1.0;
        retFlag = NO;
    }

    //valid input length id
    if ([strID length] < 3 || [strID length] > 20) {
        NSLog(@"ID invalid length");
        tfID.layer.borderColor = [UIColor redColor].CGColor;
        tfID.layer.borderWidth = 1.0;
        retFlag = NO;
    }

    //valid do not input password
    if (strPassWord == nil || [strPassWord length] == 0) {
        NSLog(@"password is blank");
        tfPassWord.layer.borderColor = [UIColor redColor].CGColor;
        tfPassWord.layer.borderWidth = 1.0;
        retFlag = NO;
    }

    //valid input length password
    if ([strPassWord length] < 6 || [strPassWord length] > 20) {
        NSLog(@"Password invalid length");
        tfPassWord.layer.borderColor = [UIColor redColor].CGColor;
        tfPassWord.layer.borderWidth = 1.0;
        retFlag = NO;
    }

    ABError *err = nil;

    //valid loginId
    err = [Validator validateFor:@"ID"
                           value:tfID.text
                           rules:@[@(ValidationRuleRequired), @(ValidationRuleLoginId)]
                        ruleArgs:@{@(ValidationRuleRequired):@{@"msg":@"ID is blank"}, @(ValidationRuleLoginId):@{@"msg":@"Invalid ID"}}];
    if (err) {
        [lbErrMessage setText:err.localizedDescription];
        tfID.layer.borderColor = [UIColor redColor].CGColor;
        tfID.layer.borderWidth = 1.0;
        retFlag = NO;
    }

    //valid password
    err = [Validator validateFor:@"Password"
                           value:tfPassWord.text
                           rules:@[@(ValidationRuleRequired), @(ValidationRulePassword)]
                        ruleArgs:@{@(ValidationRuleRequired):@{@"msg":@"Password is blank"}, @(ValidationRulePassword):@{@"msg":@"Invalid Password"}}];
    if (err) {
        [lbErrMessage setText:err.localizedDescription];
        tfPassWord.layer.borderColor = [UIColor redColor].CGColor;
        tfPassWord.layer.borderWidth = 1.0;
        retFlag = NO;
    }

    return retFlag;
}

#pragma mark - Private methods
- (void)setupView {

    tfID.delegate = self;
    tfPassWord.delegate = self;

    [[self.btnLogIn layer] setCornerRadius:7.0f];
    [[self.btnLogIn layer] setMasksToBounds:YES];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}

@end
