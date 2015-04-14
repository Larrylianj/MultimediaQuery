//
//  MQDescriptorViewController.h
//  MultimediaQuery
//
//  Created by Zichuan Wang on 15/4/10.
//  Copyright (c) 2015年 zichuanwang. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MQVideo;

@interface MQDescriptorViewController : NSViewController {
    NSArray *_dataForPlot;
}

- (void)setVideo:(MQVideo *)video;

@end
