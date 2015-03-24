//
//  DailyListViewController.m
//  Todo
//
//  Created by Appiaries Corporation on 12/8/14.
//  Copyright (c) 2014 Appiaries Corporation. All rights reserved.
//

#import "DailyListViewController.h"
#import "DailyCellSection.h"
#import "DailyTableViewCell.h"
#import "AddTodoViewController.h"
#import "MenuViewController.h"
#import "TaskManager.h"
#import "TodoAPIClient.h"
#import "MBProgressHUD.h"

#define TAG_BUTTON_TOOLBAR      1
#define TAG_ALERT_DELETE_TASK   2
#define TAG_BUTTON_DELETE_TASK  3
#define TAG_VIEW_IMPORTANT      4

// Key Dictionary
static NSString *const kDictionaryToday         = @"DictionaryToday";
static NSString *const kDictionaryTomorrow      = @"DictionaryTomorrow";
static NSString *const kDictionaryAfterTomorrow = @"DictionaryAfterTomorrow";
static NSString *const kDictionaryNexDay1       = @"DictionaryNexDay1";
static NSString *const kDictionaryNexDay2       = @"DictionaryNexDay2";
static NSString *const kDictionaryNexDay3       = @"DictionaryNexDay3";
static NSString *const kDictionaryNexDay4       = @"DictionaryNexDay4";
static NSString *const kDictionaryNearFuture    = @"DictionaryNearFuture";
static NSString *const kDictionarySomeDay       = @"DictionarySomeDay";
static NSString *const kDictionaryPast          = @"DictionaryPast";


@implementation DailyListViewController
@synthesize myTableView;

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

    myTableView.delegate = self;
    myTableView.dataSource = self;
    selectSectionIndex = -1;
    selectRowIndex = -1;
    
    [[UITableViewHeaderFooterView appearance] setTintColor:[UIColor whiteColor]];
    [self addDoneToolBarToKeyboardForTextField:self.txtTitleMemo];
    
    UISwipeGestureRecognizer *showExtrasSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(cellSwipe:)];
    showExtrasSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    [myTableView addGestureRecognizer:showExtrasSwipe];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(backToLogin)
                                                 name:@"BackToLoginNotification"
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self initializeCategories];
    [self getTasks];
    self.title = @"";
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.title = @"戻る";
}

#pragma mark - Memory management
- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Actions
- (IBAction)actionAddTaskToday:(id)sender
{
    NSString *newString = [self.txtTitleMemo.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([newString isEqualToString:@""]) {
        [[[UIAlertView alloc] initWithTitle:@""
                                    message:@"タスクのタイトルを入力ください "
                                   delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil, nil
        ] show];

    } else {
        [self doneButtonClickedDismissKeyboard];
        [self addTodayTask];
    }
}

- (IBAction)actionMenu:(id)sender
{
    MenuViewController *loginController = [self.storyboard instantiateViewControllerWithIdentifier:@"MenuView"];
    [self.navigationController pushViewController:loginController animated:YES];
}

- (void)addAction:(UIButton *)sender
{
    AddTodoViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AddTodoView"];
    viewController.section = sender.tag;
    [self presentViewController:viewController animated:YES completion:nil];
}

// Toolbar action
- (void)actionCompletedButton
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSArray *arrTasks = dictionaryTasks[arrCategories[(NSUInteger)selectSectionIndex]];
    
    TodoTasks *taskAtIndex = arrTasks[(NSUInteger)selectRowIndex];
    NSDictionary *dictionary = @{@"status" : @1};
    
    [[TaskManager sharedManager]updateTaskInfoWithTaskID:taskAtIndex.id imageData:dictionary failBlock:^(NSError *failBlock) {
        if (failBlock != nil) {
            NSLog(@"NSError");
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        } else {
            NSLog(@"OK");
            [self reloadData];
        }
    }];
}

- (void)actionImportantButton
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSArray *arrTasks = dictionaryTasks[arrCategories[(NSUInteger)selectSectionIndex]];
    
    TodoTasks *taskAtIndex = arrTasks[(NSUInteger)selectRowIndex];
    
    NSDictionary *dictionary;
    if ([taskAtIndex.type integerValue] == 0) {
        dictionary = @{ @"type" : @1 };
    } else {
        dictionary = @{ @"type" : @0 };
    }
    
    [[TaskManager sharedManager]updateTaskInfoWithTaskID:taskAtIndex.id imageData:dictionary failBlock:^(NSError *failBlock){
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if (failBlock != nil) {
            NSLog(@"NSError");
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        } else {
            NSLog(@"OK");
            [self reloadData];
        }
    }];
}

