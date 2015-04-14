//
//  NSNotificationCenter+Helper.h
//  MultimediaQuery
//
//  Created by Zichuan Wang on 15/4/9.
//  Copyright (c) 2015年 zichuanwang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNotificationCenter (Helper)

+ (void)postDataBaseSetupFinishedNotification;

+ (void)addObserverForDataBaseSetupFinishedNotification:(void (^)(NSNotification *))block;

+ (void)postQuerySetupFinishedNotification;

+ (void)addObserverForQuerySetupFinishedNotification:(void (^)(NSNotification *))block;

+ (void)postVideoIndicatorChangedNotification:(CGFloat)percentage;

+ (void)addObserverForVideoIndicatorChangedNotification:(void (^)(NSNotification *))block;

@end
