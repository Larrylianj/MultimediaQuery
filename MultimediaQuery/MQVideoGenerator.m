//
//  MQVideoConverter.m
//  MultimediaQuery
//
//  Created by Zichuan Wang on 15/4/7.
//  Copyright (c) 2015年 zichuanwang. All rights reserved.
//

#import "MQVideoGenerator.h"
#import <AVFoundation/AVFoundation.h>
#import <AppKit/AppKit.h>

@interface MQVideoGenerator () {
    uint32_t* _argb;
}

@property (nonatomic, readwrite) NSString *sourceFolderPath;

@property (nonatomic, readonly) NSString *targetVideoFileName;

@property (nonatomic, readonly) NSString *targetCompiledFileName;

@property (nonatomic, readonly) NSURL *targetVideoFileURL;

@property (nonatomic, readonly) NSURL *targetCompiledFileURL;

@property (nonatomic, strong) __attribute__((NSObject)) CGColorSpaceRef colorSpace;

@property (nonatomic, assign) NSInteger frameRate;

@property (nonatomic, copy) NSURL *audioInputFileURL;

@property (nonatomic, strong) AVAssetWriter *videoWriter;

@property (nonatomic, strong) AVAssetExportSession *assetExport;

@property (nonatomic, assign) CGSize imageSize;

@property (nonatomic, assign) int imageArea;

@end

@implementation MQVideoGenerator

- (id)initWithSourceFolderPath:(NSString *)path imageSize:(CGSize)size frameRate:(NSInteger)rate {
    self = [super init];
    if (self) {
        self.sourceFolderPath = path;
        self.imageSize = size;
        self.frameRate = rate;
        
        _argb = (uint32_t*)malloc((int)size.width * (int)size.height * sizeof(uint32_t));

        self.colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    return self;
}

- (void)setImageSize:(CGSize)imageSize {
    if (!CGSizeEqualToSize(_imageSize, imageSize)) {
        _imageSize = imageSize;
        self.imageArea = (int)self.imageSize.width * (int)self.imageSize.height;
    }
}

- (void)dealloc {
    free(_argb);
}

- (uint32_t)pixelForFrame:(int)frame atIndex:(int)idx rgb:(unsigned char *)rgb {
    uint32_t r = rgb[idx] & 0xff;
    uint32_t g = rgb[idx + self.imageArea] & 0xff;
    uint32_t b = rgb[idx + self.imageArea * 2] & 0xff;
    uint32_t pix = 0xff | (b << 24) | (g << 16) | (r << 8);
    return pix;
}

- (CVPixelBufferRef)imageBufferRefAtFileURL:(NSURL *)url frame:(int)frame bufferPool:(CVPixelBufferPoolRef)pool {
    NSData *data = [NSData dataWithContentsOfURL:url];
    unsigned char *rgb = (unsigned char *)[data bytes];
    for (int idx = 0; idx < self.imageArea; idx++) {
        uint32_t pix = [self pixelForFrame:frame atIndex:idx rgb:rgb];
        _argb[idx] = pix;
    }

    CGContextRef imageContext = (CGContextRef)CFAutorelease(CGBitmapContextCreate(_argb,
                                                                                  self.imageSize.width,
                                                                                  self.imageSize.height,
                                                                                  8, // bitsPerComponent
                                                                                  4 * self.imageSize.width, // bytesPerRow
                                                                                  self.colorSpace,
                                                                                  (CGBitmapInfo)kCGImageAlphaNoneSkipFirst));
    
    NSParameterAssert(imageContext);
    
    CGImageRef cgImage = (CGImageRef)CFAutorelease(CGBitmapContextCreateImage(imageContext));
    
    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, pool, &pxbuffer);
    //    NSDictionary *options = @{ (NSString *)kCVPixelBufferCGImageCompatibilityKey: @YES,
    //                               (NSString *)kCVPixelBufferCGBitmapContextCompatibilityKey: @YES };
    //    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, self.imageSize.width,
    //                        self.imageSize.height, kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef)options,
    //                        &pxbuffer);
    
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    
    CGContextRef context = (CGContextRef)CFAutorelease(CGBitmapContextCreate(pxdata,
                                                                             self.imageSize.width,
                                                                             self.imageSize.height,
                                                                             8, // bitsPerComponent
                                                                             4 * self.imageSize.width, // bytesPerRow
                                                                             self.colorSpace,
                                                                             (CGBitmapInfo)kCGImageAlphaNoneSkipFirst));
    NSParameterAssert(context);
    
    CGContextDrawImage(context, CGRectMake(0, 0, self.imageSize.width, self.imageSize.height), cgImage);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}

