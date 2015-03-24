//
//  AccountViewController.m
//  Todo
//
//  Created by Appiaries Corporation on 12/11/14.
//  Copyright (c) 2014 Appiaries Corporation. All rights reserved.
//

#import "AccountViewController.h"
#import "TodoAPIClient.h"
#import "UserManager.h"
#import "MBProgressHUD.h"

#define TAG_ALERT_SUCCESSFUL 99
NSString *INVALID = @"入力して下さい";


@implementation AccountViewController

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
    
    [self getUserLogin];

    self.txtPassword.delegate = self;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}

#pragma mark - Actions
- (IBAction)actionOK:(id)sender
{
    if ([self dataValidation]) {
     
        if ([self.txtPassword.text length] < 8 || [self.txtPassword.text length] > 20) {
            [[[UIAlertView alloc] initWithTitle:@"ご確認"
                                        message:@"パスワードは8桁から20桁である必要があります"
                                       delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil, nil
            ] show];
            return;
        }
        
        currentAppUser.email = self.txtLogInMail.text;
        if (![self.txtPassword.text isEqualToString:@"******"]) {
            currentAppUser.password = self.txtPassword.text;
        }
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[UserManager sharedManager]updateUser:currentAppUser withCompletion:^(NSDictionary *userInfo){
            if (userInfo != nil) {
                if (![currentEmailLogin isEqualToString:self.txtLogInMail.text]) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"ご確認"
                                                                        message:@"ご案内のためのメールが送信されました。ご確認下さい。"
                                                                       delegate:self
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil, nil];
                    alertView.tag = TAG_ALERT_SUCCESSFUL;
                    [alertView show];
                } else {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"BackToLoginNotification" object:self];
                }
            }
            [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
        } failedBlock:^(NSError * block){
            if (block != nil) {
                NSLog(@"Update user failed");
                [self.lbError setText:INVALID];
                [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
            }
        }];
    }
}

#pragma mark - UITextField delegates
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.txtPassword.text = @"";
    return YES;
}

#pragma mark - UIAlertView delegates
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == TAG_ALERT_SUCCESSFUL) {
        if (buttonIndex == 0) {
            [self.navigationController popToRootViewControllerAnimated:NO];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"BackToLoginNotification" object:self];
        }
    }
}

#pragma mark - Keyboard handlers
- (void)dismissKeyboard
{
    [self.txtLogInMail resignFirstResponder];
    [self.txtPassword resignFirstResponder];
}

#pragma mark - MISC
- (void)getUserLogin
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[UserManager sharedManager]getUserWithCompletion:^(NSDictionary *userInfo){
        if (userInfo != nil) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:NO];

            [self initCurrentAppUser:userInfo];

            self.txtLogInMail.text = userInfo[@"email"];
            self.lbUserID.text = userInfo[@"login_id"];
            self.txtPassword.text = @"******";
            self.txtPassword.secureTextEntry = YES;

            currentEmailLogin = self.txtLogInMail.text;
        }
    } failedBlock:^(NSError * block){
        if (block != nil) {
            NSLog(@"get player failed");
            [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
        }
    }];
}

- (void)initCurrentAppUser:(NSDictionary *)userInfo
{
    NSDictionary *info = [[TodoAPIClient sharedClient]loadLogInInfo];

    currentAppUser = [[APISAppUser alloc] init];
    currentAppUser.id         = userInfo[@"_id"];
    currentAppUser.loginId    = userInfo[@"login_id"];
    currentAppUser.email      = userInfo[@"email"];
    currentAppUser.storeToken = info[@"_token"];

    NSMutableDictionary *attribute = [[NSMutableDictionary alloc] init];
    [attribute setValue:userInfo[@"nickname"] forKey:@"nickname"];
    currentAppUser.attributes = attribute;
}

- (BOOL)dataValidation
{
    [self.lbError setText:@""];
    self.txtLogInMail.layer.borderColor=[[UIColor blackColor]CGColor];
    self.txtPassword.layer.borderColor=[[UIColor blackColor]CGColor];

    self.txtLogInMail.layer.borderWidth = 0;
    self.txtPassword.layer.borderWidth  = 0;

    BOOL retFlag = YES;

    //valid email type
    if (![self validateEmail:self.txtLogInMail.text]) {
        retFlag = NO;
        self.txtLogInMail.layer.borderColor = [[UIColor redColor]CGColor];
        self.txtLogInMail.layer.borderWidth = 1.0;
        [self.lbError setText:INVALID];
    }

    if (self.txtPassword.text == nil || [self.txtPassword.text length] == 0) {
        retFlag = NO;
        self.txtPassword.layer.borderColor = [[UIColor redColor]CGColor];
        self.txtPassword.layer.borderWidth = 1.0;
        [self.lbError setText:INVALID];
    }
    if ([self.txtLogInMail.text isEqualToString:currentEmailLogin] && [self.txtPassword.text isEqualToString:@"******"]) {
        self.txtLogInMail.layer.borderColor = [[UIColor redColor]CGColor];
        self.txtLogInMail.layer.borderWidth = 1.0;
        self.txtPassword.layer.borderColor = [[UIColor redColor]CGColor];
        self.txtPassword.layer.borderWidth = 1.0;
        [self.lbError setText:INVALID];
        retFlag = NO;
    }

    return retFlag;
}

- (BOOL)validateEmail:(NSString *)candidate
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:candidate];
}

@end
