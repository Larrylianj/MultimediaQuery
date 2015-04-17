//
//  MQMotionDescriptorGenerator.m
//  MultimediaQuery
//
//  Created by Zichuan Wang on 15/4/11.
//  Copyright (c) 2015年 zichuanwang. All rights reserved.
//

#import "MQMotionDescriptorGenerator.h"
#import "MQMotionDescriptor.h"
#import "MQMotionSignature.h"

@interface MQMotionDescriptorGenerator () {
    CGPoint *_vectors;
    int _vectorRows;
    int _vectorColumns;
    unsigned char **_prevHierarchyRGB;
    unsigned char **_currHierarchyRGB;
}

@property (nonatomic, assign) CGSize blockSize;
@property (nonatomic, assign) int vectorSize;
@property (nonatomic, strong) NSData *prevImageFileRawData;
@property (nonatomic, strong) NSData *currImageFileRawData;

@end

@implementation MQMotionDescriptorGenerator

#pragma mark - Methods to Overwrite

- (NSString *)targetJSONFileName {
    return [NSString stringWithFormat:@"%@_motion_descriptor.json", self.sourceFolderPath.lastPathComponent];
}

- (void)dealloc {
    free(_vectors);
    for (int i = 1; i < 4; i++) {
        free(_prevHierarchyRGB[i]);
        free(_currHierarchyRGB[i]);
    }
    free(_prevHierarchyRGB);
    free(_currHierarchyRGB);
}

- (void)generateAsynchronouslyWithCompletionHandler:(void (^)(NSError *))handler {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self convertImagesToImageDescriptor];
        dispatch_async(dispatch_get_main_queue(), ^{
            handler(nil);
        });
    });
}

- (id)initWithSourceFolderPath:(NSString *)path imageSize:(CGSize)size {
    self = [super initWithSourceFolderPath:path imageSize:size];
    if (self) {
        self.blockSize = CGSizeMake(16, 16);
        _vectorColumns = (int)(size.width / self.blockSize.width);
        _vectorRows = (int)(size.height / self.blockSize.height);
        self.vectorSize = _vectorRows * _vectorColumns;
        _vectors = (CGPoint *)malloc(self.vectorSize * sizeof(CGPoint));
        
        _currHierarchyRGB = malloc(4 * sizeof(unsigned char *));
        _prevHierarchyRGB = malloc(4 * sizeof(unsigned char *));
        int width = (int)self.imageSize.width;
        int height = (int)self.imageSize.height;
        for (int i = 1; i < 4; i++) {
            width /= 2;
            height /= 2;
            size_t size = width * height * 3 * sizeof(unsigned char);
            _prevHierarchyRGB[i] = malloc(size);
            _currHierarchyRGB[i] = malloc(size);
        }
    }
    return self;
}

- (void)setCurrImageFileRawData:(NSData *)currImageFileRawData {
    if (_currImageFileRawData != currImageFileRawData) {
        _currImageFileRawData = currImageFileRawData;
        
        // Assign first level of current hierarchy RGB by assigning pointer of current image file raw data's bytes
        _currHierarchyRGB[0] = (unsigned char *)[currImageFileRawData bytes];
        
        int width = (int)self.imageSize.width;
        int height = (int)self.imageSize.height;
        
        // Calculate each level RGB by downsizing previous level's RGB by 2
        for (int i = 1; i < 4; i++) {
            width /= 2;
            height /= 2;
            int area = width * height;
            for (int y = 0; y < height; y++) {
                for (int x = 0; x < width; x++) {
                    for (int k = 0; k < 3; k++) {
                        int val = 0;
                        for (int m = 0; m < 2; m++) {
                            for (int n = 0; n < 2; n++) {
                                int idx = (y * 2 + m) * width * 2 + x * 2 + n;
                                val += _currHierarchyRGB[i - 1][idx + area * 4 * k] & 0xff;
                            }
                        }
                        _currHierarchyRGB[i][y * width + x + area * k] = ((val / 4) & 0xff);
                    }
                }
            }
        }
    }
}

- (void)setPrevImageFileRawData:(NSData *)prevImageFileRawData {
    if (_prevImageFileRawData != prevImageFileRawData) {
        _prevImageFileRawData = prevImageFileRawData;
        // Copy current hierarchy RGB by switching pointers
        unsigned char **temp = _prevHierarchyRGB;
        _prevHierarchyRGB = _currHierarchyRGB;
        _currHierarchyRGB = temp;
    }
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
    
    NSLog(@"Generating Motion Descriptor Started -- %@", self.sourceFolderPath.lastPathComponent);
    
    MQMotionDescriptor *descriptor = [[MQMotionDescriptor alloc] init];
    
    for (NSURL *fileURL in dirContents) {
        if (![fileURL.pathExtension.lowercaseString isEqualToString:@"rgb"]) {
            continue;
        }
        NSLog(@"file name: %@", fileURL.absoluteString);
        NSData *data = [NSData dataWithContentsOfURL:fileURL];
        
        // Configure curr data
        self.currImageFileRawData = data;
        
        if (self.prevImageFileRawData) {
            MQMotionSignature *sig = [self motionSignatureForCurrentFrame];
            [descriptor appendMotionSignature:sig];
        }
        
        // Configure prev data
        self.prevImageFileRawData = data;
        
    }
    [descriptor writeOutToFileWithURL:self.targetJSONFileURL];
    
    NSLog(@"Generating Motion Descriptor Ended -- %@", self.sourceFolderPath.lastPathComponent);
}