- (NSString *)targetVideoFileName {
    return [NSString stringWithFormat:@"%@_video.mp4", self.sourceFolderPath.lastPathComponent];
}

- (NSString *)targetCompiledFileName {
    return [NSString stringWithFormat:@"%@_compile.mov", self.sourceFolderPath.lastPathComponent];
}

- (NSURL *)targetVideoFileURL {
    return [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", self.sourceFolderPath, self.targetVideoFileName]];
}

- (NSURL *)targetCompiledFileURL {
    return [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", self.sourceFolderPath, self.targetCompiledFileName]];
}

- (void)reportResult:(void (^)(NSError *))handler error:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        handler(error);
    });
}

- (void)generateAsynchronouslyWithCompletionHandler:(void (^)(NSError *))handler {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self convertImagesToVideoAsynchronouslyWithCompletionHandler:^(NSError *error) {
            if (error) {
                [self reportResult:handler error:error];
            } else {
                [self compileVideoWithAudioAsynchronouslyWithCompletionHandler:^(NSError *error) {
                    [self reportResult:handler error:error];
                }];
            }
        }];
    });
}

- (void)convertImagesToVideoAsynchronouslyWithCompletionHandler:(void (^)(NSError *))handler {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([self.targetVideoFileURL checkResourceIsReachableAndReturnError:nil]) {
        [fileManager removeItemAtURL:self.targetVideoFileURL error:nil];
    }
    
    NSArray *dirContents = [fileManager contentsOfDirectoryAtURL:[NSURL fileURLWithPath:self.sourceFolderPath isDirectory:true]
                                      includingPropertiesForKeys:nil
                                                         options:NSDirectoryEnumerationSkipsSubdirectoryDescendants | NSDirectoryEnumerationSkipsHiddenFiles
                                                           error:nil];
    
    NSLog(@"Writing Video Started -- %@", self.sourceFolderPath.lastPathComponent);
    
    NSError *error = nil;
    
    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:self.targetVideoFileURL
                                                           fileType:AVFileTypeMPEG4
                                                              error:&error];
    NSParameterAssert(videoWriter);
    
    NSDictionary *videoSettings = @{ AVVideoCodecKey: AVVideoCodecH264,
                                     AVVideoWidthKey: @(self.imageSize.width),
                                     AVVideoHeightKey: @(self.imageSize.height),
                                     AVVideoCompressionPropertiesKey: @{
                                             AVVideoAverageBitRateKey: @(1000000000000),
                                             }
                                     };
    
    
    AVAssetWriterInput* videoWriterInput = [AVAssetWriterInput
                                            assetWriterInputWithMediaType:AVMediaTypeVideo
                                            outputSettings:videoSettings];
    videoWriterInput.expectsMediaDataInRealTime = YES;
    
    NSDictionary *sourcePixelBufferAttributesDictionary = @{ (NSString *)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32ARGB),
                                                             (NSString *)kCVPixelBufferWidthKey: @(self.imageSize.width),
                                                             (NSString *)kCVPixelBufferHeightKey: @(self.imageSize.height),
                                                             (NSString *)kCVPixelBufferCGImageCompatibilityKey: @YES,
                                                             (NSString *)kCVPixelBufferCGBitmapContextCompatibilityKey: @YES };
    
    AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor
                                                     assetWriterInputPixelBufferAdaptorWithAssetWriterInput:videoWriterInput
                                                     sourcePixelBufferAttributes:sourcePixelBufferAttributesDictionary];
    
    NSParameterAssert(videoWriterInput);
    
    NSParameterAssert([videoWriter canAddInput:videoWriterInput]);
    
    [videoWriter addInput:videoWriterInput];
    //Start a session:
    [videoWriter startWriting];
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    
    //Video encoding
    
    CVImageBufferRef buffer = NULL;
    
    //convert UIImage to CVImageBufferRef.
    
    int frameCount = 0;
    
    for (NSURL *fileURL in dirContents) {
        if (![fileURL.pathExtension.lowercaseString isEqualToString:@"rgb"]) {
            if ([fileURL.pathExtension.lowercaseString isEqualToString:@"wav"]) {
                self.audioInputFileURL = fileURL;
            }
            continue;
        }
        
        CVPixelBufferPoolRef bufferPool = adaptor.pixelBufferPool;
        NSParameterAssert(bufferPool != NULL);
        
        buffer = [self imageBufferRefAtFileURL:fileURL frame:frameCount bufferPool:adaptor.pixelBufferPool];
        
        BOOL appendSucceed = NO;
        int j = 0;
        while (!appendSucceed && j < self.frameRate) {
            if (adaptor.assetWriterInput.readyForMoreMediaData) {
                // printf("appending %d attemp %d\n", frameCount, j);
                
                CMTime frameTime = CMTimeMake(frameCount, (uint32_t)self.frameRate);
                
                appendSucceed = [adaptor appendPixelBuffer:buffer withPresentationTime:frameTime];
            } else {
                // printf("adaptor not ready %d, %d\n", frameCount, j);
                [NSThread sleepForTimeInterval:0.1];
            }
            j++;
        }
        if (!appendSucceed) {
            NSLog(@"error appending image %d times %d\n", frameCount, j);
        }
        frameCount++;
    }
    
    [videoWriterInput markAsFinished];
    __weak AVAssetWriter *weakWriter = videoWriter;
    [videoWriter finishWritingWithCompletionHandler:^{
        NSLog(@"Writing Video Ended -- %@", self.sourceFolderPath.lastPathComponent);
        if (weakWriter.status == AVAssetWriterStatusFailed) {
            handler(weakWriter.error);
        } else {
            handler(nil);
        }
    }];
    
    self.videoWriter = videoWriter;
}

