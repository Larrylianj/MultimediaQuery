//
//  MQBaseDescriptorGenerator.h
//  MultimediaQuery
//
//  Created by Zichuan Wang on 15/4/11.
//  Copyright (c) 2015年 zichuanwang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MQBaseDescriptorGenerator : NSObject

@property (nonatomic, copy, readonly) NSString *sourceFolderPath;

@property (nonatomic, readonly) NSString *targetJSONFileName;

@property (nonatomic, readonly) NSURL *targetJSONFileURL;

- (id)initWithSourceFolderPath:(NSString *)path;

- (void)generateAsynchronouslyWithCompletionHandler:(void (^)(NSError *))handler;

@end
