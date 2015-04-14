//
//  MQVideoPreviewController.m
//  MultimediaQuery
//
//  Created by Zichuan Wang on 15/4/9.
//  Copyright (c) 2015年 zichuanwang. All rights reserved.
//

#import "MQVideoPreviewController.h"
#import "MQVideo.h"

@interface MQVideoPreviewController ()

@end

@implementation MQVideoPreviewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (void)setPreviewVideo:(MQVideo *)video {
    NSURL *fileURL = [NSURL fileURLWithPath:video.previewVideoFilePath];
    AVPlayerItem *playItem = [AVPlayerItem playerItemWithURL:fileURL];
    if (!self.playerView.player) {
        AVPlayer *player = [AVPlayer playerWithPlayerItem:playItem];
        self.playerView.player = player;
    } else {
        [self.playerView.player pause];
        [self.playerView.player replaceCurrentItemWithPlayerItem:playItem];
    }
}

@end
