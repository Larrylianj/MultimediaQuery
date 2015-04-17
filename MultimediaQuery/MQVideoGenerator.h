//
//  MQVideoConverter.h
//  MultimediaQuery
//
//  Created by Zichuan Wang on 15/4/7.
//  Copyright (c) 2015年 zichuanwang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MQVideoGenerator: NSObject {
    
}

@property (nonatomic, readonly) CGSize imageSize;

@property (nonatomic, readonly) int imageArea;

@property (nonatomic, copy, readonly) NSString *sourceFolderPath;

- (id)initWithSourceFolderPath:(NSString *)path imageSize:(CGSize)size frameRate:(NSInteger)rate;

- (void)generateAsynchronouslyWithCompletionHandler:(void (^)(NSError *))handler;

- (uint32_t)pixelForFrame:(int)frame atIndex:(int)idx rgb:(unsigned char *)rgb;

@end
