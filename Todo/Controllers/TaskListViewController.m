//
//  TaskListViewController.m
//  Todo
//
//  Created by Appiaries Corporation on 12/8/14.
//  Copyright (c) 2014 Appiaries Corporation. All rights reserved.
//

#import "TaskListViewController.h"
#import "TaskListHeaderView.h"
#import "TaskListCell.h"
#import "TaskInputViewController.h"
#import "SettingsViewController.h"
#import "MBProgressHUD.h"
#import "PreferenceHelper.h"
#import "SHUIKitBlocks.h"
#import "UIScrollView+SVPullToRefresh.h"

#define TAG_BUTTON_TOOLBAR      1
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


@implementation TaskListViewController
@synthesize myTableView;

#pragma mark - Initialization
- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        taskList = [@[] mutableCopy];
    }
    return self;
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupView];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(backToLogin)
                                                 name:@"BackToLoginNotification"
                                               object:nil];
    [self initializeCategories];
    
    [self getTasks];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title = @"";
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [myTableView addPullToRefreshWithActionHandler:^{
        [self getTasks];
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
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
                                  delegate:nil
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil
        ] show];
    } else {
        [self doneButtonClickedDismissKeyboard];
        [self addTodayTask];
    }
}

- (IBAction)actionMenu:(id)sender
{
    SettingsViewController *loginController = [self.storyboard instantiateViewControllerWithIdentifier:@"MenuView"];
    [self.navigationController pushViewController:loginController animated:YES];
}

- (void)addAction:(UIButton *)sender
{
    TaskInputViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AddTodoView"];
    viewController.section = sender.tag;
    [self presentViewController:viewController animated:YES completion:nil];
}

// Toolbar action
- (void)actionCompletedButton
{
    NSArray *arrTasks = dictionaryTasks[arrCategories[(NSUInteger)selectSectionIndex]];
    Task *task = arrTasks[(NSUInteger)selectRowIndex];
    task.status = 1;

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [task saveWithBlock:^(ABResult *ret, ABError *err){
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if (err == nil) {
            NSLog(@"OK");
            [self reloadData];
        } else {
            NSLog(@"NSError");
            //TODO: reload ?
        }
    }];
}

- (void)actionImportantButton
{
    NSArray *arrTasks = dictionaryTasks[arrCategories[(NSUInteger)selectSectionIndex]];
    Task *task = arrTasks[(NSUInteger)selectRowIndex];
    task.type = task.type == 0 ? 1 : 0;

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [task saveWithBlock:^(ABResult *ret, ABError *err){
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if (err == nil) {
            NSLog(@"OK");
            [self reloadData];
        } else {
            NSLog(@"NSError");
            //TODO: reload ?
        }
    }];
}

- (void)actionDeleteButton
{
    [[UIAlertView SH_alertViewWithTitle:@""
                            andMessage:@"削除しますか？"
                          buttonTitles:@[@"削除"]
                           cancelTitle:@"キャンセル"
                             withBlock:^(NSInteger buttonIndex){
                                 if (buttonIndex == 1) {
                                     NSArray *arrTasks = dictionaryTasks[arrCategories[(NSUInteger)selectSectionIndex]];
                                     Task *task = arrTasks[(NSUInteger)selectRowIndex];
                                     [self deleteTask:task];
                                 }
                             }
    ] show];
}

- (void)actionEditButton
{
    NSArray *arrTasks = dictionaryTasks[arrCategories[(NSUInteger)selectSectionIndex]];
    Task *task = arrTasks[(NSUInteger)selectRowIndex];

    TaskInputViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AddTodoView"];
    [viewController setEditTask:task];
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)actionDeletedTaskCompleted:(id)sender
{
    NSString *taskID = ((UIButton *)sender).accessibilityHint;
    [[UIAlertView SH_alertViewWithTitle:@""
                             andMessage:@"削除しますか？"
                           buttonTitles:@[@"削除"]
                            cancelTitle:@"キャンセル"
                              withBlock:^(NSInteger buttonIndex){
                                  if (buttonIndex == 1) {
                                      Task *task = [Task task];
                                      task.ID = taskID;
                                      [self deleteTask:task];
                                  }
                              }
    ] show];
}

