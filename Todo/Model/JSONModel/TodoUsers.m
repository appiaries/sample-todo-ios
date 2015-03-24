//
//  TodoUsers.m
//  Todo
//
//  Created by Appiaries Corporation on 11/17/14.
//  Copyright (c) 2014 Appiaries Corporation. All rights reserved.
//

#import "TodoUsers.h"

@implementation TodoUsers

#pragma mark - Initialization
- (id)initWithDict:(NSDictionary *)userDict
{
    if (self = [super init]) {
        _id        = userDict[@"_id"];
        _loginId   = userDict[@"login_id"];
        _password  = userDict[@"password"];
        _email     = userDict[@"email"];
        _autoLogin = userDict[@"auto_login"];
        _cts       = userDict[@"_cts"];
        _uts       = userDict[@"_uts"];
        _cby       = userDict[@"_cby"];
        _uby       = userDict[@"_uby"];
    }
    return  self;
}

@end
