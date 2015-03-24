//
//  TodoTasks.m
//  Todo
//
//  Created by Appiaries Corporation on 12/10/14.
//  Copyright (c) 2014 Appiaries Corporation. All rights reserved.
//

#import "TodoTasks.h"

@implementation TodoTasks

#pragma mark - Initialization
- (id)initWithDict:(NSDictionary *)tasksDict
{
    if (self = [super init]) {
        _id          = tasksDict[@"_id"];
        _userId      = tasksDict[@"user_Id"];
        _categoryId  = tasksDict[@"category_id"];
        _type        = tasksDict[@"type"];
        _title       = tasksDict[@"title"];
        _body        = tasksDict[@"body"];
        _status      = tasksDict[@"status"];
        _scheduledAt = tasksDict[@"scheduled_at"];
        _cts         = tasksDict[@"_cts"];
        _uts         = tasksDict[@"_uts"];
        _cby         = tasksDict[@"_cby"];
        _uby         = tasksDict[@"_uby"];
    }
    return  self;
}

@end
