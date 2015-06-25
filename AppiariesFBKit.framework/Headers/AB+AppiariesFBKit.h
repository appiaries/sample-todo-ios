//
// Created by Appiaries Corporation on 2015/03/21.
// Copyright (c) 2015 Appiaries Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppiariesSDK/AB.h>

@class ABFacebookService;

@interface AB (AppiariesFBKit)
#pragma mark - Properties;
@property (weak, nonatomic) ABFacebookService *facebook;

- (void)activateFacebookKit;

@end