- (void)compileVideoWithAudioAsynchronouslyWithCompletionHandler:(void (^)(NSError *))handler {
    AVMutableComposition *mixComposition = [AVMutableComposition composition];
    
    NSURL *audioInputFileURL = self.audioInputFileURL;
    
    NSURL *videoInputFileURL = self.targetVideoFileURL;
    
    NSURL *outputFileURL = self.targetCompiledFileURL;
    
    if ([outputFileURL checkResourceIsReachableAndReturnError:nil])
        [[NSFileManager defaultManager] removeItemAtURL:outputFileURL error:nil];
    
    NSLog(@"Compiling Started -- %@", self.sourceFolderPath.lastPathComponent);
    
    CMTime nextClipStartTime = kCMTimeZero;
    
    AVURLAsset *videoAsset = [[AVURLAsset alloc] initWithURL:videoInputFileURL options:nil];
    CMTimeRange videoTimeRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration);
    AVMutableCompositionTrack *aCompositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [aCompositionVideoTrack insertTimeRange:videoTimeRange ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:nextClipStartTime error:nil];
    
    //nextClipStartTime = CMTimeAdd(nextClipStartTime, a_timeRange.duration);
    
    if (audioInputFileURL) {
        AVURLAsset *audioAsset = [[AVURLAsset alloc] initWithURL:audioInputFileURL options:nil];
        CMTimeRange audioTimeRange = CMTimeRangeMake(kCMTimeZero, audioAsset.duration);
        AVMutableCompositionTrack *bCompositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        [bCompositionAudioTrack insertTimeRange:audioTimeRange ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:nextClipStartTime error:nil];
    } else {
        NSLog(@"Didn't find audio in source folder -- %@", self.sourceFolderPath.lastPathComponent);
    }
    
    AVAssetExportSession *assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetPassthrough];
    assetExport.outputFileType = @"com.apple.quicktime-movie";
    assetExport.outputURL = outputFileURL;
    
    __weak AVAssetExportSession *weakSession = assetExport;
    [assetExport exportAsynchronouslyWithCompletionHandler:^(void) {
        NSLog(@"Compiling Ended -- %@", self.sourceFolderPath.lastPathComponent);
        if (weakSession.status == AVAssetExportSessionStatusFailed) {
            handler(weakSession.error);
        } else {
            handler(nil);
        }
    }];
    
    self.assetExport = assetExport;
}

@end
