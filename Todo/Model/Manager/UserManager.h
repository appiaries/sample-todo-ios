//
//  TopManager.h
//  Todo
//
//  Created by Appiaries Corporation on 12/8/14.
//  Copyright (c) 2014 Appiaries Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TodoUsers;

@interface UserManager : NSObject
#pragma mark - Properties
@property (readonly, nonatomic) TodoUsers *todoInfo;

#pragma mark - Initialization
+ (UserManager *)sharedManager;

#pragma mark - Public methods
- (void)createUser:(TodoUsers *)userInfo withBlock:(void (^)(NSError *))block;
- (void)getUserWithCompletion:(void(^)(NSDictionary *))completeBlock failedBlock:(void(^)(NSError *))block;
- (void)doLogin:(TodoUsers *)userInfo WithCompletion:(void (^)(NSDictionary *))completeBlock failBlock:(void(^)(NSError *))block;
- (void)updateUser:(APISAppUser *)appUser withCompletion:(void(^)(NSDictionary *))completeBlock failedBlock:(void (^)(NSError *))block;

@end

