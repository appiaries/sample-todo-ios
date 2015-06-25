//
// Created by Appiaries Corporation on 15/05/27.
// Copyright (c) 2015 Appiaries Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Task : ABDBObject <ABManagedProtocol>
#pragma mark - Properties
@property (strong, nonatomic, getter=userId, setter=setUserId:) NSString *user_id;
@property (nonatomic) NSInteger type;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *body;
@property (nonatomic) NSInteger status;
@property (nonatomic) NSInteger position;
@property (strong, nonatomic, getter=scheduledAt, setter=setScheduledAt:) NSDate *scheduled_at;

#pragma mark - Initialization
+ (id)task;

@end
