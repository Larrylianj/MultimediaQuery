//
//  MQIndicatorView.m
//  MultimediaQuery
//
//  Created by Zichuan Wang on 15/4/10.
//  Copyright (c) 2015年 zichuanwang. All rights reserved.
//

#import "MQIndicatorView.h"

@interface MQIndicatorLayer () {
    NSColor *_lineColor;
    NSColor *_indicatorColor;
}


@end

@implementation MQIndicatorLayer

- (id)initWithFrame:(CGRect)newFrame {
    self = [super initWithFrame:newFrame];
    if (self) {
        _indicatorColor = [NSColor colorWithRed:0 / 255. green:0 / 255. blue:0 / 255. alpha:0.4];
        _lineColor = [NSColor whiteColor];
    }
    return self;
}

- (void)drawInContext:(CGContextRef)ctx {
    CGContextSetFillColorWithColor(ctx, _lineColor.CGColor);
    CGContextFillRect(ctx, CGRectMake(0, 0, 1, self.bounds.size.height));
    
    CGFloat x = floor(self.bounds.size.width * self.percentagePoint.x);
    // CGFloat y = floor(self.bounds.size.height * self.percentagePoint.y);
    CGContextSetFillColorWithColor(ctx, _indicatorColor.CGColor);
    CGContextFillRect(ctx, CGRectMake(x, 0, 2, self.bounds.size.height));
    // CGContextFillEllipseInRect(ctx, CGRectMake(x - 5, y - 5, 10, 10));
}

- (void)setPercentagePoint:(CGPoint)percentagePoint {
    if (_percentagePoint.x != percentagePoint.x) {
        _percentagePoint = percentagePoint;
        [self setNeedsDisplay];
    }
}

@end
