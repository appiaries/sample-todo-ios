//
//  MenuViewController.h
//  Todo
//
//  Created by Appiaries Corporation on 12/11/14.
//  Copyright (c) 2014 Appiaries Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
#pragma mark - Properties
@property (weak, nonatomic) IBOutlet UITableView *myTableView;

@end
