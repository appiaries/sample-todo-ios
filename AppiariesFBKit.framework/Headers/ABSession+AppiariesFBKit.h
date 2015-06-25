//
// Created by Appiaries Corporation on 15/03/20.
// Copyright (c) 2015 Appiaries Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppiariesSDK/ABSession.h>

@class FBSession;

@interface ABSession (AppiariesFBKit)
#pragma mark - Properties
@property (weak, nonatomic) FBSession *facebook;

- (void)invalidateFacebookSession;

@end