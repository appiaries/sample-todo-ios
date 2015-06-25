//
//  TopViewController.h
//  Todo
//
//  Created by Appiaries Corporation on 12/8/14.
//  Copyright (c) 2014 Appiaries Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TopViewController : UIViewController
#pragma mark - Properties
@property (weak, nonatomic) IBOutlet UIButton *btnLogin;
@property (weak, nonatomic) IBOutlet UIButton *btnRegister;
@property (weak, nonatomic) IBOutlet UIButton *btnLoginFacebook;
@property (weak, nonatomic) IBOutlet UIButton *btnLoginTwitter;

#pragma mark - Actions
- (IBAction)actionLoginFaceBook:(id)sender;
- (IBAction)actionLoginTwitter:(id)sender;

@end
