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

- (id)initWithSourceFolderPath:(NSString *)path imageSize:(CGSize)size frameRate:(NSInteger)rate;

- (void)generateAsynchronouslyWithCompletionHandler:(void (^)(NSError *))handler;

@end
