//
//  MQIndicatorView.h
//  MultimediaQuery
//
//  Created by Zichuan Wang on 15/4/10.
//  Copyright (c) 2015年 zichuanwang. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CorePlot/CorePlot.h>

@interface MQIndicatorLayer : CPTLayer

@property (nonatomic, assign) CGPoint percentagePoint;

@property (nonatomic, assign) CGFloat maxIndicatorX;

@end
