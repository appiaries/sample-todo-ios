//
//  TodoUsers.h
//  Todo
//
//  Created by Appiaries Corporation on 11/17/14.
//  Copyright (c) 2014 Appiaries Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TodoUsers : NSObject
#pragma mark - Properties
@property  (strong, nonatomic) NSString *id;
@property  (strong, nonatomic) NSString *loginId;
@property  (strong, nonatomic) NSString *password;
@property  (strong, nonatomic) NSString *email;
@property  (strong, nonatomic) NSNumber *autoLogin;
@property  (strong, nonatomic) NSNumber *cts;
@property  (strong, nonatomic) NSNumber *uts;
@property  (strong, nonatomic) NSString *cby;
@property  (strong, nonatomic) NSString *uby;

#pragma mark - Initialization
- (id)initWithDict:(NSDictionary *)userDict;

@end
