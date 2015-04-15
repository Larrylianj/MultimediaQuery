//
//  MQBrain.m
//  MultimediaQuery
//
//  Created by Zichuan Wang on 15/4/8.
//  Copyright (c) 2015年 zichuanwang. All rights reserved.
//

#import "MQBrain.h"
#import "MQVideo.h"
#import "MQVideoGenerator.h"
#import "MQImageDescriptorGenerator.h"
#import "MQMotionDescriptorGenerator.h"
#import "NSNotificationCenter+Helper.h"

@interface MQBrain ()

typedef void (^QueryVideoSetupHandler)(void);

@property (nonatomic, strong, readwrite) NSMutableDictionary *videoStore;
@property (nonatomic, strong) NSString *rootFolderPath;
@property (nonatomic, strong) NSString *queryFolderPath;
@property (atomic, assign) NSInteger rootTaskCount;
@property (atomic, assign) NSInteger queryTaskCount;
@property (nonatomic, readonly) CGSize imageSize;
@property (nonatomic, copy) QueryVideoSetupHandler queryVideoSetupHandler;

@end

@implementation MQBrain

+ (instancetype)sharedInstance {
    static dispatch_once_t MQBrainPredicate;
    static id sharedInstance;
    dispatch_once(&MQBrainPredicate, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)setupWithRootFolderPath:(NSString *)path {
    self.rootFolderPath = path;
    NSArray *subFolderPaths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
    // subFolderPaths = @[@"musicvideo"];
    for (NSString *subPath in subFolderPaths) {
        [self setupVideoAtFolderPath:[path stringByAppendingFormat:@"/%@", subPath] isQueryFile:NO];
    }
    if (self.rootTaskCount == 0) {
        [NSNotificationCenter postDataBaseSetupFinishedNotification];
    }
}

- (BOOL)setupQueryFolderURL:(NSURL *)url {
    if (self.queryFolderPath) [self.videoStore removeObjectForKey:self.queryFolderPath];
    self.queryFolderPath = url.path;
    NSLog(@"query folder path %@", self.queryFolderPath);
    [self setupVideoAtFolderPath:self.queryFolderPath isQueryFile:YES];
    [self queryInDataBaseAsynchronously];
    return YES;
}

- (void)queryInDataBaseAsynchronously {
    [self waitForQueryVideoSetup:^{
        [self addSetupTask:YES];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSArray *array = self.videoStore.allValues;
            // array = @[self.videoStore[@"/Users/zichuanwang/Downloads/source_data/musicvideo"]];
            for (MQVideo *video in array) {
                if (video != self.queryVideo) {
                    [video updateDescriptorsWithQueryVideo:self.queryVideo];
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self finishSetupTask:YES];
            });
        });
    }];
}

- (void)waitForQueryVideoSetup:(void (^)(void))handler {
    if (self.queryTaskCount == 0) handler();
    else self.queryVideoSetupHandler = handler;
}

- (NSArray *)queryResults {
    NSMutableArray *array = [NSMutableArray arrayWithArray:self.videoStore.allValues];
    [array removeObject:self.queryVideo];
    
    // array = [NSMutableArray arrayWithArray:@[self.videoStore[@"/Users/zichuanwang/Downloads/source_data/musicvideo"]]];
    
    [array sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        float a = [obj1 totalScore];
        float b = [obj2 totalScore];
        if (a == b) {
            return [[obj1 name] compare:[obj2 name]];
        } else if (a > b) {
            return NSOrderedAscending;
        } else {
            return NSOrderedDescending;
        }
    }];
    return array;
}

#pragma mark - Properties

- (CGSize)imageSize {
    return CGSizeMake(352, 288);
}

- (NSMutableDictionary *)videoStore {
    if (!_videoStore) {
        _videoStore = [[NSMutableDictionary alloc] init];
    }
    return _videoStore;
}

- (MQVideo *)queryVideo {
    return [MQVideo videoWithSourceFolderPath:self.queryFolderPath];
}

