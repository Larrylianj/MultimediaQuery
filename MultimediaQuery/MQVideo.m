//
//  MQVideo.m
//  MultimediaQuery
//
//  Created by Zichuan Wang on 15/4/8.
//  Copyright (c) 2015年 zichuanwang. All rights reserved.
//

#import "MQVideo.h"
#import "MQBrain.h"
#import "MQImageDescriptor.h"
#import "MQMotionDescriptor.h"

@interface MQVideo ()

@property (nonatomic, readwrite) NSString *name;
@property (nonatomic, readwrite) float totalScore;
@property (nonatomic, readwrite) float imageScore;
@property (nonatomic, readwrite) float motionScore;
@property (nonatomic, readwrite) float audioScore;
@property (nonatomic, readwrite) NSString *sourceFolderPath;
@property (nonatomic, readwrite) NSString *previewVideoFileName;
@property (nonatomic, readwrite) NSString *audioFileName;
@property (nonatomic, readwrite) MQImageDescriptor *imageDescriptor;
@property (nonatomic, readwrite) MQMotionDescriptor *motionDescriptor;

@end

@implementation MQVideo

- (NSString *)totalScoreString {
    return [NSString stringWithFormat:@"%.0f%%", self.totalScore * 100];
}

- (NSString *)imageScoreString {
    return [NSString stringWithFormat:@"%.0f%%", self.imageScore * 100];
}

- (NSString *)motionScoreString {
    return [NSString stringWithFormat:@"%.0f%%", self.motionScore * 100];
}

- (NSString *)audioScoreString {
    return [NSString stringWithFormat:@"%.0f%%", self.audioScore * 100];
}

- (NSString *)previewVideoFilePath {
    if (self.previewVideoFileName)
        return [NSString stringWithFormat:@"%@/%@", self.sourceFolderPath, self.previewVideoFileName];
    else
        return nil;
}

+ (MQVideo *)videoWithSourceFolderPath:(NSString *)path {
    if (!path) return nil;
    MQVideo *video = [MQBrain sharedInstance].videoStore[path];
    if (!video) {
        video = [[MQVideo alloc] init];
        video.name = path.lastPathComponent;
        video.sourceFolderPath = path;
        [MQBrain sharedInstance].videoStore[path] = video;
        
        [video setup];
    }
    return video;
}

- (void)setup {
    NSFileManager *manager = [NSFileManager defaultManager];
    
    NSString *compliedVideoFileName = [NSString stringWithFormat:@"%@_compile.mov", self.name];
    NSString *compliedVideoFilePath = [NSString stringWithFormat:@"%@/%@", self.sourceFolderPath, compliedVideoFileName];
    if ([manager fileExistsAtPath:compliedVideoFilePath]) {
        self.previewVideoFileName = compliedVideoFileName;
    }
    
    NSString *imageDescriptorFileName = [NSString stringWithFormat:@"%@_image_descriptor.json", self.name];
    NSString *imageDescriptorFilePath = [NSString stringWithFormat:@"%@/%@", self.sourceFolderPath, imageDescriptorFileName];
    if ([manager fileExistsAtPath:imageDescriptorFilePath]) {
        self.imageDescriptor = [[MQImageDescriptor alloc] initWithJSONFilePath:imageDescriptorFilePath];
    }
    
    NSString *motionDescriptorFileName = [NSString stringWithFormat:@"%@_motion_descriptor.json", self.name];
    NSString *motionDescriptorFilePath = [NSString stringWithFormat:@"%@/%@", self.sourceFolderPath, motionDescriptorFileName];
    if ([manager fileExistsAtPath:motionDescriptorFilePath]) {
        self.motionDescriptor = [[MQMotionDescriptor alloc] initWithJSONFilePath:motionDescriptorFilePath];
    }
}

- (void)updateDescriptorsWithQueryVideo:(MQVideo *)video {
    self.motionScore = [self.motionDescriptor updateWithQueryVideoMotionDescriptor:video.motionDescriptor];
    self.imageScore = [self.imageDescriptor updateWithQueryVideoImageDescriptor:video.imageDescriptor];
    self.totalScore = self.imageScore * 0.6 + self.motionScore * 0.4;
}

@end
