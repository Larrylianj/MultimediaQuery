//
//  MQAudioDescriptor.h
//  MultimediaQuery
//
//  Created by Zichuan Wang on 15/4/17.
//  Copyright (c) 2015年 zichuanwang. All rights reserved.
//

#import "MQBaseDescriptor.h"

@class MQAudioSignature;

@interface MQAudioDescriptor : MQBaseDescriptor

- (void)updateWithQueryVideoAudioDescriptor:(MQAudioDescriptor *)query;

- (void)appendAudioSignature:(MQAudioSignature *)sig;

@end
