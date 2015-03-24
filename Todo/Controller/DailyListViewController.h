//
//  DailyListViewController.h
//  Todo
//
//  Created by Appiaries Corporation on 12/8/14.
//  Copyright (c) 2014 Appiaries Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DailyListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>
{
    NSInteger selectRowIndex;
    NSInteger selectSectionIndex;
    NSMutableArray *listTasks;
    NSMutableDictionary *dictionaryTasks;
    NSArray *arrCategories;
    NSArray *listTitleCategory;
}
#pragma mark - Properties
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (weak, nonatomic) IBOutlet UITextField *txtTitleMemo;

@end
