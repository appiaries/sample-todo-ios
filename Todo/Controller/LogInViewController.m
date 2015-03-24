//
//  ViewController.m
//  Todo
//
//  Created by Appiaries Corporation on 14/10/14.
//  Copyright (c) 2014 Appiaries Corporation. All rights reserved.
//

#import "LogInViewController.h"
#import "TodoUsers.h"
#import "UserManager.h"
#import "TodoAPIClient.h"
#import "MBProgressHUD.h"


@implementation LogInViewController
@synthesize tfID, tfPassWord, btnLogIn, lbErrMessage;

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[self.btnLogIn layer] setCornerRadius:7.0f];
    [[self.btnLogIn layer] setMasksToBounds:YES];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}

#pragma mark - Actions
- (IBAction)logIn:(id)sender
{
    NSLog(@" button Login Click");
    
    if ([self validAccountWithId:tfID.text andPassWord:tfPassWord.text]) {
        //TODO execute after check password
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        TodoUsers *todoInfo = [[TodoUsers alloc] init];
        todoInfo.loginId = tfID.text;
        todoInfo.password = tfPassWord.text;
        
        [[UserManager sharedManager] doLogin:todoInfo WithCompletion:^(NSDictionary *completeBlock){
                    NSLog(@"log in successful");
                    [MBProgressHUD hideAllHUDsForView:self.view animated:NO];

                    UINavigationController *naviViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"NavigationControllerDailyList"];
                    [self presentViewController:naviViewController animated:YES completion:nil];

                    NSDictionary *dictionary = @{
                            @"user_id" : completeBlock[@"_id"],
                            @"_token"  : completeBlock[@"_token"],
                            @"type"    : @0
                    };

                    [[TodoAPIClient sharedClient] saveLogInInfo:dictionary];

        } failBlock:^(NSError * error){
            NSLog(@"Log in fail");
            [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
            [lbErrMessage setText:error.localizedDescription];
        }];
        
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

#pragma mark - MISC
- (BOOL)validAccountWithId:(NSString *)strID andPassWord:(NSString *)strPassWord
{
    [lbErrMessage setText:@""];
    tfID.layer.borderColor=[[UIColor blackColor]CGColor];
    tfPassWord.layer.borderColor=[[UIColor blackColor]CGColor];
    tfID.layer.borderWidth = 0;
    tfPassWord.layer.borderWidth = 0;

    BOOL retFlag = YES;

    //valid do not input ID
    if (strID == nil || [strID length] == 0 ) {
        NSLog(@"ID is blank");
        tfID.layer.borderColor=[[UIColor redColor]CGColor];
        tfID.layer.borderWidth = 1.0;
        retFlag = NO;
    }

    //valid input length id
    if ([strID length] < 3 || [strID length] > 20) {
        NSLog(@"ID invalid length");
        tfID.layer.borderColor=[[UIColor redColor]CGColor];
        tfID.layer.borderWidth = 1.0;
        retFlag = NO;
    }

    //valid do not input password
    if (strPassWord == nil || [strPassWord length] == 0) {
        NSLog(@"password is blank");
        tfPassWord.layer.borderColor=[[UIColor redColor]CGColor];
        tfPassWord.layer.borderWidth = 1.0;
        retFlag = NO;
    }

    //valid input length password
    if ([strPassWord length] < 6 || [strPassWord length] > 20) {
        NSLog(@"Password invalid length");
        tfPassWord.layer.borderColor=[[UIColor redColor]CGColor];
        tfPassWord.layer.borderWidth = 1.0;
        retFlag = NO;
    }

    return retFlag;
}

@end