#pragma mark - Gestures
- (void)cellSwipe:(UISwipeGestureRecognizer *)gesture
{
    CGPoint location = [gesture locationInView:myTableView];
    NSIndexPath *swipedIndexPath = [myTableView indexPathForRowAtPoint:location];
    NSInteger sectionIndex = swipedIndexPath.section;
    NSInteger rowIndex = swipedIndexPath.row;
    
    NSArray *arrTasks = dictionaryTasks[arrCategories[(NSUInteger)sectionIndex]];
    Task *task = arrTasks[(NSUInteger)rowIndex];
    
    if (task.status != 1) {
        task.status = 1;

        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [task saveWithBlock:^(ABResult *ret, ABError *err){
            if (err == nil) {
                NSLog(@"OK");
                [self reloadData];
            } else {
                NSLog(@"NSError");
                //TODO: reload?
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
    
    for (Task *task in taskList) {
        
        long long schedule = [nowSchedule longLongValue];
        long long taskSchedule = (long long)task.scheduledAt.timeIntervalSince1970;
        
        // TODAY (今日)
        if (taskSchedule - schedule > 0 & taskSchedule - schedule <= 86400) {
            [listToDays addObject:task];
        }
        // TOMORROW (明日)
        else if (taskSchedule - schedule > 86400 & taskSchedule - schedule <= 172800) {
            [listTomorrows addObject:task];
        }
        // THE DAY AFTER TOMORROW (明後日)
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
    NSString *userId = [[PreferenceHelper sharedPreference] loadUserId];
    ABQuery *query = [[Task query] where:@"user_id" equalsTo:userId];

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [baas.db findWithQuery:query block:^(ABResult *ret, ABError *err){
        double delayInSeconds = 1.5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){

            if (!myTableView.pullToRefreshView.hidden) {
                [myTableView.pullToRefreshView stopAnimating];
            }
            if (err == nil) {
                NSArray *tasks = ret.data;
                if ([tasks count] > 0) {
                    [taskList removeAllObjects];
                    [taskList addObjectsFromArray:tasks];
                }
                [self initializeCategories];
                [self filterTaskByTime];
            } else {
                NSLog(@"get Categories failed");
                //TODO: 何もしなくて大丈夫？
            }
            [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
        });
    }];
}

// Add task today
- (void)addTodayTask
{
    Task *task = [Task task];
    task.userId = [[PreferenceHelper sharedPreference] loadUserId];
    task.type = 0;
    task.title = self.txtTitleMemo.text;
    task.body = @"";
    task.status = 0;
    task.scheduledAt = [NSDate date];

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [task saveWithBlock:^(ABResult *ret, ABError *err){
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if (err == nil) {
            self.txtTitleMemo.text = @"";
            [self reloadData];
        } else {
            NSLog(@"NSError");
             //TODO:
        }
    }];
}

// Delete task with taskID
- (void)deleteTask:(Task *)task
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [task deleteWithBlock:^(ABResult *ret, ABError *err){
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (err == nil) {
            [self reloadData];
        } else {
            NSLog(@"Delete Task error");
            //TODO:
        }
    }];
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
    static NSString *kHeaderIdentifier = @"TaskListHeaderView";
    TaskListHeaderView *cellSection = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kHeaderIdentifier];

    if (!cellSection) {
        NSArray *objs = [[NSBundle mainBundle] loadNibNamed:kHeaderIdentifier owner:self options:nil];
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
    NSString *categoryName = arrCategories[(NSUInteger)section];
    NSArray *tasks = dictionaryTasks[categoryName];
    return [tasks count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [listTitleCategory count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TaskCellIdentifier";
    TaskListCell *cell = (TaskListCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[TaskListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSArray *arrTasks = dictionaryTasks[arrCategories[(NSUInteger)indexPath.section]];
    Task *task = arrTasks[(NSUInteger)indexPath.row];
    
    if (task.status == 1) {
        
        UIImage *image = [UIImage imageNamed:@"iconDelete.png"];
        UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        deleteButton.frame = CGRectMake(290.0, 15.0, 25.0, 25.0);
        deleteButton.tag = TAG_BUTTON_DELETE_TASK;
        deleteButton.accessibilityHint = task.ID;
        [deleteButton setBackgroundImage:image forState:UIControlStateNormal];
        [deleteButton addTarget:self action:@selector(actionDeletedTaskCompleted:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:deleteButton];
        
        NSAttributedString * title = [[NSAttributedString alloc]
                initWithString:task.title attributes:@{NSStrikethroughStyleAttributeName:@(NSUnderlineStyleSingle)}];
        [cell.lbName setAttributedText:title];

    } else {

        cell.lbName.text = task.title;
        for (UIView *subView in cell.contentView.subviews) {
            if (subView.tag == TAG_BUTTON_DELETE_TASK) {
                [subView removeFromSuperview];
            }
        }
    }
    
    if (task.type == 1) {
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
        Task *task = arrTasks[(NSUInteger)indexPath.row];
        
        if (task.status == 0) {
            selectSectionIndex = indexPath.section;
            selectRowIndex = indexPath.row;
        } else {
            selectSectionIndex = -1;
            selectRowIndex = -1;
        }
    }
    [self.myTableView reloadData];
}

#pragma mark - UITextField delegates
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self actionAddTaskToday:nil];
    return NO;
}

#pragma mark - MISC
- (void)setupView {
    
    self.title = @"";

    myTableView.delegate = self;
    myTableView.dataSource = self;
    selectSectionIndex = -1;
    selectRowIndex = -1;

    [[UITableViewHeaderFooterView appearance] setTintColor:[UIColor whiteColor]];

    // Add Done button to keyboard
    UIToolbar *doneToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    doneToolbar.barStyle = UIBarStyleDefault;
    doneToolbar.items = @[
            [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
            [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonClickedDismissKeyboard)]
    ];
    [doneToolbar sizeToFit];
    self.txtTitleMemo.inputAccessoryView = doneToolbar;
    self.txtTitleMemo.placeholder = @"タスクを入力";
    self.txtTitleMemo.delegate = self;

    UISwipeGestureRecognizer *showExtrasSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(cellSwipe:)];
    showExtrasSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    [myTableView addGestureRecognizer:showExtrasSwipe];


}

@end
