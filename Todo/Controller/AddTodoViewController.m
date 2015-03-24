//
//  AddTodoViewController.m
//  Todo
//
//  Created by Appiaries Corporation on 12/9/14.
//  Copyright (c) 2014 Appiaries Corporation. All rights reserved.
//

#import "AddTodoViewController.h"
#import "TaskManager.h"
#import "TodoAPIClient.h"
#import "MBProgressHUD.h"


@implementation AddTodoViewController
@synthesize editTask;
@synthesize section;

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
    
    // Set border for button
    [[self.btnCancel layer] setCornerRadius:7.0f];
    [[self.btnCancel layer] setMasksToBounds:YES];
    
    [[self.btnSave layer] setCornerRadius:7.0f];
    [[self.btnSave layer] setMasksToBounds:YES];
    
    // Set border for textView
    self.tvMemo.layer.borderColor = [UIColor blackColor].CGColor;
    self.tvMemo.layer.borderWidth = 1.0f;
    
    [self addDoneToolBarToKeyboard:self.tvMemo];
    [self addDoneToolBarToKeyboardForTextField:self.txtTitle];
    
    [self setScheduledTime];
}

#pragma mark - Actions
- (IBAction)actionCancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)actionCancelPickerView
{
    [actionSheetSelectDate dismissWithClickedButtonIndex:0 animated:YES];
}

- (IBAction)actionSave:(id)sender
{
    NSString *newString = [self.txtTitle.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([newString isEqualToString:@""]) {
        [[[UIAlertView alloc] initWithTitle:@""
                                    message:@"Not empty task title"
                                   delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil, nil
        ] show];
    } else {
        if (editTask) {
            [self updateTask];
        } else {
            [self addTask];
        }
    }
}

- (void)actionSetPickerView
{
    
    NSInteger hour   = [timePicker selectedRowInComponent:0] + 1;
    NSInteger minute = [timePicker selectedRowInComponent:1];
    NSInteger isPM   = [timePicker selectedRowInComponent:2];
    
    if (isPM == 1) {
        hour = hour + 12;
    }
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:datePicker.date];
    NSInteger getHour = [components hour];
    NSInteger getMinute = [components minute];
    NSDate *oldDate = [datePicker.date dateByAddingTimeInterval: -(getHour * 60 * 60 + getMinute*60)];
    
    NSTimeInterval secondsInEightHours = hour * 60 * 60 + minute*60;
    NSDate *newDate = [oldDate dateByAddingTimeInterval:secondsInEightHours];
    
    NSTimeInterval timeInterval = [newDate timeIntervalSince1970];
    unsigned long long timeIntervalLongLong = (unsigned long long )timeInterval;
    scheduledTime = @(timeIntervalLongLong);
    
    self.lbDateSelected.text = [self convertDateToString:newDate];
    
    [actionSheetSelectDate dismissWithClickedButtonIndex:0 animated:YES];
}

- (IBAction)actionSelectTime:(id)sender
{
    actionSheetSelectDate = [[UIActionSheet alloc] initWithTitle:@" "
                                                        delegate:self
                                               cancelButtonTitle:@""
                                          destructiveButtonTitle:nil
                                               otherButtonTitles:nil];
    // Add the picker
    datePicker = [[UIDatePicker alloc] init];
    datePicker.datePickerMode = UIDatePickerModeDate;
    datePicker.transform = CGAffineTransformMakeScale(0.8, 0.8);
    [datePicker setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ja_JP"]];
    datePicker.date = dateSelected;
    
    timePicker = [[UIPickerView alloc] init];
    timePicker.transform = CGAffineTransformMakeScale(0.8, 0.8);
    timePicker.delegate = self;
    timePicker.dataSource = self;
    
    [self selectRowPickerView];
    
    CGRect pickerRect = datePicker.frame;
    pickerRect.origin.y = 190;
    timePicker.frame = pickerRect;
    
    // Add set button to pickerView
    UIButton *btnSet = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSet.frame = CGRectMake(50.0, 358.0, 80.0, 35.0);
    [btnSet setTitle:@"Set" forState:UIControlStateNormal];
    [btnSet setTitleColor:self.view.tintColor forState:UIControlStateNormal];
    
    [[btnSet layer] setCornerRadius:5.0f];
    [[btnSet layer] setMasksToBounds:YES];
    btnSet.layer.borderColor = [self.view.tintColor CGColor];
    btnSet.layer.borderWidth = 1.0f;
    [btnSet addTarget:self action:@selector(actionSetPickerView) forControlEvents:UIControlEventTouchUpInside];
    
    // Add cancel button to pickerView
    UIButton *btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
    btnCancel.frame = CGRectMake(200.0, 358.0, 80.0, 35.0);
    [btnCancel setTitle:@"Cancel" forState:UIControlStateNormal];
    [btnCancel setTitleColor:self.view.tintColor forState:UIControlStateNormal];
    
    [[btnCancel layer] setCornerRadius:5.0f];
    [[btnCancel layer] setMasksToBounds:YES];
    btnCancel.layer.borderColor = [self.view.tintColor CGColor];
    btnCancel.layer.borderWidth = 1.0f;
    [btnCancel addTarget:self action:@selector(actionCancelPickerView) forControlEvents:UIControlEventTouchUpInside];
    
    [actionSheetSelectDate addSubview:datePicker];
    [actionSheetSelectDate addSubview:timePicker];
    [actionSheetSelectDate addSubview:btnSet];
    [actionSheetSelectDate addSubview:btnCancel];
    [actionSheetSelectDate showInView:self.view];
    [actionSheetSelectDate setBounds:CGRectMake(0.0, 0.0, 320.0, 700.0)];
}

#pragma mark - UIPickerView data sources
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0) {
        return 12;
    } else if (component == 1) {
        return 60;
    }
    return 2;
}

