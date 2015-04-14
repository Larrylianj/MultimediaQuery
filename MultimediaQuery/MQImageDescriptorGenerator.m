//
//  MQImageDescriptorGenerator.m
//  MultimediaQuery
//
//  Created by Zichuan Wang on 15/4/9.
//  Copyright (c) 2015年 zichuanwang. All rights reserved.
//

#import "MQImageDescriptorGenerator.h"
#import "MQImageDescriptor.h"
#import "MQImageSignatrue.h"

@interface MQImageDescriptorGenerator () {
    uint32_t _sig[4][4];
}

@end

@implementation MQImageDescriptorGenerator

#pragma mark - Methods to Overwrite

- (NSString *)targetJSONFileName {
    return [NSString stringWithFormat:@"%@_image_descriptor.json", self.sourceFolderPath.lastPathComponent];
}

- (void)generateAsynchronouslyWithCompletionHandler:(void (^)(NSError *))handler {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self convertImagesToImageDescriptor];
        dispatch_async(dispatch_get_main_queue(), ^{
            handler(nil);
        });
    });
}

#pragma mark - Logic

- (void)convertImagesToImageDescriptor {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([self.targetJSONFileURL checkResourceIsReachableAndReturnError:nil]) {
        [fileManager removeItemAtURL:self.targetJSONFileURL error:nil];
    }
    
    NSArray *dirContents = [fileManager contentsOfDirectoryAtURL:[NSURL fileURLWithPath:self.sourceFolderPath isDirectory:YES]
                                      includingPropertiesForKeys:nil
                                                         options:NSDirectoryEnumerationSkipsSubdirectoryDescendants | NSDirectoryEnumerationSkipsHiddenFiles
                                                           error:nil];
    
    NSLog(@"Generating Image Descriptor Started -- %@", self.sourceFolderPath.lastPathComponent);
    
    MQImageDescriptor *descriptor = [[MQImageDescriptor alloc] init];
    
    for (NSURL *fileURL in dirContents) {
        if (![fileURL.pathExtension.lowercaseString isEqualToString:@"rgb"]) {
            continue;
        }
        MQImageSignatrue *sig = [self imageSignatureAtFileURL:fileURL];
        [descriptor appendImageSignature:sig];
    }
    [descriptor writeOutToFileWithURL:self.targetJSONFileURL];
    
    NSLog(@"Generating Image Descriptor Ended -- %@", self.sourceFolderPath.lastPathComponent);
}

- (MQImageSignatrue *)imageSignatureAtFileURL:(NSURL *)url {
    NSData *data = [NSData dataWithContentsOfURL:url];
    unsigned char *rgb = (unsigned char *)[data bytes];
    int width = (int)self.imageSize.width;
    int height = (int)self.imageSize.height;
    int area = width * height;
    int sampleWidth = (int)floor(self.imageSize.width / 4);
    int sampleHeight = (int)floor(self.imageSize.height / 4);
    int sampleArea = sampleWidth * sampleHeight;
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
            uint32_t r = 0;
            uint32_t g = 0;
            uint32_t b = 0;
            for (int m = 0; m < sampleHeight; m++) {
                for (int n = 0; n < sampleWidth; n++) {
                    int idx = i * sampleHeight * width + m * width + j * sampleWidth + n;
                    r += rgb[idx] & 0xff;
                    g += rgb[idx + area] & 0xff;
                    b += rgb[idx + area * 2] & 0xff;
                }
            }
            r = r / sampleArea & 0xff;
            g = g / sampleArea & 0xff;
            b = b / sampleArea & 0xff;
            uint32_t pix = 0 | (r << 16) | (g << 8) | b;
            _sig[i][j] = pix;
        }
    }
    
    NSData *sigData = [[NSData alloc] initWithBytes:_sig length:4 * 4 * sizeof(uint32_t)];
    MQImageSignatrue *sig = [[MQImageSignatrue alloc] initWithData:sigData];
    
    return sig;
}

@end
