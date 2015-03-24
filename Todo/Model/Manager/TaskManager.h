//
//  TaskManager.h
//  Todo
//
//  Created by Appiaries Corporation on 12/10/14.
//  Copyright (c) 2014 Appiaries Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TodoTasks;

@interface TaskManager : NSObject
#pragma mark - Properties
@property (readonly, nonatomic) TodoTasks *taskInfo;

#pragma mark - Initialization
+ (TaskManager *)sharedManager;

#pragma mark - Public methods
- (void)addTaskInfoWithData:(NSDictionary *)data failBlock:(void(^)(NSError *))failBlock;
- (void)getTasksWithCompletion:(void(^)(NSDictionary *))completeBlock failedBlock:(void (^)(NSError *))block;
- (void)updateTaskInfoWithTaskID:(NSString *)taskID imageData:(NSDictionary *)data failBlock:(void(^)(NSError *))failBlock;
- (void)deleteTaskWithTaskID:(NSString *)taskID failBlock:(void (^)(NSError *))failedBlock;

@end
