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
#import "MQAudioDescriptor.h"

@interface MQVideo ()

@property (nonatomic, readwrite) NSString *name;
@property (nonatomic, readwrite) float totalScore;
@property (nonatomic, readwrite) float imageScore;
@property (nonatomic, readwrite) float motionScore;
@property (nonatomic, readwrite) float audioScore;
@property (nonatomic, readwrite) NSString *sourceFolderPath;
@property (nonatomic, readwrite) NSString *previewVideoFileName;
@property (nonatomic, readwrite) NSString *motionDebugPreviewVideoFileName;
@property (nonatomic, readwrite) NSString *audioFileName;
@property (nonatomic, readwrite) MQImageDescriptor *imageDescriptor;
@property (nonatomic, readwrite) MQMotionDescriptor *motionDescriptor;
@property (nonatomic, readwrite) MQAudioDescriptor *audioDescriptor;
@property (nonatomic, readwrite) NSUInteger maxTotalScoreIndex;

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
    if (self.previewVideoFileName) {
        return [NSString stringWithFormat:@"%@/%@", self.sourceFolderPath, self.previewVideoFileName];
    } else {
        return nil;
    }
}

- (NSString *)motionDebugPreviewVideoFilePath {
    if (self.motionDebugPreviewVideoFileName) {
        return [NSString stringWithFormat:@"%@/%@", self.sourceFolderPath, self.motionDebugPreviewVideoFileName];
    } else {
        return nil;
    }
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
    
    NSString *compliedMotionDebugVideoFileName = [NSString stringWithFormat:@"%@_compile_motion_debug.mov", self.name];
    NSString *compliedMotionDebugVideoFilePath = [NSString stringWithFormat:@"%@/%@", self.sourceFolderPath, compliedMotionDebugVideoFileName];
    if ([manager fileExistsAtPath:compliedMotionDebugVideoFilePath]) {
        self.motionDebugPreviewVideoFileName = compliedMotionDebugVideoFileName;
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
    
    NSString *audioDescriptorFileName = [NSString stringWithFormat:@"%@_audio_descriptor.json", self.name];
    NSString *audioDescriptorFilePath = [NSString stringWithFormat:@"%@/%@", self.sourceFolderPath, audioDescriptorFileName];
    if ([manager fileExistsAtPath:audioDescriptorFilePath]) {
        self.audioDescriptor = [[MQAudioDescriptor alloc] initWithJSONFilePath:audioDescriptorFilePath];
    }
}

- (void)updateDescriptorsWithQueryVideo:(MQVideo *)video {
    [self.imageDescriptor updateWithQueryVideoImageDescriptor:video.imageDescriptor];
    [self.motionDescriptor updateWithQueryVideoMotionDescriptor:video.motionDescriptor];
    [self.audioDescriptor updateWithQueryVideoAudioDescriptor:video.audioDescriptor];
    
    self.totalScore = 0;
    for (NSUInteger i = 0; i < self.imageDescriptor.matchingScores.count; i++) {
        float imageScore = [self.imageDescriptor.matchingScores[i] floatValue];
        float motionScore = [self.motionDescriptor.matchingScores[i] floatValue];
        float audioScore = [self.audioDescriptor.matchingScores[i] floatValue];
        float totalScore = imageScore * 0.5 + motionScore * 0.3 + audioScore * 0.2;
        if (totalScore > self.totalScore) {
            self.totalScore = totalScore;
            self.imageScore = imageScore;
            self.motionScore = motionScore;
            self.audioScore = audioScore;
            self.maxTotalScoreIndex = i;
        }
    }
}

@end
