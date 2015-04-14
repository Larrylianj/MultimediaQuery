//
//  NSNotificationCenter+Helper.m
//  MultimediaQuery
//
//  Created by Zichuan Wang on 15/4/9.
//  Copyright (c) 2015年 zichuanwang. All rights reserved.
//

#import "NSNotificationCenter+Helper.h"

static NSString *kDataBaseSetupFinished = @"DataBaseSetupFinished";
static NSString *kQuerySetupFinished = @"QuerySetupFinished";
static NSString *kVideoIndicatorChanged = @"VideoIndicatorChanged";

@implementation NSNotificationCenter (Helper)

+ (void)postVideoIndicatorChangedNotification:(CGFloat)percentage {
    [[NSNotificationCenter defaultCenter] postNotificationName:kVideoIndicatorChanged object:nil userInfo:@{ @"percentage": @(percentage) }];
}

+ (void)addObserverForVideoIndicatorChangedNotification:(void (^)(NSNotification *))block {
    [[NSNotificationCenter defaultCenter] addObserverForName:kVideoIndicatorChanged object:nil queue:nil usingBlock:^(NSNotification *note) {
        block(note);
    }];
}

+ (void)postDataBaseSetupFinishedNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:kDataBaseSetupFinished object:nil];
}

+ (void)addObserverForDataBaseSetupFinishedNotification:(void (^)(NSNotification *))block {
    [[NSNotificationCenter defaultCenter] addObserverForName:kDataBaseSetupFinished object:nil queue:nil usingBlock:^(NSNotification *note) {
        block(note);
    }];
}

+ (void)postQuerySetupFinishedNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:kQuerySetupFinished object:nil];
}

+ (void)addObserverForQuerySetupFinishedNotification:(void (^)(NSNotification *))block {
    [[NSNotificationCenter defaultCenter] addObserverForName:kQuerySetupFinished object:nil queue:nil usingBlock:^(NSNotification *note) {
        block(note);
    }];
}

@end
