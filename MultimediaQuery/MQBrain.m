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
#import "MQAudioDescriptorGenerator.h"
#import "NSNotificationCenter+Helper.h"
#import "MQMotionDebugVideoGenerator.h"

// #define SETUP_DEBUG 1

@interface MQBrain ()

typedef void (^QueryVideoSetupHandler)(void);

@property (nonatomic, strong, readwrite) NSMutableDictionary *videoStore;
@property (nonatomic, strong) NSString *rootFolderPath;
@property (nonatomic, strong) NSString *queryFolderPath;
@property (atomic, assign) NSInteger rootTaskCount;
@property (atomic, assign) NSInteger queryTaskCount;
@property (nonatomic, readonly) CGSize imageSize;
@property (nonatomic, copy) QueryVideoSetupHandler queryVideoSetupHandler;
@property (nonatomic, readonly) NSInteger videoFrameRate;

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
#ifdef SETUP_DEBUG
    subFolderPaths = @[@"musicvideo"];
#endif
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
#ifdef SETUP_DEBUG
            array = @[self.videoStore[@"/Users/zichuanwang/Downloads/source_data/musicvideo"]];
#endif
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
#ifdef SETUP_DEBUG
    array = [NSMutableArray arrayWithArray:@[self.videoStore[@"/Users/zichuanwang/Downloads/source_data/musicvideo"]]];
#endif
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

- (BOOL)motionDebugMode {
    return YES;
}

- (NSInteger)videoFrameRate {
    return 30;
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
    BOOL isDir;
    [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir];
    if (!isDir) return;
    
    MQVideo *video = [MQVideo videoWithSourceFolderPath:path];
    // Setup Preview Video
    if (!video.previewVideoFilePath) {
        [self addSetupTask:query];
        [self createPreviewVideoAtFolderPath:path completion:^(NSError *error) {
            if (!error) {
                [video setup];
            }
            [self finishSetupTask:query];
        }];
    }
    // Setup Image Descriptor
    if (!video.imageDescriptor) {
        [self addSetupTask:query];
        [self createImageDescriptorAtFolderPath:path completion:^(NSError *error) {
            if (!error) {
                [video setup];
            }
            [self finishSetupTask:query];
        }];
    }
    // Setup Motion Descriptor and Motion Debug Preview Video
    if (!video.motionDescriptor) {
        [self addSetupTask:query];
        [self createMotionDescriptorAtFolderPath:path completion:^(NSError *error) {
            if (!error) {
                [video setup];
            }
            [self finishSetupTask:query];
        }];
    } else if (self.motionDebugMode && !video.motionDebugPreviewVideoFilePath) {
        [self addSetupTask:query];
        [self createMotionDebugPreviewVideoAtFolderPath:path completion:^(NSError *error) {
            if (!error) {
                [video setup];
            }
            [self finishSetupTask:query];
        }];
    }
    // Setup Audio Descriptor
    if (!video.audioDescriptor) {
        [self addSetupTask:query];
        [self createAudioDescriptorAtFolderPath:path completion:^(NSError *error) {
            if (!error) {
                [video setup];
            }
            [self finishSetupTask:query];
        }];
    }
}

- (void)createMotionDebugPreviewVideoAtFolderPath:(NSString *)path completion:(void (^)(NSError *))handler {
    MQVideo *video = [MQVideo videoWithSourceFolderPath:path];
    MQMotionDescriptor *descriptor = video.motionDescriptor;
    MQMotionDebugVideoGenerator *generator = [[MQMotionDebugVideoGenerator alloc] initWithSourceFolderPath:path imageSize:self.imageSize frameRate:self.videoFrameRate motionDescriptor:descriptor];
    [generator generateAsynchronouslyWithCompletionHandler:^(NSError *error) {
        if (error) {
            NSLog(@"createMotionDebugPreviewVideoAtFolderPath: %@, error: %@", path, error.localizedDescription);
        }
        handler(error);
    }];
}

- (void)createAudioDescriptorAtFolderPath:(NSString *)path completion:(void (^)(NSError *))handler {
    MQAudioDescriptorGenerator *generator = [[MQAudioDescriptorGenerator alloc] initWithSourceFolderPath:path];
    [generator generateAsynchronouslyWithCompletionHandler:^(NSError *error) {
        if (error) {
            NSLog(@"createAudioDescriptorAtFolderPath: %@, error: %@", path, error.localizedDescription);
        }
        handler(error);
    }];
}

- (void)createMotionDescriptorAtFolderPath:(NSString *)path completion:(void (^)(NSError *))handler {
    MQMotionDescriptorGenerator *generator = [[MQMotionDescriptorGenerator alloc] initWithSourceFolderPath:path imageSize:self.imageSize];
    [generator generateAsynchronouslyWithCompletionHandler:^(NSError *error) {
        if (error) {
            NSLog(@"createMotionDescriptorAtFolderPath: %@, error: %@", path, error.localizedDescription);
        }
        MQVideo *video = [MQVideo videoWithSourceFolderPath:path];
        [video setup];
        if (!error && self.motionDebugMode && !video.motionDebugPreviewVideoFilePath) {
            [self createMotionDebugPreviewVideoAtFolderPath:path completion:handler];
        } else {
            handler(error);
        }
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
    MQVideoGenerator *generator = [[MQVideoGenerator alloc] initWithSourceFolderPath:path imageSize:self.imageSize frameRate:self.videoFrameRate];
    [generator generateAsynchronouslyWithCompletionHandler:^(NSError *error) {
        if (error) {
            NSLog(@"createPreviewVideoAtFolderPath: %@, error: %@", path, error.localizedDescription);
        }
        handler(error);
    }];
}

@end
