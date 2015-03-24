//
//  DailyCellSection.h
//  Todo
//
//  Created by Appiaries Corporation on 12/8/14.
//  Copyright (c) 2014 Appiaries Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DailyCellSection : UITableViewHeaderFooterView
#pragma mark - Properties
@property (weak, nonatomic) IBOutlet UIView *viewBackground;
@property (weak, nonatomic) IBOutlet UILabel *labelSectionName;
@property (weak, nonatomic) IBOutlet UIButton *btnAdd;

@end
