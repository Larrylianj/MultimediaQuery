//
//  MQBrain.h
//  MultimediaQuery
//
//  Created by Zichuan Wang on 15/4/8.
//  Copyright (c) 2015年 zichuanwang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MQVideo;

@interface MQBrain : NSObject

@property (nonatomic, strong, readonly) NSMutableDictionary *videoStore;
@property (nonatomic, readonly) MQVideo *queryVideo;

+ (instancetype)sharedInstance;

- (void)setupWithRootFolderPath:(NSString *)path;

- (BOOL)setupQueryFolderURL:(NSURL *)url;

- (NSArray *)queryResults;

@end