- (void)actionDeleteButton
{
    UIAlertView *alAlert = [[UIAlertView alloc] initWithTitle:@"" message:@"削除しますか？" delegate:self cancelButtonTitle:@"キャンセル" otherButtonTitles:@"削除", nil];
    alAlert.tag = TAG_ALERT_DELETE_TASK;
    [alAlert show];
}

- (void)actionEditButton
{
    NSArray *arrTasks = dictionaryTasks[arrCategories[(NSUInteger)selectSectionIndex]];
    TodoTasks *taskAtIndex = arrTasks[(NSUInteger)selectRowIndex];

    AddTodoViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AddTodoView"];
    [viewController setEditTask:taskAtIndex];
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)actionDeletedTaskCompleted:(id) sender
{
    UIButton *deleteButton = (UIButton *)sender;
    NSString *taskID = deleteButton.accessibilityHint;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[TaskManager sharedManager]deleteTaskWithTaskID:taskID failBlock:^(NSError *error) {
        if (error == nil) {
            NSLog(@"OK");
            [self reloadData];
        } else {
            NSLog(@"Delete Task error");
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }
    }];
}

#pragma mark - Gestures
- (void)cellSwipe:(UISwipeGestureRecognizer *)gesture
{
    CGPoint location = [gesture locationInView:myTableView];
    NSIndexPath *swipedIndexPath = [myTableView indexPathForRowAtPoint:location];
    NSInteger sectionIndex = swipedIndexPath.section;
    NSInteger rowIndex = swipedIndexPath.row;
    
    NSArray *arrTasks = dictionaryTasks[arrCategories[(NSUInteger)sectionIndex]];
    TodoTasks *taskAtIndex = arrTasks[(NSUInteger)rowIndex];
    
    if ([taskAtIndex.status integerValue] != 1) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        NSDictionary *dictionary = @{ @"status" : @1 };
        
        [[TaskManager sharedManager]updateTaskInfoWithTaskID:taskAtIndex.id imageData:dictionary failBlock:^(NSError *failBlock) {
            if (failBlock != nil) {
                NSLog(@"NSError");
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            } else {
                NSLog(@"OK");
                [self reloadData];
            }
        }];
    }
}

#pragma mark - MISC

- (void)reloadData
{
    selectRowIndex = -1;
    selectSectionIndex = -1;
    [self getTasks];
}

- (NSNumber *)convertTimestampFromDate:(NSDate *)date
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
    NSDateComponents *components = [gregorian components: (NSCalendarUnit)NSUIntegerMax fromDate: date];
    [components setHour: 0];
    [components setMinute: 0];
    [components setSecond: 0];
    
    NSDate *newDate = [gregorian dateFromComponents:components];
    NSTimeInterval timeInterval = [newDate timeIntervalSince1970];
    unsigned long long timeIntervalLongLong = (unsigned long long)timeInterval;
    NSNumber *schedule = @(timeIntervalLongLong);
    
    return schedule;
}