#pragma mark - UIPickerView delegates
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component == 0) {
        return arrHour[(NSUInteger)row];
    } else if (component == 1) {
        return arrMinute[(NSUInteger)row];
    } else {
        return (row == 0) ? @"AM" : @"PM";
    }
}

#pragma mark - Keyboard handlers
// Add Done button to keyboard
- (void)addDoneToolBarToKeyboard:(UITextView *)textView
{
    UIToolbar *doneToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    doneToolbar.barStyle = UIBarStyleDefault;
    doneToolbar.items = @[
            [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
            [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonClickedDismissKeyboard)]
    ];
    [doneToolbar sizeToFit];
    textView.inputAccessoryView = doneToolbar;
}

// Add Done button to keyboard
- (void)addDoneToolBarToKeyboardForTextField:(UITextField *)textField
{
    UIToolbar *doneToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    doneToolbar.barStyle = UIBarStyleDefault;
    doneToolbar.items = @[
            [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
            [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonClickedDismissKeyboard)]
    ];
    [doneToolbar sizeToFit];
    textField.inputAccessoryView = doneToolbar;
}

// Dismiss Keyboard
- (void)doneButtonClickedDismissKeyboard
{
    [self.tvMemo resignFirstResponder];
    [self.txtTitle resignFirstResponder];
}

#pragma mark - MISC
- (void)setScheduledTime
{
    arrHour   = [@[] mutableCopy];
    arrMinute = [@[] mutableCopy];
    for (int i = 1; i <= 12; i ++) {
        [arrHour addObject:[NSString stringWithFormat:@"%d", i]];
    }

    for (int i = 0; i <= 59; i ++) {
        [arrMinute addObject:[NSString stringWithFormat:@"%d", i]];
    }

    if (editTask) {
        [self displayEditTask];
    } else {
        NSDate *newDate = [[NSDate date] dateByAddingTimeInterval:60 * 60 * 24 * section];
        dateSelected = newDate;

        NSTimeInterval timeInterval = [newDate timeIntervalSince1970];
        unsigned long long timeIntervalLongLong = (unsigned long long )timeInterval;
        scheduledTime = @(timeIntervalLongLong);
        self.lbDateSelected.text = [self convertDateToString:newDate];
    }
}

- (void)addTask
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSDictionary *userInfo = [[TodoAPIClient sharedClient]loadLogInInfo];

    NSDictionary *dictionary = @{
            @"user_Id"      : userInfo[@"user_id"],
            @"category_id"  : @"",
            @"type"         : @0,
            @"title"        : self.txtTitle.text,
            @"body"         : self.tvMemo.text,
            @"status"       : @0,
            @"scheduled_at" : scheduledTime,
    };

    [[TaskManager sharedManager]addTaskInfoWithData:dictionary failBlock:^(NSError *failBlock){
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if (failBlock != nil) {
            NSLog(@"NSError");
        } else {
            NSLog(@"OK");
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}

// Update task
- (void)updateTask
{
    if (![self.txtTitle.text isEqualToString:editTask.title]
            || ![self.tvMemo.text isEqualToString:editTask.body]
            || [editTask.scheduledAt longLongValue] != [scheduledTime longLongValue]) {

        [MBProgressHUD showHUDAddedTo:self.view animated:YES];

        NSDictionary *dictionary = @{
                @"title"        : self.txtTitle.text,
                @"body"         : self.tvMemo.text,
                @"scheduled_at" : scheduledTime
        };

        [[TaskManager sharedManager]updateTaskInfoWithTaskID:editTask.id imageData:dictionary failBlock:^(NSError *failBlock){
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            if (failBlock != nil) {
                NSLog(@"NSError");
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            } else {
                NSLog(@"OK");
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }];
    }
}

- (void)displayEditTask
{
    self.tvMemo.text = editTask.body;
    self.txtTitle.text = editTask.title;

    scheduledTime = editTask.scheduledAt;
    NSDate *dateEdit = [NSDate dateWithTimeIntervalSince1970:[scheduledTime doubleValue]];
    dateSelected = dateEdit;
    self.lbDateSelected.text = [self convertDateToString:dateEdit];
}

- (NSString *)convertDateToString:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE. MMMM d, YYYY HH:mm"];
    return [dateFormatter stringFromDate:date];
}

- (void)selectRowPickerView
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:dateSelected];
    NSInteger hour = [components hour];
    NSInteger minute = [components minute];

    if (hour > 12 || (hour == 12 && minute > 0)) {
        [timePicker selectRow:1 inComponent:2 animated:NO];
    }
    NSInteger selectIndexHour;
    if (hour > 12) {
        selectIndexHour = hour - 13;
    } else {
        selectIndexHour = hour - 1;
    }
    [timePicker selectRow:selectIndexHour inComponent:0 animated:NO];
    [timePicker selectRow:minute inComponent:1 animated:NO];
}

@end
