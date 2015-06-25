//
// Created by Appiaries Corporation on 15/05/27.
// Copyright (c) 2015 Appiaries Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, ValidationRule) {
    ValidationRuleRequired,
    ValidationRuleEmail,
    ValidationRuleObjectId,
    ValidationRuleLoginId,
    ValidationRulePassword,
};

@interface Validator : NSObject
+ (ABError *)validateFor:(NSString *)key value:(id)value rules:(NSArray *)rules ruleArgs:(NSDictionary *)ruleArgs;
@end
