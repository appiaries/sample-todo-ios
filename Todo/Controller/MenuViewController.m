//
//  MenuViewController.m
//  Todo
//
//  Created by Appiaries Corporation on 12/11/14.
//  Copyright (c) 2014 Appiaries Corporation. All rights reserved.
//

#import "MenuViewController.h"
#import "TodoAPIClient.h"
#import "AccountViewController.h"


@implementation MenuViewController

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
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.title = @"";
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.title = @"戻る";
}

#pragma mark - UITableView data sources
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary *info = [[TodoAPIClient sharedClient]loadLogInInfo];
    return ([info[@"type"] integerValue] == 0) ? 1 : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = @"アカウント";
    cell.textLabel.font = [UIFont boldSystemFontOfSize:20];
    
    return cell;
}

#pragma mark - UITableView delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AccountViewController *loginController = [self.storyboard instantiateViewControllerWithIdentifier:@"AccountView"];
    [self.navigationController pushViewController:loginController animated:YES];
}

@end