// Filter Task By Time
- (void)filterTaskByTime
{
    NSMutableArray *listToDays         = [@[] mutableCopy];
    NSMutableArray *listTomorrows      = [@[] mutableCopy];
    NSMutableArray *listAfterTomorrows = [@[] mutableCopy];
    NSMutableArray *listNextDay1       = [@[] mutableCopy];
    NSMutableArray *listNextDay2       = [@[] mutableCopy];
    NSMutableArray *listNextDay3       = [@[] mutableCopy];
    NSMutableArray *listNextDay4       = [@[] mutableCopy];
    NSMutableArray *listNearFutures    = [@[] mutableCopy];
    NSMutableArray *listNearSomeDays   = [@[] mutableCopy];
    NSMutableArray *listPasts          = [@[] mutableCopy];
    
    NSNumber *nowSchedule = [self convertTimestampFromDate:[NSDate date]];
    
    for (TodoTasks *task in listTasks) {
        
        long long schedule = [nowSchedule longLongValue];
        long long taskSchedule = [task.scheduledAt longLongValue];
        
        // 今日
        // TODAY
        if (taskSchedule - schedule > 0 & taskSchedule - schedule <= 86400) {
            [listToDays addObject:task];
        }
        // 明日
        // TOMORROW
        else if (taskSchedule - schedule > 86400 & taskSchedule - schedule <= 172800) {
            [listTomorrows addObject:task];
        }
        // 明後日
        // THE DAY AFTER TOMORROW
        else if (taskSchedule - schedule > 172800 & taskSchedule - schedule <= 259200) {
            [listAfterTomorrows addObject:task];
        }
        else if (taskSchedule - schedule > 259200 & taskSchedule - schedule <= 345600) {
            [listNextDay1 addObject:task];
        }
        else if (taskSchedule - schedule > 345600 & taskSchedule - schedule <= 432000) {
            [listNextDay2 addObject:task];
        }
        else if (taskSchedule - schedule > 432000 & taskSchedule - schedule <= 518400) {
            [listNextDay3 addObject:task];
        }
        else if (taskSchedule - schedule > 518400 & taskSchedule - schedule <= 604800) {
            [listNextDay4 addObject:task];
        }
        // 近日中
        else if (taskSchedule - schedule > 604800 & taskSchedule - schedule <= 2592000) {
            [listNearFutures addObject:task];
        }
        // いつか
        else if (taskSchedule - schedule > 2592000) {
            [listNearSomeDays addObject:task];
        }
        // 過去
        else {
            [listPasts addObject:task];
        }
    }

    dictionaryTasks = [[NSMutableDictionary alloc] init];
    dictionaryTasks[kDictionaryToday]         = listToDays;
    dictionaryTasks[kDictionaryTomorrow]      = listTomorrows;
    dictionaryTasks[kDictionaryAfterTomorrow] = listAfterTomorrows;
    dictionaryTasks[kDictionaryNexDay1]       = listNextDay1;
    dictionaryTasks[kDictionaryNexDay2]       = listNextDay2;
    dictionaryTasks[kDictionaryNexDay3]       = listNextDay3;
    dictionaryTasks[kDictionaryNexDay4]       = listNextDay4;
    dictionaryTasks[kDictionaryNearFuture]    = listNearFutures;
    dictionaryTasks[kDictionarySomeDay]       = listNearSomeDays;
    dictionaryTasks[kDictionaryPast]          = listPasts;
    
    // Reload tableView
    [myTableView reloadData];
}

// Init Categories
- (void)initializeCategories
{
    arrCategories = @[
            kDictionaryToday,
            kDictionaryTomorrow,
            kDictionaryAfterTomorrow,
            kDictionaryNexDay1,
            kDictionaryNexDay2,
            kDictionaryNexDay3,
            kDictionaryNexDay4,
            kDictionaryNearFuture,
            kDictionarySomeDay,
            kDictionaryPast
    ];
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [gregorian components:NSWeekdayCalendarUnit fromDate:[NSDate date]];
    NSInteger weekday = [comps weekday];
    
    switch (weekday) {
        case 1: listTitleCategory = @[@"今日", @"明日", @"明後日", @"水曜日", @"木曜日", @"金曜日", @"土曜日", @"近日中", @"いつか", @"過去"]; return;
        case 2: listTitleCategory = @[@"今日", @"明日", @"明後日", @"木曜日", @"金曜日", @"土曜日", @"日曜日", @"近日中", @"いつか", @"過去"]; return;
        case 3: listTitleCategory = @[@"今日", @"明日", @"明後日", @"金曜日", @"土曜日", @"日曜日", @"月曜日", @"近日中", @"いつか", @"過去"]; return;
        case 4: listTitleCategory = @[@"今日", @"明日", @"明後日", @"土曜日", @"日曜日", @"月曜日", @"火曜日", @"近日中", @"いつか", @"過去"]; return;
        case 5: listTitleCategory = @[@"今日", @"明日", @"明後日", @"日曜日", @"月曜日", @"火曜日", @"水曜日", @"近日中", @"いつか", @"過去"]; return;
        case 6: listTitleCategory = @[@"今日", @"明日", @"明後日", @"月曜日", @"火曜日", @"水曜日", @"木曜日", @"近日中", @"いつか", @"過去"]; return;
        case 7: listTitleCategory = @[@"今日", @"明日", @"明後日", @"火曜日", @"水曜日", @"木曜日", @"金曜日", @"近日中", @"いつか", @"過去"]; return;
        default: return;
    }
}

