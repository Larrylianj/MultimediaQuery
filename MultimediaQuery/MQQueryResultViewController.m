//
//  MQQueryResultViewController.m
//  MultimediaQuery
//
//  Created by Zichuan Wang on 15/4/8.
//  Copyright (c) 2015年 zichuanwang. All rights reserved.
//

#import "MQQueryResultViewController.h"
#import "MQBrain.h"
#import "MQVideo.h"
#import "NSNotificationCenter+Helper.h"
#import "AppDelegate.h"
#import "MQVideoPreviewController.h"
#import "MQDescriptorViewController.h"

@interface MQQueryResultViewController () <NSTableViewDelegate>

@property (nonatomic, strong) IBOutlet NSArrayController *arrayController;
@property (nonatomic, strong) IBOutlet NSTableView *tableView;
@property (nonatomic, strong) NSArray *queryResults;

@end

@implementation MQQueryResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [NSNotificationCenter addObserverForDataBaseSetupFinishedNotification:^(NSNotification *note) {
        [self updateQueryResults];
    }];
    
    [NSNotificationCenter addObserverForQuerySetupFinishedNotification:^(NSNotification *note) {
        [self updateQueryResults];
        [self.tableView deselectAll:nil];
        [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:YES];
    }];
    
    NSString *sourceFolderPath = [NSString stringWithFormat:@"%@/Downloads/source_data", NSHomeDirectory()];
    [[MQBrain sharedInstance] setupWithRootFolderPath:sourceFolderPath];
}

- (void)updateQueryResults {
    //[self willChangeValueForKey:@"queryResults"];
    self.queryResults = [[MQBrain sharedInstance] queryResults];
    //[self didChangeValueForKey:@"queryResults"];
}

- (void)handleTableViewSelection {
    if (self.tableView.numberOfSelectedRows == 0) return;
    MQVideo *video = self.queryResults[self.tableView.selectedRow];
    NSLog(@"%@", video.sourceFolderPath);
    AppDelegate *delegate = [NSApplication sharedApplication].delegate;
    [delegate.sourcePreviewController setPreviewVideo:video];
    
    if ([MQBrain sharedInstance].queryVideo) {
        [delegate.imageDescriptorController setVideo:video];
        [delegate.motionDescriptorController setVideo:video];
        [delegate.audioDescriptorController setVideo:video];
    }
}

#pragma mark - NSTableViewDelegate

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    [self handleTableViewSelection];
}

@end
