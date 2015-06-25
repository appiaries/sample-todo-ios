//
// Created by Appiaries Corporation on 15/05/27.
// Copyright (c) 2015 Appiaries Corporation. All rights reserved.
//

#import "Task.h"


@implementation Task
@dynamic user_id;
@dynamic type;
@dynamic title;
@dynamic body;
@dynamic status;
@dynamic position;
@dynamic scheduled_at;

#pragma mark - Initialization
+ (id)task
{
    return [[self class] object];
}

#pragma mark - ABManagedProtocol
+ (NSString *)collectionID
{
    return @"Tasks";
}

#pragma mark - ABModel overridden methods
- (id)baasInputDataFilter:(id)data forKey:(NSString *)key {
    id filtered = [super baasInputDataFilter:data forKey:key];
    if ([key isEqualToString:@"scheduled_at"]) {
        if ([data isKindOfClass:[NSNumber class]]) {
            unsigned long long longLongValue = [filtered unsignedLongLongValue];
            NSTimeInterval timeInterval = (double)(longLongValue / 1000);
            filtered = [NSDate dateWithTimeIntervalSince1970:timeInterval];
        }
    }
    return filtered;
}

- (id)baasOutputDataFilter:(id)data forKey:(NSString *)key {
    id filtered = [super baasInputDataFilter:data forKey:key];
    if ([key isEqualToString:@"scheduled_at"]) {
        if ([data isKindOfClass:[NSDate class]]) {
            NSTimeInterval timeInterval = [filtered timeIntervalSince1970];
            filtered = @((unsigned long long)(timeInterval * 1000));
        }
    }
    return filtered;
}

@end
