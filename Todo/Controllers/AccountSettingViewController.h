//
//  AccountSettingViewController.h
//  Todo
//
//  Created by Appiaries Corporation on 12/11/14.
//  Copyright (c) 2014 Appiaries Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@class User;

@interface AccountSettingViewController : UIViewController <UITextFieldDelegate, UIAlertViewDelegate>
#pragma mark - Properties
@property (weak, nonatomic) IBOutlet UILabel *lbError;
@property (weak, nonatomic) IBOutlet UITextField *txtLogInMail;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) IBOutlet UIButton *btnOK;
@property (weak, nonatomic) IBOutlet UILabel *lbUserID;

#pragma mark - Actions
- (IBAction)actionOK:(id)sender;

@end
