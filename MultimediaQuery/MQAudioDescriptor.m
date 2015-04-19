//
//  MQAudioDescriptor.m
//  MultimediaQuery
//
//  Created by Zichuan Wang on 15/4/17.
//  Copyright (c) 2015年 zichuanwang. All rights reserved.
//

#import "MQAudioDescriptor.h"
#import "MQAudioSignature.h"

@interface MQAudioDescriptor ()

@property (nonatomic, strong) NSMutableArray *audioSignatures;

@end

@implementation MQAudioDescriptor

- (NSMutableArray *)audioSignatures {
    if (!_audioSignatures) {
        _audioSignatures = [NSMutableArray array];
    }
    return _audioSignatures;
}

- (void)updateWithQueryVideoAudioDescriptor:(MQAudioDescriptor *)query {
    NSUInteger m = self.audioSignatures.count;
    NSUInteger n = query.audioSignatures.count;
    
    NSMutableArray *matchingScroes = [[NSMutableArray alloc] initWithCapacity:self.audioSignatures.count];
    
    for (NSUInteger i = 0; i < m; i++) {
        float dis = 0;
        for (NSUInteger j = 0; j < n; j++) {
            MQAudioSignature *a = self.audioSignatures[i + j < m ? i + j : m - 2 + (m - i - j)];
            MQAudioSignature *b = query.audioSignatures[j];
            float distance = [a distanceToSignature:b];
            dis += distance;
        }
        float curr = 1 - dis / n;
        matchingScroes[i] = @(curr);
    }
    _matchingScores = matchingScroes;
}

- (void)appendAudioSignature:(MQAudioSignature *)sig {
    [self.audioSignatures addObject:sig];
}

- (NSArray *)JSONPresentation {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.audioSignatures.count];
    for (int i = 0; i < self.audioSignatures.count; i++) {
        MQAudioSignature *sig = self.audioSignatures[i];
        array[i] = sig.JSONPresentation;
    }
    return array;
}

- (void)setupWithJSONObject:(id)json {
    NSArray *array = json;
    for (NSArray *sigArr in array) {
        MQAudioSignature *sig = [[MQAudioSignature alloc] initWithJSONArray:sigArr];
        [self appendAudioSignature:sig];
    }
//    for (MQAudioSignature *sig in self.audioSignatures) {
//        NSLog(@"%@", sig.JSONPresentation);
//    }
}

@end
