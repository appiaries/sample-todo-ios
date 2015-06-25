//
//  TaskInputViewController.m
//  Todo
//
//  Created by Appiaries Corporation on 12/9/14.
//  Copyright (c) 2014 Appiaries Corporation. All rights reserved.
//

#import "TaskInputViewController.h"
#import "MBProgressHUD.h"


@implementation TaskInputViewController
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

    [self setupView];
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
                                  delegate:nil
                         cancelButtonTitle:@"OK"
                          otherButtonTitles:nil
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
    scheduledAt = [oldDate dateByAddingTimeInterval:secondsInEightHours];
    self.lbDateSelected.text = [self convertDateToString:scheduledAt];
    
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
- (void)setupView
{
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

    // Set scheduleAt
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
        dateSelected = [[NSDate date] dateByAddingTimeInterval:60 * 60 * 24 * section];
        scheduledAt = dateSelected;
        self.lbDateSelected.text = [self convertDateToString:dateSelected];
    }
}

- (void)addTask
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    Task *task = [Task task];
    task.userId = baas.session.user.ID;
    task.type = 0;
    task.title = self.txtTitle.text;
    task.body = self.tvMemo.text;
    task.status = 0;
    task.scheduledAt = scheduledAt;

    [task saveWithBlock:^(ABResult *ret, ABError *err){
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if (err == nil) {
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            [[[UIAlertView alloc] initWithTitle:@"ERROR"
                                       message:err.description
                                      delegate:nil
                             cancelButtonTitle:@"OK"
                              otherButtonTitles:nil
            ] show];
        }
    }];
}

// Update task
- (void)updateTask
{
    NSString *title = self.txtTitle.text;
    NSString *body  = self.tvMemo.text;

    if (![editTask.title isEqualToString:title]) {
        editTask.title = title;
    }
    if (![editTask.body isEqualToString:body]) {
        editTask.body = body;
    }
    if (editTask.scheduledAt.timeIntervalSince1970 != scheduledAt.timeIntervalSince1970) {
        editTask.scheduledAt = scheduledAt;
    }

    if (editTask.isDirty) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [editTask saveWithBlock:^(ABResult *ret, ABError *err){
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            if (err == nil) {
                [self dismissViewControllerAnimated:YES completion:nil];
            } else {
                NSLog(@"NSError"); //FIXME:
            }
        }];
    } else {
        // has no updates
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)displayEditTask
{
    self.tvMemo.text = editTask.body;
    self.txtTitle.text = editTask.title;

    //FIXME: redundant
    scheduledAt = editTask.scheduledAt;
    NSDate *dateEdit = scheduledAt;
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
    NSInteger selectIndexHour = (hour > 12) ? hour - 13 : hour - 1;
    [timePicker selectRow:selectIndexHour inComponent:0 animated:NO];
    [timePicker selectRow:minute inComponent:1 animated:NO];
}

@end
