//
//  TaskInputViewController.h
//  Todo
//
//  Created by Appiaries Corporation on 12/9/14.
//  Copyright (c) 2014 Appiaries Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Task.h"

@interface TaskInputViewController : UIViewController <UIActionSheetDelegate, UIPickerViewDelegate, UIPickerViewDataSource>
{
    UIDatePicker *datePicker;
    UIPickerView *timePicker;
    UIActionSheet *actionSheetSelectDate;
    NSDate *dateSelected;
    NSMutableArray *arrHour;
    NSMutableArray *arrMinute;
    NSDate *scheduledAt;

}
#pragma mark - Properties
@property (assign, nonatomic) NSInteger section;
@property (strong, nonatomic) Task *editTask;
@property (weak, nonatomic) IBOutlet UITextField *txtTitle;
@property (weak, nonatomic) IBOutlet UITextView *tvMemo;
@property (weak, nonatomic) IBOutlet UIButton *btnSave;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet UILabel *lbDateSelected;

#pragma mark - Actions
- (IBAction)actionSave:(id)sender;
- (IBAction)actionCancel:(id)sender;

@end
