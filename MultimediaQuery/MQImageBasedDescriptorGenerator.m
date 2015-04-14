//
//  MQBaseDescriptorGenerator.m
//  MultimediaQuery
//
//  Created by Zichuan Wang on 15/4/11.
//  Copyright (c) 2015年 zichuanwang. All rights reserved.
//

#import "MQImageBasedDescriptorGenerator.h"

@interface MQImageBasedDescriptorGenerator ()

@property (nonatomic, assign) CGSize imageSize;

@end

@implementation MQImageBasedDescriptorGenerator

- (id)initWithSourceFolderPath:(NSString *)path imageSize:(CGSize)size {
    self = [super initWithSourceFolderPath:path];
    if (self) {
        self.imageSize = size;
    }
    return self;
}

@end
