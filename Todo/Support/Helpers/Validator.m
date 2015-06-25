//
// Created by Appiaries Corporation on 15/05/27.
// Copyright (c) 2015 Appiaries Corporation. All rights reserved.
//

#import "Validator.h"


@implementation Validator

+ (ABError *)validateFor:(NSString *)key value:(id)value rules:(NSArray *)rules ruleArgs:(NSDictionary *)ruleArgs
{
    for (id r in rules) {
        ValidationRule rule = (ValidationRule)[r intValue];

        switch (rule) {
            case ValidationRuleRequired:
                if (!value || [value isEqual:[NSNull null]]) {
                    NSString *msg = [Validator messageForRule:ValidationRuleRequired ruleArgs:ruleArgs
                                                 defaultMessage:@"Insufficient parameter. [param: %@]"];
                    return [ABError errorWithDomain:@"com.appiaries" code:10001 userInfo:@{
                            NSLocalizedDescriptionKey : [NSString stringWithFormat:msg, key],
                    }];
                }
                break;
            case ValidationRuleEmail: {
                NSPredicate *emailPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"];
                if (![emailPredicate evaluateWithObject:value]) {
                    NSString *msg = [Validator messageForRule:ValidationRuleRequired ruleArgs:ruleArgs
                                               defaultMessage:@"Invalid email address. [param: %@]"];
                    return [ABError errorWithDomain:@"com.appiaries" code:10001 userInfo:@{
                            NSLocalizedDescriptionKey : [NSString stringWithFormat:msg, key],
                    }];
                }
            }
                break;
            default:
                break;
        }
    }
    return nil;
}

#pragma mark - Private methods
+ (NSString *)messageForRule:(ValidationRule)rule ruleArgs:(NSDictionary *)ruleArgs
{
    return [Validator messageForRule:rule ruleArgs:ruleArgs defaultMessage:nil];
}
+ (NSString *)messageForRule:(ValidationRule)rule ruleArgs:(NSDictionary *)ruleArgs defaultMessage:(NSString *)defaultMessage
{
    if (ruleArgs) {
        NSDictionary *args =ruleArgs[@(rule)];
        if (args) {
            NSString *msg = args[@"msg"];
            if (msg && [msg isEqual:[NSNull null]]) {
                return msg;
            }
        }
    }
    return defaultMessage;
}

@end
