//
//  MQVideoDescriptor.m
//  MultimediaQuery
//
//  Created by Zichuan Wang on 15/4/9.
//  Copyright (c) 2015年 zichuanwang. All rights reserved.
//

#import "MQBaseDescriptor.h"

@interface MQBaseDescriptor ()

@property (nonatomic, strong, readwrite) NSArray *matchingScores;

@end

@implementation MQBaseDescriptor

@synthesize matchingScores = _matchingScores;

- (void)writeOutToFileWithURL:(NSURL *)url {
    NSOutputStream *os = [[NSOutputStream alloc] initWithURL:url append:NO];
    [os open];
    [NSJSONSerialization writeJSONObject:self.JSONPresentation toStream:os options:0 error:nil];
    [os close];
}

- (id)initWithJSONFilePath:(NSString *)path {
    self = [super init];
    if (self) {
        NSData *data = [NSData dataWithContentsOfFile:path];
        NSError *error;
        id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        [self setupWithJSONObject:jsonObject];
    }
    return self;
}

- (void)setupWithJSONObject:(id)json {
    
}

@end
