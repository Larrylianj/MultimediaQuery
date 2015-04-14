//
//  MQQueryVideoPreviewController.m
//  MultimediaQuery
//
//  Created by Zichuan Wang on 15/4/9.
//  Copyright (c) 2015年 zichuanwang. All rights reserved.
//

#import "MQQueryVideoPreviewController.h"
#import "NSNotificationCenter+Helper.h"
#import "AVDroppablePlayerView.h"
#import "MQBrain.h"
#import "MQVideo.h"

@interface MQQueryVideoPreviewController () <AVDroppablePlayerViewDelegate>

@end

@implementation MQQueryVideoPreviewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [NSNotificationCenter addObserverForQuerySetupFinishedNotification:^(NSNotification *note) {
        MQVideo *video = [MQBrain sharedInstance].queryVideo;
        [self setPreviewVideo:video];
    }];
}

- (BOOL)dropFileURL:(NSURL *)fileURL {
    [[MQBrain sharedInstance] setupQueryFolderURL:fileURL];
    return YES;
}

@end
