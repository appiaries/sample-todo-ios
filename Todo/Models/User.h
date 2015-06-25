//
// Created by Appiaries Corporation on 15/05/27.
// Copyright (c) 2015 Appiaries Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface User : ABUser <ABManagedProtocol>
#pragma mark - Properties
@property (strong, nonatomic) NSString *nickname;

#pragma mark - Initialization
+ (id)user;

@end
