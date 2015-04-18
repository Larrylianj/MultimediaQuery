//
//  MQMotionDescriptor.m
//  MultimediaQuery
//
//  Created by Zichuan Wang on 15/4/11.
//  Copyright (c) 2015年 zichuanwang. All rights reserved.
//

#import "MQMotionDescriptor.h"
#import "MQMotionSignature.h"

@interface MQMotionDescriptor ()

@property (nonatomic, strong) NSMutableArray *motionSignatures;

@end

@implementation MQMotionDescriptor

- (NSMutableArray *)motionSignatures {
    if (!_motionSignatures) {
        _motionSignatures = [NSMutableArray array];
    }
    return _motionSignatures;
}

- (void)appendMotionSignature:(MQMotionSignature *)sig {
    [self.motionSignatures addObject:sig];
}

- (NSArray *)JSONPresentation {
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:self.motionSignatures.count];
    for (int i = 0; i < self.motionSignatures.count; i++) {
        MQMotionDescriptor *sig = self.motionSignatures[i];
        array[i] = sig.JSONPresentation;
    }
    return array;
}

- (void)setupWithJSONObject:(id)json {
    NSArray *array = json;
    for (NSArray *sigArr in array) {
        MQMotionSignature *sig = [[MQMotionSignature alloc] initWithJSONArray:sigArr];
        [self appendMotionSignature:sig];
    }
}

- (void)updateWithQueryVideoMotionDescriptor:(MQMotionDescriptor *)query {
    NSUInteger m = self.motionSignatures.count;
    NSUInteger n = query.motionSignatures.count;
    
    NSMutableArray *matchingScroes = [[NSMutableArray alloc] initWithCapacity:self.motionSignatures.count];
    

    for (NSUInteger i = 0; i < m; i++) {
        float dis = 0;
        for (NSUInteger j = 0; j < n; j++) {
            MQMotionSignature *a = self.motionSignatures[i + j < m ? i + j : m - 2 + (m - i - j)];
            MQMotionSignature *b = query.motionSignatures[j];
            float distance = [a distanceToSignature:b];
            dis += distance;
        }
        float curr = 1 - dis / n;
        matchingScroes[i] = @(curr);
    }
    
    [matchingScroes addObject:@(0)];
    _matchingScores = matchingScroes;
}

- (BOOL)detectedMovementAtFrame:(int)frame pixelIndex:(int)idx {
    if (frame <= 0) return NO;
    // This is just for the images provided
    MQMotionSignature *sig = self.motionSignatures[frame - 1];
    return [sig detectedMovementForPixelIndex:idx];
}

@end
