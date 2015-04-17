//
//  MQMotionSignature.m
//  MultimediaQuery
//
//  Created by Zichuan Wang on 15/4/11.
//  Copyright (c) 2015年 zichuanwang. All rights reserved.
//

#import "MQMotionSignature.h"

@interface MQMotionSignature () {
    CGPoint *_vectors;
    unsigned long _size;
}

@property (nonatomic, assign) float movementPercentage;

@end

@implementation MQMotionSignature

- (float)maxDifferentMotions {
    return _size;
}

- (id)initWithData:(NSData *)data {
    self = [super init];
    if (self) {
        _vectors = malloc(data.length);
        _size = data.length / sizeof(CGPoint);
        memcpy(_vectors, data.bytes, data.length);
        [self configureMovementPercentage];
    }
    return self;
}

- (id)initWithJSONArray:(NSArray *)array {
    self = [super init];
    if (self) {
        _size = array.count;
        _vectors = malloc(_size * sizeof(CGPoint));

        for (int i = 0; i < _size; i++) {
            NSArray *vecArray = array[i];
            _vectors[i] = CGPointMake([vecArray[0] integerValue], [vecArray[1] integerValue]);
        }
        [self configureMovementPercentage];
    }
    return self;
}

- (void)dealloc {
    free(_vectors);
}

- (NSString *)description {
    NSMutableString *result = [NSMutableString string];
    for (int i = 0; i < _size; i++) {
        CGPoint vector = _vectors[i];
        if ([MQMotionSignature detectVectorMovement:vector]) {
            [result appendFormat:@"(%@, %@) ", @(i), NSStringFromPoint(vector)];
        }
    }
    return result;
}

- (NSArray *)JSONPresentation {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:16];
    for (int i = 0; i < _size; i++) {
        array[i] = @[@((int)(_vectors[i].x)), @((int)_vectors[i].y)];
    }
    return array;
}

- (CGPoint *)vectors {
    return _vectors;
}

- (void)configureMovementPercentage {
    float count = 0;
    for (int i = 0; i < _size; i++) {
        CGPoint p = _vectors[i];
        if ([MQMotionSignature detectVectorMovement:p]) {
            count++;
        }
    }
    self.movementPercentage = count / _size;
}

- (float)distanceToSignature:(MQMotionSignature *)sig {
    float larger = MAX(self.movementPercentage, sig.movementPercentage);
    if (larger == 0) return 0;
    float diff = 1 - MIN(self.movementPercentage, sig.movementPercentage) / larger;
    return diff;
}

- (BOOL)detectedMovementForPixelIndex:(int)idx {
    int x = idx % 352;
    int y = idx / 352;
    int blockIdx = (y / 16) * 22 + (x / 16);
    CGPoint vector = _vectors[blockIdx];
    return [MQMotionSignature detectVectorMovement:vector];
}

+ (BOOL)detectVectorMovement:(CGPoint)vector {
    return fabs(vector.x) + fabs(vector.y) >= 8;
}

@end
