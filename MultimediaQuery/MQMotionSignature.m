//
//  MQMotionSignature.m
//  MultimediaQuery
//
//  Created by Zichuan Wang on 15/4/11.
//  Copyright (c) 2015年 zichuanwang. All rights reserved.
//

#import "MQMotionSignature.h"

static float motionThreshold = 4;

typedef NS_ENUM(int, MQVectorDirection) {
    MQVectorDirectionNone = 0,
    MQVectorDirectionLeft = 1,
    MQVectorDirectionRight = 2,
    MQVectorDirectionUp = 3,
    MQVectorDirectionDown = 4,
};

@interface MQMotionSignature () {
    CGPoint *_vectors;
    unsigned long _size;
}

@property (nonatomic, readonly) float maxDifferentMotions;

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
        
    }
    return self;
}

- (void)dealloc {
    free(_vectors);
}

- (id)initWithJSONArray:(NSArray *)array {
    self = [super init];
    if (self) {
        _size = array.count;
        _vectors = malloc(_size * sizeof(CGPoint));
        int index = 0;
        for (NSArray *vecArray in array) {
            _vectors[index] = CGPointMake([vecArray[0] integerValue], [vecArray[1] integerValue]);
            index++;
        }
    }
    return self;
}

- (NSArray *)JSONPresentation {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:16];
    for (int i = 0; i < _size; i++) {
        array[i] = @[@(_vectors[i].x), @(_vectors[i].y)];
    }
    return array;
}

- (CGPoint *)vectors {
    return _vectors;
}

+ (MQVectorDirection)directionForVector:(CGPoint)vector {
    double vertical = MIN(fabs(vector.x), 1);
    double horizontal = MIN(fabs(vector.y), 1);
    if (horizontal / vertical >= motionThreshold) {
        return vector.x > 0 ? MQVectorDirectionRight : MQVectorDirectionLeft;
    } else if (vertical / horizontal >= motionThreshold) {
        return vector.y > 0 ? MQVectorDirectionUp : MQVectorDirectionDown;
    }
    return MQVectorDirectionNone;
}

- (void)directionsCount:(int *)buffer {
    memset(buffer, 0, sizeof(int) * 4);
    
    for (int i = 0; i < _size; i++) {
        CGPoint vec = _vectors[i];
        MQVectorDirection direction = [MQMotionSignature directionForVector:vec];
        switch (direction) {
            case MQVectorDirectionLeft:
                buffer[0]++;
                break;
                
            case MQVectorDirectionRight:
                buffer[1]++;
                break;
                
            case MQVectorDirectionUp:
                buffer[2]++;
                break;
                
            case MQVectorDirectionDown:
                buffer[3]++;
                break;
                
            default:
                break;
        }
    }
}

- (float)distanceToSignature:(MQMotionSignature *)sig {
    int my[4], others[4];
    [self directionsCount:my];
    [sig directionsCount:others];
    
    for (int i = 0; i < 4; i++) {
        // NSLog(@"%@, %@", @(my[i]), @(others[i]));
    }
    int total = 0, diff = 0;
    for (int i = 0; i < 4; i++) {
        total += my[i];
        diff += abs(my[i] - others[i]);
    }
    float ret = diff / self.maxDifferentMotions;
    return MAX(ret, 1);
}

@end
