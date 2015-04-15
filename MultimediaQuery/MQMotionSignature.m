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

@property (nonatomic, assign) CGPoint avgVector;
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
        [self configureAvgVector];
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
        [self configureAvgVector];
        [self configureMovementPercentage];
    }
    return self;
}

- (void)dealloc {
    free(_vectors);
}

- (NSArray *)JSONPresentation {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:16];
    for (int i = 0; i < _size; i++) {
        array[i] = @[@((int)(_vectors[i].x)), @((int)_vectors[i].y)];
    }
    return array;
}

- (void)configureAvgVector {
    return;
    CGFloat x = 0, y = 0;
    for (int i = 0; i < _size; i++) {
        CGPoint vec = _vectors[i];
        x += vec.x;
        y += vec.y;
    }
    self.avgVector = CGPointMake(x / _size, y / _size);
    // NSLog(@"x: %@, y: %@, avg: %@, %@", @(x), @(y), NSStringFromPoint(self.avgVector), @(_size));
}

- (CGPoint *)vectors {
    return _vectors;
}

- (void)configureMovementPercentage {
    float count = 0;
    for (int i = 0; i < _size; i++) {
        CGPoint p = _vectors[i];
        if (fabs(p.x) + fabs(p.y) > 32) {
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

@end
