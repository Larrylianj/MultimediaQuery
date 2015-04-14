//
//  MQImageSignatrue.h
//  MultimediaQuery
//
//  Created by Zichuan Wang on 15/4/9.
//  Copyright (c) 2015年 zichuanwang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MQImageSignatrue : NSObject

@property (nonatomic, readonly) NSArray *JSONPresentation;

- (id)initWithData:(NSData *)data;

- (id)initWithJSONArray:(NSArray *)array;

- (float)distanceToSignature:(MQImageSignatrue *)sig;

@end
