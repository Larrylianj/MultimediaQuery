//
//  MQAudioDescriptorController.m
//  MultimediaQuery
//
//  Created by Zichuan Wang on 15/4/17.
//  Copyright (c) 2015年 zichuanwang. All rights reserved.
//

#import "MQAudioDescriptorController.h"
#import "MQVideo.h"
#import "MQAudioDescriptor.h"

@interface MQAudioDescriptorController ()

@end

@implementation MQAudioDescriptorController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (void)setVideo:(MQVideo *)video {
    _dataForPlot = video.audioDescriptor.matchingScores;
    [super setVideo: video];
}

- (NSColor *)themeColor {
    return [NSColor colorWithRed:114 / 255. green:95 / 255. blue:161 / 255. alpha:1];
}

@end
