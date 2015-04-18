//
//  MQVideo.h
//  MultimediaQuery
//
//  Created by Zichuan Wang on 15/4/8.
//  Copyright (c) 2015年 zichuanwang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MQImageDescriptor;
@class MQMotionDescriptor;
@class MQAudioDescriptor;

@interface MQVideo : NSObject

@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, assign, readonly) float totalScore;
@property (nonatomic, assign, readonly) NSUInteger maxTotalScoreIndex;
@property (nonatomic, assign, readonly) float imageScore;
@property (nonatomic, assign, readonly) float motionScore;
@property (nonatomic, assign, readonly) float audioScore;
@property (nonatomic, copy, readonly) NSString *sourceFolderPath;

@property (nonatomic, readonly) NSString *totalScoreString;
@property (nonatomic, readonly) NSString *imageScoreString;
@property (nonatomic, readonly) NSString *motionScoreString;
@property (nonatomic, readonly) NSString *audioScoreString;
@property (nonatomic, readonly) NSString *previewVideoFilePath;
@property (nonatomic, readonly) NSString *motionDebugPreviewVideoFilePath;

// @property (nonatomic, readonly) NSString *audioFilePath;

@property (nonatomic, strong, readonly) MQImageDescriptor *imageDescriptor;
@property (nonatomic, strong, readonly) MQMotionDescriptor *motionDescriptor;
@property (nonatomic, strong, readonly) MQAudioDescriptor *audioDescriptor;

+ (MQVideo *)videoWithSourceFolderPath:(NSString *)path;

- (void)updateDescriptorsWithQueryVideo:(MQVideo *)video;

- (void)setup;

@end