#pragma mark - Logic

- (void)reportRootSetupTaskFinished {
    self.rootTaskCount--;
    NSLog(@"left root task count: %@", @(self.rootTaskCount));
    if (self.rootTaskCount == 0) {
        [NSNotificationCenter postDataBaseSetupFinishedNotification];
    }
}

- (void)reportQuerySetupTaskFinished {
    self.queryTaskCount--;
    NSLog(@"left query task count: %@", @(self.queryTaskCount));
    if (self.queryTaskCount == 0) {
        if (self.queryVideoSetupHandler) {
            self.queryVideoSetupHandler();
            self.queryVideoSetupHandler = nil;
        } else {
            [NSNotificationCenter postQuerySetupFinishedNotification];
        }
    }
}

- (void)addSetupTask:(BOOL)isQuery {
    if (isQuery) {
        self.queryTaskCount++;
    } else {
        self.rootTaskCount++;
    }
}

- (void)finishSetupTask:(BOOL)isQuery {
    if (isQuery) {
        [self reportQuerySetupTaskFinished];
    } else {
        [self reportRootSetupTaskFinished];
    }
}

- (void)setupVideoAtFolderPath:(NSString *)path isQueryFile:(BOOL)query {
    // NSLog(@"setupVideoAtFolderPath: %@, isQueryFile: %@", path, @(query));
    BOOL isDir;
    [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir];
    if (!isDir) return;
    
    MQVideo *video = [MQVideo videoWithSourceFolderPath:path];
    if (!video.previewVideoFilePath) {
        [self addSetupTask:query];
        [self createPreviewVideoAtFolderPath:path completion:^(NSError *error) {
            if (!error) {
                [video setup];
            }
            [self finishSetupTask:query];
        }];
    }
    if (!video.imageDescriptor) {
        [self addSetupTask:query];
        [self createImageDescriptorAtFolderPath:path completion:^(NSError *error) {
            if (!error) {
                [video setup];
            }
            [self finishSetupTask:query];
        }];
    }
    if (!video.motionDescriptor) {
        [self addSetupTask:query];
        [self createMotionDescriptorAtFolderPath:path completion:^(NSError *error) {
            if (!error) {
                [video setup];
            }
            [self finishSetupTask:query];
        }];
    }
}

- (void)createMotionDescriptorAtFolderPath:(NSString *)path completion:(void (^)(NSError *))handler {
    MQMotionDescriptorGenerator *generator = [[MQMotionDescriptorGenerator alloc] initWithSourceFolderPath:path imageSize:self.imageSize];
    [generator generateAsynchronouslyWithCompletionHandler:^(NSError *error) {
        if (error) {
            NSLog(@"createMotionDescriptorAtFolderPath: %@, error: %@", path, error.localizedDescription);
        }
        handler(error);
    }];
}

- (void)createImageDescriptorAtFolderPath:(NSString *)path completion:(void (^)(NSError *))handler {
    MQImageDescriptorGenerator *generator = [[MQImageDescriptorGenerator alloc] initWithSourceFolderPath:path imageSize:self.imageSize];
    [generator generateAsynchronouslyWithCompletionHandler:^(NSError *error) {
        if (error) {
            NSLog(@"createImageDescriptorAtFolderPath: %@, error: %@", path, error.localizedDescription);
        }
        handler(error);
    }];
}

- (void)createPreviewVideoAtFolderPath:(NSString *)path completion:(void (^)(NSError *))handler {
    MQVideoGenerator *generator = [[MQVideoGenerator alloc] initWithSourceFolderPath:path imageSize:self.imageSize frameRate:30];
    [generator generateAsynchronouslyWithCompletionHandler:^(NSError *error) {
        if (error) {
            NSLog(@"createPreviewVideoAtFolderPath: %@, error: %@", path, error.localizedDescription);
        }
        handler(error);
    }];
}

@end
