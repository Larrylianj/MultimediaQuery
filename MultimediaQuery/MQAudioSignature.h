//
//  MQAudioSignature.h
//  MultimediaQuery
//
//  Created by Zichuan Wang on 15/4/17.
//  Copyright (c) 2015年 zichuanwang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MQAudioSignature : NSObject

@property (nonatomic, readonly) NSArray *JSONPresentation;

- (id)initWithData:(Float32 *)data;

- (id)initWithJSONArray:(NSArray *)array;

- (float)distanceToSignature:(MQAudioSignature *)sig;

@end
