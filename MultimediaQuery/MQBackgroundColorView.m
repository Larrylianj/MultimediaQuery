//
//  MQBackgroundColorView.m
//  MultimediaQuery
//
//  Created by Zichuan Wang on 15/4/10.
//  Copyright (c) 2015年 zichuanwang. All rights reserved.
//

#import "MQBackgroundColorView.h"

@implementation MQBackgroundColorView

- (void)drawRect:(NSRect)aRect {
    [[NSColor whiteColor] set];
    NSRectFill([self bounds]);
}

@end
