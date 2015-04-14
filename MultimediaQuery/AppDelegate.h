//
//  AppDelegate.h
//  MultimediaQuery
//
//  Created by Zichuan Wang on 15/4/7.
//  Copyright (c) 2015年 zichuanwang. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MQVideoPreviewController;
@class MQQueryResultViewController;
@class MQDescriptorViewController;

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (readonly, weak, nonatomic) MQVideoPreviewController *sourcePreviewController;
@property (readonly, weak, nonatomic) MQVideoPreviewController *queryPreviewController;
@property (readonly, weak, nonatomic) MQQueryResultViewController *queryResultController;
@property (readonly, weak, nonatomic) MQDescriptorViewController *imageDescriptorController;
@property (readonly, weak, nonatomic) MQDescriptorViewController *motionDescriptorController;
@property (readonly, weak, nonatomic) MQDescriptorViewController *audioDescriptorController;

@property (readonly) NSWindowController *windowController;
@property (readonly) NSSplitViewController *rootSplitViewController;
@property (readonly) NSSplitViewController *previewSplitViewController;
@property (readonly) NSSplitViewController *descriptorSplitViewController;

@end

