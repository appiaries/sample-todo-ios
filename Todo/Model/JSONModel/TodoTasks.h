//
//  TodoTasks.h
//  Todo
//
//  Created by Appiaries Corporation on 12/10/14.
//  Copyright (c) 2014 Appiaries Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TodoTasks : NSObject
#pragma mark - Properties
@property  (strong, nonatomic) NSString *id;
@property  (strong, nonatomic) NSString *userId;
@property  (strong, nonatomic) NSString *categoryId;
@property  (strong, nonatomic) NSNumber *type;
@property  (strong, nonatomic) NSString *title;
@property  (strong, nonatomic) NSString *body;
@property  (strong, nonatomic) NSNumber *status;
@property  (strong, nonatomic) NSNumber *scheduledAt;
@property  (strong, nonatomic) NSNumber *cts;
@property  (strong, nonatomic) NSNumber *uts;
@property  (strong, nonatomic) NSString *cby;
@property  (strong, nonatomic) NSString *uby;

#pragma mark - Initialization
- (id)initWithDict:(NSDictionary *)tasksDict;

@end
