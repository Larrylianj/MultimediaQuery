//
//  MQMotionDebugVideoGenerator.h
//  MultimediaQuery
//
//  Created by Zichuan Wang on 15/4/15.
//  Copyright (c) 2015年 zichuanwang. All rights reserved.
//

#import "MQVideoGenerator.h"

@class MQMotionDescriptor;

@interface MQMotionDebugVideoGenerator : MQVideoGenerator

- (id)initWithSourceFolderPath:(NSString *)path
                     imageSize:(CGSize)size
                     frameRate:(NSInteger)rate
              motionDescriptor:(MQMotionDescriptor *)descriptor;

@end
