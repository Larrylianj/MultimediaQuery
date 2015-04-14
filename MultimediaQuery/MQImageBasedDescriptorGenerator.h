//
//  MQBaseDescriptorGenerator.h
//  MultimediaQuery
//
//  Created by Zichuan Wang on 15/4/11.
//  Copyright (c) 2015年 zichuanwang. All rights reserved.
//

#import "MQBaseDescriptorGenerator.h"

@interface MQImageBasedDescriptorGenerator : MQBaseDescriptorGenerator

@property (nonatomic, readonly) CGSize imageSize;

- (id)initWithSourceFolderPath:(NSString *)path imageSize:(CGSize)size;

@end
