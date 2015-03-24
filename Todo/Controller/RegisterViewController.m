//
//  RegisterViewController.m
//  Todo
//
//  Created by Appiaries Corporation on 11/13/14.
//  Copyright (c) 2014 Appiaries Corporation. All rights reserved.
//

#import "RegisterViewController.h"
#import "TodoUsers.h"
#import "UserManager.h"
#import "MBProgressHUD.h"

#define TAG_ALERT_SUCCESSFUL 99

NSString *INVALID_INFORMATION = @"入力された内容に誤りがあります。";

CGFloat animatedDistance;

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 150;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;


@implementation RegisterViewController
@synthesize lbError, tfEmail, tfId, tfPassword;

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    tfPassword.delegate = self;
    tfPassword.secureTextEntry = YES;
    
    [self tapOut];
    
    self.title = @"";
    [lbError setText:@""];
    [[self.btnRegist layer] setCornerRadius:7.0f];
    [[self.btnRegist layer] setMasksToBounds:YES];
}

#pragma mark - Actions
- (IBAction)registNewID:(id)btnRegist
{
    NSLog(@"button regist clicked");
    
    //validation data
    if ([self dataValidation]) {
        
        if ([tfId.text length] < 4 || [tfId.text length] > 20) {
            [[[UIAlertView alloc] initWithTitle:@"ご確認"
                                        message:@"IDは4桁から20桁である必要があります"
                                       delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil, nil
            ] show];

        } else if ([tfPassword.text length] < 8 || [tfPassword.text length] > 20) {
            [[[UIAlertView alloc] initWithTitle:@"ご確認"
                                        message:@"パスワードは8桁から20桁である必要があります"
                                       delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil, nil
            ] show];

        } else {
            //regist new account
            TodoUsers *todoInfo = [[TodoUsers alloc] init];
            todoInfo.loginId = tfId.text;
            todoInfo.email = tfEmail.text;
            todoInfo.password = tfPassword.text;
            
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [[UserManager sharedManager] createUser:todoInfo withBlock:^(NSError *error){
                [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
                if (error != nil) {
                    [lbError setText:[error localizedDescription]];
                    NSLog(@"Error: %@", [error localizedDescription]);
                } else {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"ご確認"
                                                                        message:@"ご案内のためのメールが送信されました。ご確認下さい。"
                                                                       delegate:self
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil, nil];
                    alertView.tag = TAG_ALERT_SUCCESSFUL;
                    [alertView show];
                }
            }];
        }
    } else {
        NSLog(@"validation register form fail");
    }
    
    [self dismissKeyboard];
}

#pragma mark - UITextField delegates
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UIAlertView delegates
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == TAG_ALERT_SUCCESSFUL) {
        if (buttonIndex == 0) {
            [self.navigationController popToRootViewControllerAnimated:NO];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"GotoLoginNotification" object:self];
        }
    }
}

#pragma mark - Keyboard handlers
- (void)dismissKeyboard
{
    [tfEmail resignFirstResponder];
    [tfId resignFirstResponder];
    [tfPassword resignFirstResponder];
}

#pragma mark - MISC
- (void)tapOut
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}

- (BOOL)dataValidation
{
    [lbError setText:@""];
    tfEmail.layer.borderColor=[[UIColor blackColor]CGColor];
    tfId.layer.borderColor=[[UIColor blackColor]CGColor];
    tfPassword.layer.borderColor=[[UIColor blackColor]CGColor];

    tfEmail.layer.borderWidth = 0;
    tfId.layer.borderWidth = 0;
    tfPassword.layer.borderWidth = 0;

    BOOL retFlag = YES;

    //valid email nil or blank
    if (tfEmail.text == nil || [tfEmail.text length] == 0) {
        [lbError setText:INVALID_INFORMATION];
        tfEmail.layer.borderColor=[[UIColor redColor]CGColor];
        tfEmail.layer.borderWidth = 1.0;
        retFlag = NO;
    }

    //valid email type
    if (![self validateEmail:tfEmail.text]) {
        [lbError setText:INVALID_INFORMATION];
        tfEmail.layer.borderColor=[[UIColor redColor]CGColor];
        tfEmail.layer.borderWidth = 1.0;
        retFlag = NO;
    }

    //valid id nil or blank
    if (tfId.text == nil || [tfId.text length] == 0) {
        [lbError setText:INVALID_INFORMATION];
        tfId.layer.borderColor=[[UIColor redColor]CGColor];
        tfId.layer.borderWidth = 1.0;
        retFlag = NO;
    }

    //TODO valid id in use

    //valid password
    if (tfPassword.text == nil || [tfPassword.text length] == 0) {
        [lbError setText:INVALID_INFORMATION];
        tfPassword.layer.borderColor=[[UIColor redColor]CGColor];
        tfPassword.layer.borderWidth = 1.0;
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
