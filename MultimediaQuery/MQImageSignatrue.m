//
//  MQImageSignatrue.m
//  MultimediaQuery
//
//  Created by Zichuan Wang on 15/4/9.
//  Copyright (c) 2015年 zichuanwang. All rights reserved.
//

#import "MQImageSignatrue.h"

@interface MQImageSignatrue () {
    uint32_t _sig[16];
}

@end

@implementation MQImageSignatrue

- (id)initWithData:(NSData *)data {
    self = [super init];
    if (self) {
        memcpy(_sig, data.bytes, data.length);
    }
    return self;
}

- (id)initWithJSONArray:(NSArray *)array {
    self = [super init];
    if (self) {
        int index = 0;
        for (NSNumber *num in array) {
            _sig[index] = num.intValue;
            index++;
        }
    }
    return self;
}

- (NSArray *)JSONPresentation {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:16];
    for (int i = 0; i < 16; i++) {
        array[i] = @(_sig[i]);
    }
    return array;
}

- (void *)data {
    return _sig;
}

int32_t rgbDistance(int32_t a, int32_t b) {
    int32_t ret = abs(a - b);
    return ret > 50 ? 255 : ret;
}

- (float)distanceToSignature:(MQImageSignatrue *)sig {
    float diff = 0;
    uint32_t *data = [sig data];
    for (int i = 0; i < 16; i++) {
        int32_t r1 = (_sig[i] >> 16) & 0xFF;
        int32_t r2 = (data[i] >> 16) & 0xFF;
        int32_t g1 = (_sig[i] >> 8) & 0xFF;
        int32_t g2 = (data[i] >> 8) & 0xFF;
        int32_t b1 = (_sig[i]) & 0xFF;
        int32_t b2 = (data[i]) & 0xFF;
        diff += rgbDistance(r1, r2) + rgbDistance(g1, g2) + rgbDistance(b1, b2);
    }
    float nom = diff / 3 / 16 / 255;
    return nom;
}

@end
