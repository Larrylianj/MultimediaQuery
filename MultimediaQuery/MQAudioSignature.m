//
//  MQAudioSignature.m
//  MultimediaQuery
//
//  Created by Zichuan Wang on 15/4/17.
//  Copyright (c) 2015年 zichuanwang. All rights reserved.
//

#import "MQAudioSignature.h"

const UInt32 dataLength = 32;

@interface MQAudioSignature () {
    Float32 _data[dataLength];
}

@property (nonatomic, assign) Float32 totalMagnitude;

@end

@implementation MQAudioSignature

- (id)initWithData:(Float32 *)data; {
    self = [super init];
    if (self) {
        memcpy(_data, data, dataLength * sizeof(Float32));
    }
    return self;
}

- (id)initWithJSONArray:(NSArray *)array {
    self = [super init];
    if (self) {
        for (int i = 0; i < dataLength; i++) {
            float value = [array[i] floatValue];
            _data[i] = value;
            _totalMagnitude += value;
        }
    }
    return self;
}

- (NSArray *)JSONPresentation {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:dataLength];
    for (int i = 0; i < dataLength; i++) {
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
    for (int i = 0; i < dataLength; i++) {
        float max = MAX(_data[i], other[i]);
        float sim = max != 0 ? MIN(_data[i], other[i]) / max : 1;
        
        float currDiff = 0;
        if (sim > 0.7) currDiff = 0;
        else if (sim < 0.1) currDiff = 1;
        else currDiff = 1 - sim;
        
        float weight = (_data[i] + other[i]) / (_totalMagnitude + sig.totalMagnitude);
        diff += currDiff * weight;
    }
    return diff;
}

@end
