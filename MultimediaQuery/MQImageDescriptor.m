//
//  MQImageDescriptor.m
//  MultimediaQuery
//
//  Created by Zichuan Wang on 15/4/9.
//  Copyright (c) 2015年 zichuanwang. All rights reserved.
//

#import "MQImageDescriptor.h"
#import "MQImageSignatrue.h"

@interface MQImageDescriptor () {
    
}

@property (nonatomic, strong) NSMutableArray *imageSignatures;

@end

@implementation MQImageDescriptor

- (NSMutableArray *)imageSignatures {
    if (!_imageSignatures) {
        _imageSignatures = [NSMutableArray array];
    }
    return _imageSignatures;
}

- (NSArray *)JSONPresentation {
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:self.imageSignatures.count];
    for (int i = 0; i < self.imageSignatures.count; i++) {
        MQImageSignatrue *sig = self.imageSignatures[i];
        array[i] = sig.JSONPresentation;
    }
    return array;
}

- (void)setupWithJSONObject:(id)json {
    NSArray *array = json;
    for (NSArray *sigArr in array) {
        MQImageSignatrue *sig = [[MQImageSignatrue alloc] initWithJSONArray:sigArr];
        [self appendImageSignature:sig];
    }
}

- (void)appendImageSignature:(MQImageSignatrue *)sig; {
    [self.imageSignatures addObject:sig];
}

- (float)updateWithQueryVideoImageDescriptor:(MQImageDescriptor *)query {
    NSUInteger m = self.imageSignatures.count;
    NSUInteger n = query.imageSignatures.count;
    float ret = 0;
    
    NSMutableArray *matchingScroes = [[NSMutableArray alloc] initWithCapacity:self.imageSignatures.count];
    
    for (NSUInteger i = 0; i < m; i++) {
        float curr = 0;
        for (NSUInteger j = 0; j < n && i + j < m; j++) {
            MQImageSignatrue *a = self.imageSignatures[i + j];
            MQImageSignatrue *b = query.imageSignatures[j];
            float distance = [a distanceToSignature:b];
            curr += distance;
        }
        float count = MIN(n, m - i);
        curr = (count - curr) / count;
        matchingScroes[i] = @(curr);
        
        if (ret < curr) {
            ret = curr;
        }
    }
    
    _matchingScores = matchingScroes;
    return ret;
}

@end
