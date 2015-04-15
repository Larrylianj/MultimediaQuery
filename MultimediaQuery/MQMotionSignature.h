//
//  MQMotionSignature.h
//  MultimediaQuery
//
//  Created by Zichuan Wang on 15/4/11.
//  Copyright (c) 2015年 zichuanwang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MQMotionSignature;

@interface MQMotionSignature : NSObject

@property (nonatomic, readonly) NSArray *JSONPresentation;
@property (nonatomic, readonly) float movementPercentage;

- (id)initWithData:(NSData *)data;

- (id)initWithJSONArray:(NSArray *)array;

@property (nonatomic, readonly) CGPoint avgVector;

/* max: 1 min: 0 */
- (float)distanceToSignature:(MQMotionSignature *)sig;

@end
