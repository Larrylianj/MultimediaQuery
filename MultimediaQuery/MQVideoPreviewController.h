//
//  MQVideoPreviewController.h
//  MultimediaQuery
//
//  Created by Zichuan Wang on 15/4/9.
//  Copyright (c) 2015年 zichuanwang. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

@class MQVideo;

@interface MQVideoPreviewController : NSViewController

@property (nonatomic, weak) IBOutlet AVPlayerView *playerView;

- (void)setPreviewVideo:(MQVideo *)video;

@end
