//
//  AVDroppablePlayerView.h
//  MultimediaQuery
//
//  Created by Zichuan Wang on 15/4/9.
//  Copyright (c) 2015年 zichuanwang. All rights reserved.
//

#import <AVKit/AVKit.h>

@class AVDroppablePlayerView;

@protocol AVDroppablePlayerViewDelegate <NSObject>

- (BOOL)dropFileURL:(NSURL *)fileURL;

@end

@interface AVDroppablePlayerView : AVPlayerView

@property (nonatomic, weak) IBOutlet id<AVDroppablePlayerViewDelegate> delegate;

@end
