//
//  ViewController.h
//  Todo
//
//  Created by Appiaries Corporation on 14/10/14.
//  Copyright (c) 2014 Appiaries Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LogInViewController : UIViewController
#pragma mark - Properties
@property (strong, nonatomic) IBOutlet UILabel *lbErrMessage;
@property (strong, nonatomic) IBOutlet UITextField *tfID;
@property (strong, nonatomic) IBOutlet UITextField *tfPassWord;
@property (strong, nonatomic) IBOutlet UIButton *btnLogIn;

#pragma mark - Actions
- (IBAction)logIn:(id)sender;

@end