// Get Task List
- (void)getTasks
{
    [[TaskManager sharedManager]getTasksWithCompletion:^(NSDictionary *categoryInfo){
        if (categoryInfo != nil) {
            NSArray *taskInfoArray = categoryInfo[@"_objs"];
            listTasks = [@[] mutableCopy];
            for (int i = 0; i < [taskInfoArray count]; i++) {
                TodoTasks *task = [[TodoTasks alloc] initWithDict:taskInfoArray[(NSUInteger)i]];
                [listTasks addObject:task];
            }
        }
        [self initializeCategories];
        [self filterTaskByTime];
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
    } failedBlock:^(NSError * block){
        [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
        if (block != nil) {
            NSLog(@"get Categories failed");
        }
    }];
}

// Add task today
- (void)addTodayTask
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSDictionary *userInfo = [[TodoAPIClient sharedClient]loadLogInInfo];
    
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    unsigned long long timeIntervalLongLong = (unsigned long long)timeInterval;
    NSNumber *scheduledTime = @(timeIntervalLongLong);
    
    NSDictionary *dictionary = @{
            @"user_Id"      : userInfo[@"user_id"],
            @"category_id"  : @"",
            @"type"         : @0,
            @"title"        : self.txtTitleMemo.text,
            @"body"         : @"",
            @"status"       : @0,
            @"scheduled_at" : scheduledTime
    };
    
    [[TaskManager sharedManager]addTaskInfoWithData:dictionary failBlock:^(NSError *failBlock){
         [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
         if (failBlock != nil) {
             NSLog(@"NSError");
         } else {
             NSLog(@"OK");
             self.txtTitleMemo.text = @"";
             [self reloadData];
         }
     }];
}

// Delete task with taskID
- (void)deleteTask
{
    NSArray *arrTasks = dictionaryTasks[arrCategories[(NSUInteger)selectSectionIndex]];
    TodoTasks *taskAtIndex = arrTasks[(NSUInteger)selectRowIndex];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[TaskManager sharedManager]deleteTaskWithTaskID:taskAtIndex.id failBlock:^(NSError *error){
        if (error == nil) {
             NSLog(@"OK");
            [self reloadData];
        } else {
            NSLog(@"Delete Task error");
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }
    }];
}

// Add Done button to keyboard
- (void)addDoneToolBarToKeyboardForTextField:(UITextField *)textField{
    
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
    [self.txtTitleMemo resignFirstResponder];
}

