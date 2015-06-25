//
// Created by Appiaries Corporation on 15/03/20.
// Copyright (c) 2015 Appiaries Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppiariesSDK/ABConfig.h>

@class ABFacebookConfig;

@interface ABConfig (AppiariesFBKit)
#pragma mark - Properties
@property (weak, nonatomic) ABFacebookConfig *facebook;

@end