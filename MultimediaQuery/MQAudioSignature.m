//
//  MQAudioSignature.m
//  MultimediaQuery
//
//  Created by Zichuan Wang on 15/4/17.
//  Copyright (c) 2015年 zichuanwang. All rights reserved.
//

#import "MQAudioSignature.h"

@interface MQAudioSignature () {
    Float32 _data[32];
}

@end

@implementation MQAudioSignature

- (id)initWithData:(Float32 *)data; {
    self = [super init];
    if (self) {
        memcpy(_data, data, 32 * sizeof(Float32));
    }
    return self;
}

- (id)initWithJSONArray:(NSArray *)array {
    self = [super init];
    if (self) {
        for (int i = 0; i < 32; i++) {
            _data[i] = [array[i] floatValue];
        }
    }
    return self;
}

- (NSArray *)JSONPresentation {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:32];
    for (int i = 0; i < 32; i++) {
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
    for (int i = 0; i < 32; i++) {
        float sim = MIN(other[i], _data[i]) / MAX(other[i], _data[i]);
        if (sim > 0.8) sim = 1;
        if (sim < 0.3) sim = 0;
        diff += (1 - sim) / 32;
    }
    return diff;
}

@end
