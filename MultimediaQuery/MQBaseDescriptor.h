//
//  MQVideoDescriptor.h
//  MultimediaQuery
//
//  Created by Zichuan Wang on 15/4/9.
//  Copyright (c) 2015年 zichuanwang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MQBaseDescriptor : NSObject {
    NSArray *_matchingScores;
}

@property (nonatomic, readonly) NSArray *JSONPresentation;

@property (nonatomic, strong, readonly) NSArray *matchingScores;

- (void)writeOutToFileWithURL:(NSURL *)url;

- (id)initWithJSONFilePath:(NSString *)path;

@end
