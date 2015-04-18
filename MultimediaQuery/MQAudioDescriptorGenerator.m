//
//  MQAudioDescriptorGenerator.m
//  MultimediaQuery
//
//  Created by Zichuan Wang on 15/4/17.
//  Copyright (c) 2015年 zichuanwang. All rights reserved.
//

#import "MQAudioDescriptorGenerator.h"
// #import <AudioToolbox/AudioToolbox.h>
#import "MQAudioDescriptor.h"
#import "MQAudioSignature.h"
#import <Accelerate/Accelerate.h>

const UInt32 numberOfChannels = 2;
const UInt32 sampleRate = 44100;
const UInt32 frameRate = 30;
const UInt32 maxSampleCount = 1024;
const UInt32 outputCount = maxSampleCount / 2;
const UInt32 quantizeBucketSize = outputCount / 32;

const Float32 kAdjust0DB = 1.5849e-13;

@interface MQAudioDescriptorGenerator () {
    Float32             inAudioData[maxSampleCount];
    Float32             outFFTData[outputCount];
    
    FFTSetup            mSpectrumAnalysis;
    DSPSplitComplex     mDspSplitComplex;
    Float32             mFFTNormFactor;
    UInt32              mFFTLength;
    vDSP_Length         mLog2N;
    Float32             quantizedResult[32];
}

@end

@implementation MQAudioDescriptorGenerator

#pragma mark - Methods to overwrite

- (id)initWithSourceFolderPath:(NSString *)path {
    self = [super initWithSourceFolderPath:path];
    if (self) {
        mFFTNormFactor = 1.0 / (2 * maxSampleCount);
        mFFTLength = outputCount;
        mLog2N = ceil(log2f(maxSampleCount));
        mDspSplitComplex.realp = (Float32 *)calloc(mFFTLength, sizeof(Float32));
        mDspSplitComplex.imagp = (Float32 *)calloc(mFFTLength, sizeof(Float32));
        mSpectrumAnalysis = vDSP_create_fftsetup(mLog2N, kFFTRadix2);
    }
    return self;
}

- (void)dealloc {
    vDSP_destroy_fftsetup(mSpectrumAnalysis);
    free(mDspSplitComplex.realp);
    free(mDspSplitComplex.imagp);
}

- (NSString *)targetJSONFileName {
    return [NSString stringWithFormat:@"%@_audio_descriptor.json", self.sourceFolderPath.lastPathComponent];
}

- (void)generateAsynchronouslyWithCompletionHandler:(void (^)(NSError *))handler {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self convertAudioToAudioDescriptor];
        dispatch_async(dispatch_get_main_queue(), ^{
            handler(nil);
        });
    });
}

#pragma mark - Logic

- (void)convertAudioToAudioDescriptor {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([self.targetJSONFileURL checkResourceIsReachableAndReturnError:nil]) {
        [fileManager removeItemAtURL:self.targetJSONFileURL error:nil];
    }
    
    NSArray *dirContents = [fileManager contentsOfDirectoryAtURL:[NSURL fileURLWithPath:self.sourceFolderPath isDirectory:YES]
                                      includingPropertiesForKeys:nil
                                                         options:NSDirectoryEnumerationSkipsSubdirectoryDescendants | NSDirectoryEnumerationSkipsHiddenFiles
                                                           error:nil];
    
    NSLog(@"Generating Audio Descriptor Started -- %@", self.sourceFolderPath.lastPathComponent);
    
    MQAudioDescriptor *descriptor = nil;
    for (NSURL *fileURL in dirContents) {
        if ([fileURL.pathExtension.lowercaseString isEqualToString:@"wav"]) {
            descriptor = [self audioDescriptorForAudioAtFileURL:fileURL];
            break;
        }
    }
    [descriptor writeOutToFileWithURL:self.targetJSONFileURL];
    
    NSLog(@"Generating Audio Descriptor Ended -- %@", self.sourceFolderPath.lastPathComponent);
}

- (void)computeFFT {
    //Generate a split complex vector from the real data
    vDSP_ctoz((COMPLEX *)inAudioData, 2, &mDspSplitComplex, 1, mFFTLength);
    
    //Take the fft and scale appropriately
    vDSP_fft_zrip(mSpectrumAnalysis, &mDspSplitComplex, 1, mLog2N, kFFTDirection_Forward);
    vDSP_vsmul(mDspSplitComplex.realp, 1, &mFFTNormFactor, mDspSplitComplex.realp, 1, mFFTLength);
    vDSP_vsmul(mDspSplitComplex.imagp, 1, &mFFTNormFactor, mDspSplitComplex.imagp, 1, mFFTLength);
    
    //Zero out the nyquist value
    mDspSplitComplex.imagp[0] = 0.0;
    
    //Convert the fft data to dB
    vDSP_zvmags(&mDspSplitComplex, 1, outFFTData, 1, mFFTLength);
    
    //In order to avoid taking log10 of zero, an adjusting factor is added in to make the minimum value equal -128dB
    vDSP_vsadd(outFFTData, 1, &kAdjust0DB, outFFTData, 1, mFFTLength);
    Float32 one = 1;
    vDSP_vdbcon(outFFTData, 1, &one, outFFTData, 1, mFFTLength, 0);
}

- (MQAudioSignature *)audioSignatureForWavechunk:(short *)chunk numberOfSamples:(NSUInteger)numberOfSamples {
    
    // Setup the length
    memset(quantizedResult, 0, 32 * sizeof(Float32));
    for (int chnl = 0; chnl < numberOfChannels; chnl++) {
        for (int i = 0; i < MIN(numberOfSamples, maxSampleCount); i++) {
            inAudioData[i] = (Float32)chunk[i * 2 + chnl] / 32768;
        }
        [self computeFFT];
        for (int i = 0; i < outputCount; i++) {
            int idx = i / quantizeBucketSize;
            quantizedResult[idx] += (outFFTData[i] + 128) / 256 / quantizeBucketSize / numberOfChannels;

            // NSLog(@"idx: %@, i: %@, v: %@", @(idx), @(i), @(outFFTData[i]));
        }
    }
    MQAudioSignature *sig = [[MQAudioSignature alloc] initWithData:quantizedResult];
    NSLog(@"%@", sig.JSONPresentation);
    return sig;
}

- (MQAudioDescriptor *)audioDescriptorForAudioAtFileURL:(NSURL *)url {
    
    MQAudioDescriptor *descriptor = [[MQAudioDescriptor alloc] init];
    
    NSData *data = [NSData dataWithContentsOfURL:url];
    // WAV header is 44 bytes long
    short *waveChunks = (short *)data.bytes + 22;
    UInt32 chunkLength = (UInt32)(data.length - 44) / 2;
    UInt32 sliceLength = numberOfChannels * sampleRate / frameRate;
    // NSLog(@"slice length: %@, chunk length: %@", @(sliceLength), @(chunkLength));
    for (UInt32 i = 0; i < chunkLength; i += sliceLength) {
        NSUInteger sliceSize = MIN(sliceLength, chunkLength - i);
        // NSLog(@"slice size: %@", @(sliceSize));
        MQAudioSignature *sig = [self audioSignatureForWavechunk:waveChunks + i
                                                 numberOfSamples:sliceSize / numberOfChannels];
        [descriptor appendAudioSignature:sig];
    }
    return descriptor;
}

@end
