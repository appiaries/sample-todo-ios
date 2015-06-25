//
// Created by Appiaries Corporation on 15/05/27.
// Copyright (c) 2015 Appiaries Corporation. All rights reserved.
//

#import "User.h"


@implementation User
@dynamic nickname;

#pragma mark - Initialization
+ (id)user
{
//    return [[self class] user]; //FIXME:
    return [[ABUser class] user];
}

#pragma mark - ABManagedProtocol
+ (NSString *)collectionID
{
    return @"User";
}

@end
