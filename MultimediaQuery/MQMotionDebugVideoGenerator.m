//
//  MQMotionDebugVideoGenerator.m
//  MultimediaQuery
//
//  Created by Zichuan Wang on 15/4/15.
//  Copyright (c) 2015年 zichuanwang. All rights reserved.
//

#import "MQMotionDebugVideoGenerator.h"
#import "MQMotionDescriptor.h"

@interface MQMotionDebugVideoGenerator ()

@property (nonatomic, strong) MQMotionDescriptor *descriptor;

@end

@implementation MQMotionDebugVideoGenerator

#pragma mark - Methods to overwrite

- (id)initWithSourceFolderPath:(NSString *)path imageSize:(CGSize)size frameRate:(NSInteger)rate motionDescriptor:(MQMotionDescriptor *)descriptor {
    self = [super initWithSourceFolderPath:path imageSize:size frameRate:rate];
    if (self) {
        self.descriptor = descriptor;
    }
    return self;
}

- (BOOL)shouldAddEffectOnPixelForFrame:(int)frame atIndex:(int)idx {
    return [self.descriptor detectedMovementAtFrame:frame pixelIndex:idx];
}

- (uint32_t)pixelForFrame:(int)frame atIndex:(int)idx rgb:(unsigned char *)rgb {
    if (![self shouldAddEffectOnPixelForFrame:frame atIndex:idx]) {
        return [super pixelForFrame:frame atIndex:idx rgb:rgb];
    }
    // NSLog(@"%@", @(idx));
    const uint32_t a = 100;
    uint32_t r = (255 * a + (rgb[idx] & 0xff) * (255 - a)) / 255;
    uint32_t g = (rgb[idx + self.imageArea] & 0xff) * (255 - a) / 255;
    uint32_t b = (rgb[idx + self.imageArea * 2] & 0xff) * (255 - a) / 255;
    uint32_t pix = 0xff | (b << 24) | (g << 16) | (r << 8);
    return pix;
}

- (NSString *)targetVideoFileName {
    return [NSString stringWithFormat:@"%@_video_motion_debug.mp4", self.sourceFolderPath.lastPathComponent];
}

- (NSString *)targetCompiledFileName {
    return [NSString stringWithFormat:@"%@_compile_motion_debug.mov", self.sourceFolderPath.lastPathComponent];
}


@end
