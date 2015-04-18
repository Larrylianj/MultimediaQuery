//
//  MQAudioSignature.m
//  MultimediaQuery
//
//  Created by Zichuan Wang on 15/4/17.
//  Copyright (c) 2015年 zichuanwang. All rights reserved.
//

#import "MQAudioSignature.h"

@interface MQAudioSignature () {
    Float32 _data[16];
}

@end

@implementation MQAudioSignature

- (id)initWithData:(Float32[16])data; {
    self = [super init];
    if (self) {
        memcpy(_data, data, 16 * sizeof(Float32));
    }
    return self;
}

- (id)initWithJSONArray:(NSArray *)array {
    self = [super init];
    if (self) {
        for (int i = 0; i < 16; i++) {
            _data[i] = [array[i] floatValue];
        }
    }
    return self;
}

- (NSArray *)JSONPresentation {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:16];
    for (int i = 0; i < 16; i++) {
        array[i] = @(_data[i]);
    }
    return array;
}

- (Float32 *)data {
    return _data;
}

- (float)distanceToSignature:(MQAudioSignature *)sig {
    float diff = 0;
    Float32 *other = [sig data];
    for (int i = 0; i < 16; i++) {
        diff += fabsf(_data[i] - other[i]) / 16;
    }
    return diff;
}

@end
