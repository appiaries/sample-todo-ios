//
//  SignUpViewController.m
//  Todo
//
//  Created by Appiaries Corporation on 11/13/14.
//  Copyright (c) 2014 Appiaries Corporation. All rights reserved.
//

#import "SignUpViewController.h"
#import "MBProgressHUD.h"
#import "User.h"
#import "Validator.h"
#import "UIAlertView+SHAlertViewBlocks.h"

@implementation SignUpViewController
@synthesize lbError, tfEmail, tfId, tfPassword;

static NSString *const INVALID_INFORMATION = @"入力された内容に誤りがあります。";

CGFloat animatedDistance;

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 150;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;


#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupView];
}

#pragma mark - Actions
- (IBAction)registNewID:(id)btnRegist
{
    NSLog(@"button regist clicked");
    
    //validation data
    if ([self validate]) {
        
        if ([tfId.text length] < 4 || [tfId.text length] > 20) {
            [[[UIAlertView alloc] initWithTitle:@"ご確認"
                                       message:@"IDは4桁から20桁である必要があります"
                                      delegate:nil
                             cancelButtonTitle:@"OK"
                             otherButtonTitles:nil
            ] show];

        } else if ([tfPassword.text length] < 8 || [tfPassword.text length] > 20) {
            [[[UIAlertView alloc] initWithTitle:@"ご確認"
                                        message:@"パスワードは8桁から20桁である必要があります"
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil
            ] show];

        } else {
            //regist new account
            User *user = [User user];
            user.loginId  = tfId.text;
            user.email    = tfEmail.text;
            user.password = tfPassword.text;

            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [user signUpWithBlock:^(ABResult *ret, ABError *err){
                [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
                if (err == nil) {
                    [[UIAlertView SH_alertViewWithTitle:@"ご確認"
                                            andMessage:@"ご案内のためのメールが送信されました。ご確認ください。"
                                          buttonTitles:nil
                                           cancelTitle:@"OK"
                                             withBlock:^(NSInteger buttonIndex){
                                                 if (buttonIndex == 0) {
                                                     [self.navigationController popToRootViewControllerAnimated:NO];
                                                     [[NSNotificationCenter defaultCenter] postNotificationName:@"GotoLoginNotification" object:self];
                                                 }
                                             }
                    ] show];
                } else {
                    [lbError setText:[err localizedDescription]];
                }
            } option:ABUserSignUpOptionLogInAutomatically];
        }
    } else {
        NSLog(@"validation register form fail");
    }
    
    [self dismissKeyboard];
}

#pragma mark - UITextField delegates
/*
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect textFieldRect = [self.view.window convertRect:textField.bounds fromView:textField];
    CGRect viewRect = [self.view.window convertRect:self.view.bounds fromView:self.view];
    
    CGFloat midline = textFieldRect.origin.y + 0.5f * textFieldRect.size.height;
    CGFloat numerator = midline - viewRect.origin.y - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    CGFloat denominator = (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION) * viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;
    
    if (heightFraction < 0.0f) {
        heightFraction = 0.0f;
    } else if (heightFraction > 1.0f) {
        heightFraction = 1.0f;
    }
    
    UIInterfaceOrientation orientation =
    [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait ||
        orientation == UIInterfaceOrientationPortraitUpsideDown) {
        animatedDistance = (CGFloat)floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
    } else {
        animatedDistance = (CGFloat)floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
    }
    
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y -= animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}
*/

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self registNewID:nil];
    return NO;
}

#pragma mark - Keyboard handlers
- (void)dismissKeyboard
{
    [tfEmail resignFirstResponder];
    [tfId resignFirstResponder];
    [tfPassword resignFirstResponder];
}

#pragma mark - MISC
- (void)setupView
{
    self.title = @"";

    tfId.delegate = self;
    tfEmail.delegate = self;
    tfPassword.delegate = self;
    tfPassword.secureTextEntry = YES;

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];

    [lbError setText:@""];
    [[self.btnRegist layer] setCornerRadius:7.0f];
    [[self.btnRegist layer] setMasksToBounds:YES];
}

- (BOOL)validate
{
    [lbError setText:@""];
    tfEmail.layer.borderColor = [UIColor blackColor].CGColor;
    tfId.layer.borderColor = [UIColor blackColor].CGColor;
    tfPassword.layer.borderColor = [UIColor blackColor].CGColor;

    tfEmail.layer.borderWidth = 0;
    tfId.layer.borderWidth = 0;
    tfPassword.layer.borderWidth = 0;

    BOOL retFlag = YES;

    ABError *err = nil;

    //valid email
    err = [Validator validateFor:@"Email"
                           value:tfEmail.text
                           rules:@[@(ValidationRuleRequired), @(ValidationRuleEmail)]
                        ruleArgs:@{@(ValidationRuleRequired):@{@"msg":INVALID_INFORMATION}, @(ValidationRuleEmail):@{@"msg":INVALID_INFORMATION}}];
    if (err) {
        [lbError setText:INVALID_INFORMATION];
        tfEmail.layer.borderColor = [UIColor redColor].CGColor;
        tfEmail.layer.borderWidth = 1.0;
        retFlag = NO;
    }

    //valid loginId
    err = [Validator validateFor:@"ID"
                           value:tfId.text
                           rules:@[@(ValidationRuleRequired), @(ValidationRuleLoginId)]
                        ruleArgs:@{@(ValidationRuleRequired):@{@"msg":INVALID_INFORMATION}, @(ValidationRuleLoginId):@{@"msg":INVALID_INFORMATION}}];
    if (err) {
        [lbError setText:INVALID_INFORMATION];
        tfId.layer.borderColor = [UIColor redColor].CGColor;
        tfId.layer.borderWidth = 1.0;
        retFlag = NO;
    }

    //valid password
    err = [Validator validateFor:@"Password"
                           value:tfPassword.text
                           rules:@[@(ValidationRuleRequired), @(ValidationRulePassword)]
                        ruleArgs:@{@(ValidationRuleRequired):@{@"msg":INVALID_INFORMATION}, @(ValidationRulePassword):@{@"msg":INVALID_INFORMATION}}];
    if (err) {
        [lbError setText:INVALID_INFORMATION];
        tfPassword.layer.borderColor = [UIColor redColor].CGColor;
        tfPassword.layer.borderWidth = 1.0;
        retFlag = NO;
    }

    return retFlag;
}

@end
