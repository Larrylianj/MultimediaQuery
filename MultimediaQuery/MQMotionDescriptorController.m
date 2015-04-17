//
//  MQMotionDescriptorController.m
//  MultimediaQuery
//
//  Created by Zichuan Wang on 15/4/11.
//  Copyright (c) 2015年 zichuanwang. All rights reserved.
//

#import "MQMotionDescriptorController.h"
#import "MQVideo.h"
#import "MQMotionDescriptor.h"

@interface MQMotionDescriptorController ()

@end

@implementation MQMotionDescriptorController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (void)setVideo:(MQVideo *)video {
    _dataForPlot = video.motionDescriptor.matchingScores;
    [super setVideo: video];
}

- (NSColor *)themeColor {
    return [NSColor colorWithRed:32 / 255. green:217 / 255. blue:182 / 255. alpha:1];
}

@end
