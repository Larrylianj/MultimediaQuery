//
//  MQMotionDescriptor.h
//  MultimediaQuery
//
//  Created by Zichuan Wang on 15/4/11.
//  Copyright (c) 2015年 zichuanwang. All rights reserved.
//

#import "MQBaseDescriptor.h"

@class MQMotionSignature;

@interface MQMotionDescriptor : MQBaseDescriptor

- (void)appendMotionSignature:(MQMotionSignature *)sig;

- (void)updateWithQueryVideoMotionDescriptor:(MQMotionDescriptor *)query;

@end
