//
//  MQSourceVideoPreviewController.m
//  MultimediaQuery
//
//  Created by Zichuan Wang on 15/4/10.
//  Copyright (c) 2015年 zichuanwang. All rights reserved.
//

#import "MQSourceVideoPreviewController.h"
#import "NSNotificationCenter+Helper.h"

@interface MQSourceVideoPreviewController ()

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, assign) CGFloat currentPercentage;

@end

@implementation MQSourceVideoPreviewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    self.timer = [NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(updateVideoIndicator) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
}

- (void)updateVideoIndicator {
    if (!self.playerView.player.currentItem) return;
    double curr = CMTimeGetSeconds(self.playerView.player.currentTime);
    double duration = CMTimeGetSeconds(self.playerView.player.currentItem.duration);
    CGFloat percentage = curr / duration;
    
    if (percentage != self.currentPercentage) {
        self.currentPercentage = percentage;
        if (!isnan(percentage))
            [NSNotificationCenter postVideoIndicatorChangedNotification:percentage];
    }
}

@end