- (void)backToLogin
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableView Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 55;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    static NSString *HeaderIdentifier = @"DailyCellSection";
    DailyCellSection *cellSection = [tableView dequeueReusableHeaderFooterViewWithIdentifier:HeaderIdentifier];

    if (!cellSection) {
        NSArray *objs = [[NSBundle mainBundle] loadNibNamed:HeaderIdentifier owner:self options:nil];
        cellSection = objs[(NSUInteger)0];
    }
    
    cellSection.labelSectionName.text = listTitleCategory[(NSUInteger)section];
    cellSection.btnAdd.tag = section;
    [cellSection.btnAdd addTarget:self action:@selector(addAction:) forControlEvents:UIControlEventTouchUpInside];
    if (section > 6) {
        cellSection.btnAdd.alpha = 0;
    }
    
    return cellSection;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.row == selectRowIndex && indexPath.section == selectSectionIndex) ? 100 : 55;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [dictionaryTasks[arrCategories[(NSUInteger)section]] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [listTitleCategory count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DailyCellIdentifier";
    DailyTableViewCell *cell = (DailyTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[DailyTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSArray *arrTasks = dictionaryTasks[arrCategories[(NSUInteger)indexPath.section]];
    TodoTasks *taskAtIndex = arrTasks[(NSUInteger)indexPath.row];
    
    if ([taskAtIndex.status intValue] == 1) {
        
        UIImage *image = [UIImage imageNamed:@"iconDelete.png"];
        UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        deleteButton.frame = CGRectMake(290.0, 15.0, 25.0, 25.0);
        deleteButton.tag = TAG_BUTTON_DELETE_TASK;
        deleteButton.accessibilityHint = taskAtIndex.id;
        [deleteButton setBackgroundImage:image forState:UIControlStateNormal];
        [deleteButton addTarget:self action:@selector(actionDeletedTaskCompleted:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:deleteButton];
        
        NSAttributedString * title = [[NSAttributedString alloc]
                initWithString:taskAtIndex.title attributes:@{NSStrikethroughStyleAttributeName:@(NSUnderlineStyleSingle)}];
        [cell.lbName setAttributedText:title];

    } else {

        cell.lbName.text = taskAtIndex.title;
        for (UIView *subView in cell.contentView.subviews) {
            if (subView.tag == TAG_BUTTON_DELETE_TASK) {
                [subView removeFromSuperview];
            }
        }
    }
    
    if ([taskAtIndex.type integerValue] == 1) {
        UIView *importantView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 55)];
        importantView.tag = TAG_VIEW_IMPORTANT;
        importantView.backgroundColor = [UIColor redColor];
        [cell.contentView addSubview:importantView];
    } else {
        for (UIView *subView in cell.contentView.subviews) {
            if (subView.tag == TAG_VIEW_IMPORTANT) {
                [subView removeFromSuperview];
            }
        }
    }

    if (indexPath.row == selectRowIndex && indexPath.section == selectSectionIndex) {
        UIImage *image = [UIImage imageNamed:@"completed.png"];
        UIButton *completedButton = [UIButton buttonWithType:UIButtonTypeCustom];
        completedButton.tag = TAG_BUTTON_TOOLBAR;
        completedButton.frame = CGRectMake(50.0, 55.0, 29.0, 29.0);
        [completedButton setBackgroundImage:image forState:UIControlStateNormal];
        [completedButton addTarget:self action:@selector(actionCompletedButton) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:completedButton];
        
        image = [UIImage imageNamed:@"important.png"];
        UIButton *importantButton = [UIButton buttonWithType:UIButtonTypeCustom];
        importantButton.tag = TAG_BUTTON_TOOLBAR;
        importantButton.frame = CGRectMake(115.0, 55.0, 29.0, 29.0);
        [importantButton setBackgroundImage:image forState:UIControlStateNormal];
        [importantButton addTarget:self action:@selector(actionImportantButton) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:importantButton];
        
        image = [UIImage imageNamed:@"delete.png"];
        UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        deleteButton.tag = TAG_BUTTON_TOOLBAR;
        deleteButton.frame = CGRectMake(180.0, 55.0, 29.0, 29.0);
        [deleteButton setBackgroundImage:image forState:UIControlStateNormal];
        [deleteButton addTarget:self action:@selector(actionDeleteButton) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:deleteButton];
        
        image = [UIImage imageNamed:@"edittask.png"];
        UIButton *editButton = [UIButton buttonWithType:UIButtonTypeCustom];
        editButton.tag = TAG_BUTTON_TOOLBAR;
        editButton.frame = CGRectMake(245.0, 55.0, 29.0, 29.0);
        [editButton setBackgroundImage:image forState:UIControlStateNormal];
        [editButton addTarget:self action:@selector(actionEditButton) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:editButton];

    } else {
        for (UIView *subView in cell.contentView.subviews) {
            if (subView.tag == TAG_BUTTON_TOOLBAR) {
                [subView removeFromSuperview];
            }
        }
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == selectRowIndex && indexPath.section == selectSectionIndex) {
        selectSectionIndex = -1;
        selectRowIndex = -1;
    } else {
        NSArray *arrTasks = dictionaryTasks[arrCategories[(NSUInteger)indexPath.section]];
        TodoTasks *task = arrTasks[(NSUInteger)indexPath.row];
        
        if ([task.status integerValue] == 0) {
            selectSectionIndex = indexPath.section;
            selectRowIndex = indexPath.row;
        } else {
            selectSectionIndex = -1;
            selectRowIndex = -1;
        }
    }
    [self.myTableView reloadData];
}

#pragma mark - UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self deleteTask];
    }
}

@end
