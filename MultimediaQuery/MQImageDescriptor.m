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
    NSLog(@"");
}

- (void)appendImageSignature:(MQImageSignatrue *)sig; {
    [self.imageSignatures addObject:sig];
}

- (void)updateWithQueryVideoImageDescriptor:(MQImageDescriptor *)query {
    NSUInteger m = self.imageSignatures.count;
    NSUInteger n = query.imageSignatures.count;
    
    NSMutableArray *matchingScroes = [[NSMutableArray alloc] initWithCapacity:self.imageSignatures.count];
    
    for (NSUInteger i = 0; i < m; i++) {
        float dis = 0;
        for (NSUInteger j = 0; j < n; j++) {
            MQImageSignatrue *a = self.imageSignatures[i + j < m ? i + j : m - 2 + (m - i - j)];
            MQImageSignatrue *b = query.imageSignatures[j];
            float distance = [a distanceToSignature:b];
            dis += distance;
        }
        float curr = 1 - dis / n;
        matchingScroes[i] = @(curr);
    }
    
    _matchingScores = matchingScroes;

}

@end