- (void)configureRGBBufferAtX:(int)x
                            y:(int)y
                        level:(int)lvl
                     withData:(unsigned char **)rgb
                       buffer:(int32_t *)buff {
    
    int pw = pow(2, lvl);
    int width = (int)self.imageSize.width / pw;
    int height = (int)self.imageSize.height / pw;
    int area = width * height;
    
    for (int k = 0; k < 3; k++) {
        buff[k] = rgb[lvl][y * width + x + area * k] & 0xff;
    }
}

- (int32_t)differenceBetweenPrevFrameAtX:(int)px prevY:(int)py withCurrentFrameAtX:(int)cx currY:(int)cy level:(int)lvl {
    int32_t prgb[3], crgb[3];
    int diff = 0;
    [self configureRGBBufferAtX:px y:py level:lvl withData:_prevHierarchyRGB buffer:prgb];
    [self configureRGBBufferAtX:cx y:cy level:lvl withData:_currHierarchyRGB buffer:crgb];
    for (int i = 0; i < 3; i++) {
        diff += abs(prgb[i] - crgb[i]);
    }
    // NSLog(@"px: %@, py: %@, cx: %@, cy: %@, lvl: %@, diff: %@", @(px), @(py), @(cx), @(cy), @(lvl), @(diff));
    return diff / 3;
}

- (CGPoint)hierarchicalSearchMotionVectorForBlockAtRow:(int)row
                                                column:(int)column
                                       candidateLength:(int)k
                                                 level:(int)lvl {
    
    int pw = pow(2, lvl);
    int width = (int)self.imageSize.width / pw;
    int height = (int)self.imageSize.height / pw;
    int blockWidth = (int)self.blockSize.width / pw;
    int blockHeight = (int)self.blockSize.height / pw;
    
    int currX = column * blockWidth;
    int currY = row * blockHeight;
    
    if (lvl == 0) {
        int32_t originalDiff = 0;
        for (int m = 0; m < blockHeight; m++) {
            for (int n = 0; n < blockWidth; n++) {
                int32_t diff = [self differenceBetweenPrevFrameAtX:currX + n prevY:currY + m withCurrentFrameAtX:currX + n currY:currY + m level:lvl];
                originalDiff += diff;
            }
        }
        if (originalDiff / blockHeight / blockWidth < 2) {
            // NSLog(@"(%@, %@), %@", @(row), @(column), @(originalDiff));
            return CGPointMake(currX, currY);
        }
    }
    
    CGPoint ret = CGPointZero;
    int32_t minDiff = INT32_MAX;
    
    if (lvl == 3) {
        for (int i = MAX(currY - k, 0); i <= MIN(currY + k, height - blockHeight - 1); i++) {
            for (int j = MAX(currX - k, 0); j <= MIN(currX + k, width - blockWidth - 1); j++) {
                int32_t currDiff = 0;
                for (int m = 0; m < blockHeight; m++) {
                    for (int n = 0; n < blockWidth; n++) {
                        currDiff += [self differenceBetweenPrevFrameAtX:j + n prevY:i + m withCurrentFrameAtX:currX + n currY:currY + m level:lvl];
                    }
                }
                if (currDiff < minDiff) {
                    minDiff = currDiff;
                    ret = CGPointMake(j, i);
                }
            }
        }
    } else {
        CGPoint target = [self hierarchicalSearchMotionVectorForBlockAtRow:row column:column candidateLength:k / 2 level:lvl + 1];
        
        int targetX = target.x * 2;
        int targetY = target.y * 2;
        
        for (int i = 0; i < 2; i++) {
            for (int j = 0; j < 2; j++) {
                int32_t currDiff = 0;
                for (int m = 0; m < blockHeight; m++) {
                    for (int n = 0; n < blockWidth; n++) {
                        currDiff += [self differenceBetweenPrevFrameAtX:targetX + j + n prevY:targetY + i + m withCurrentFrameAtX:currX + n currY:currY + m level:lvl];
                    }
                }
                if (currDiff < minDiff) {
                    minDiff = currDiff;
                    ret = CGPointMake(targetX + j, targetY + i);
                }
            }
        }
    }
    // NSLog(@"row: %@, column: %@, level: %@, vector: %@", @(row), @(column), @(lvl), NSStringFromPoint(ret));
    return ret;
}

- (CGPoint)motionVectorForBlockAtRow:(int)row
                              column:(int)column
                     candidateLength:(int)k {
    int blockWidth = (int)self.blockSize.width;
    int blockHeight = (int)self.blockSize.height;
    int x = column * blockWidth;
    int y = row * blockHeight;
    
    CGPoint ret = [self hierarchicalSearchMotionVectorForBlockAtRow:row column:column candidateLength:k level:0];
    ret = CGPointMake(x - ret.x, y - ret.y);
//    if (abs(ret.x) + abs(ret.y) > 16) {
//        NSLog(@"row: %@, column: %@, ret: %@", @(row), @(column), NSStringFromPoint(ret));
//    }
    return ret;
}

- (MQMotionSignature *)motionSignatureForCurrentFrame {
    for (int i = 0; i < _vectorRows; i++) {
        for (int j = 0; j < _vectorColumns; j++) {
            // NSLog(@"i: %@, j: %@", @(i), @(j));
            CGPoint vec = [self motionVectorForBlockAtRow:i column:j candidateLength:32];
            _vectors[i * _vectorColumns + j] = vec;
        }
    }
    
    NSData *sigData = [[NSData alloc] initWithBytes:_vectors length:self.vectorSize * sizeof(CGPoint)];
    MQMotionSignature *sig = [[MQMotionSignature alloc] initWithData:sigData];
    // NSLog(@"sig: %@", sig);
    
    return sig;
}

@end
