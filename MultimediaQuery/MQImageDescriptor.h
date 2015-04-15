//
//  MQImageDescriptor.h
//  MultimediaQuery
//
//  Created by Zichuan Wang on 15/4/9.
//  Copyright (c) 2015年 zichuanwang. All rights reserved.
//

#import "MQBaseDescriptor.h"

@class MQImageSignatrue;

@interface MQImageDescriptor : MQBaseDescriptor

- (void)appendImageSignature:(MQImageSignatrue *)sig;

- (void)updateWithQueryVideoImageDescriptor:(MQImageDescriptor *)query;

@end
