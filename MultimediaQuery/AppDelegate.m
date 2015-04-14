//
//  AppDelegate.m
//  MultimediaQuery
//
//  Created by Zichuan Wang on 15/4/7.
//  Copyright (c) 2015年 zichuanwang. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (NSWindowController *)windowController {
    NSWindow *window = [NSApplication sharedApplication].windows.firstObject;
    NSWindowController *windowController = window.windowController;
    return windowController;
}

- (NSSplitViewController *)rootSplitViewController {
    NSSplitViewController *rootSplitViewController = (NSSplitViewController *)self.windowController.contentViewController;
    return rootSplitViewController;
}

- (MQQueryResultViewController *)queryResultController {
    NSSplitViewItem *item = self.rootSplitViewController.splitViewItems[0];
    return (MQQueryResultViewController *)item.viewController;
}

- (NSSplitViewController *)previewSplitViewController {
    NSSplitViewItem *item = self.rootSplitViewController.splitViewItems[1];
    return (NSSplitViewController *)item.viewController;
}

- (NSSplitViewController *)descriptorSplitViewController {
    NSSplitViewItem *item = self.rootSplitViewController.splitViewItems[2];
    return (NSSplitViewController *)item.viewController;
}

- (MQVideoPreviewController *)sourcePreviewController {
    NSSplitViewItem *item = self.previewSplitViewController.splitViewItems[1];
    return (MQVideoPreviewController *)item.viewController;
}

- (MQVideoPreviewController *)queryPreviewController {
    NSSplitViewItem *item = self.previewSplitViewController.splitViewItems[0];
    return (MQVideoPreviewController *)item.viewController;
}

- (MQDescriptorViewController *)imageDescriptorController {
    NSSplitViewItem *item = self.descriptorSplitViewController.splitViewItems[0];
    return (MQDescriptorViewController *)item.viewController;
}

- (MQDescriptorViewController *)motionDescriptorController {
    NSSplitViewItem *item = self.descriptorSplitViewController.splitViewItems[1];
    return (MQDescriptorViewController *)item.viewController;
}

- (MQDescriptorViewController *)audioDescriptorController {
    NSSplitViewItem *item = self.descriptorSplitViewController.splitViewItems[2];
    return (MQDescriptorViewController *)item.viewController;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
