//
//  MQDescriptorViewController.m
//  MultimediaQuery
//
//  Created by Zichuan Wang on 15/4/9.
//  Copyright (c) 2015年 zichuanwang. All rights reserved.
//

#import "MQImageDescriptorViewController.h"
#import "MQVideo.h"
#import "MQImageDescriptor.h"

@interface MQImageDescriptorViewController ()

@end

@implementation MQImageDescriptorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (void)setVideo:(MQVideo *)video {
    _dataForPlot = video.imageDescriptor.matchingScores;
    [super setVideo: video];
}

@end
