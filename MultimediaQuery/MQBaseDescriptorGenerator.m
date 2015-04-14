//
//  MQBaseDescriptorGenerator.m
//  MultimediaQuery
//
//  Created by Zichuan Wang on 15/4/11.
//  Copyright (c) 2015年 zichuanwang. All rights reserved.
//

#import "MQBaseDescriptorGenerator.h"

@interface MQBaseDescriptorGenerator ()

@property (nonatomic, copy) NSString *sourceFolderPath;

@end

@implementation MQBaseDescriptorGenerator

- (id)initWithSourceFolderPath:(NSString *)path {
    self = [super init];
    if (self) {
        self.sourceFolderPath = path;
    }
    return self;
}

- (void)generateAsynchronouslyWithCompletionHandler:(void (^)(NSError *))handler {
    
}

- (NSURL *)targetJSONFileURL {
    return [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", self.sourceFolderPath, self.targetJSONFileName]];
}

@end
