//
//  MQDescriptorViewController.m
//  MultimediaQuery
//
//  Created by Zichuan Wang on 15/4/10.
//  Copyright (c) 2015年 zichuanwang. All rights reserved.
//

#import "MQDescriptorViewController.h"
#import "NSNotificationCenter+Helper.h"
#import <CorePlot/CorePlot.h>
#import "MQVideo.h"
#import "MQIndicatorView.h"

@interface MQDescriptorViewController () <CPTPlotDataSource, CPTPlotDelegate>

@property (nonatomic, strong) MQIndicatorLayer *indicatorLayer;

@property (nonatomic, strong) CPTXYGraph *graph;

@property (nonatomic, weak) IBOutlet CPTGraphHostingView *hostingView;

@property (nonatomic, strong) CPTPlot *plot;

@property (nonatomic, assign) float maxMatchingScore;

@end

@implementation MQDescriptorViewController

- (void)setVideo:(MQVideo *)video {
    if (_dataForPlot.count == 0) return;
    self.maxMatchingScore = video.totalScore;
    if (!self.plot) [self setupCoreplotViews];
    [self.plot reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [NSNotificationCenter addObserverForVideoIndicatorChangedNotification:^(NSNotification *note) {
        CGFloat percentage = [note.userInfo[@"percentage"] floatValue];
        self.indicatorLayer.percentagePoint = CGPointMake(percentage, 0);
    }];
}

- (void)setupCoreplotViews {
    self.graph = [[CPTXYGraph alloc] initWithFrame:self.hostingView.bounds];
    
    self.hostingView.hostedGraph = self.graph;
    
    self.graph.paddingLeft = self.graph.paddingRight = 0;
    self.graph.paddingTop = self.graph.paddingBottom = 0;
    
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0) length:CPTDecimalFromFloat(_dataForPlot.count - 1)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0) length:CPTDecimalFromFloat(1)];
    
    CPTScatterPlot *plot = [[CPTScatterPlot alloc] initWithFrame:CGRectZero];
    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
    lineStyle.lineWidth = 0;
    lineStyle.lineColor = [CPTColor colorWithCGColor:[NSColor whiteColor].CGColor];
    plot.dataLineStyle = lineStyle;
    
    plot.areaFill = [[CPTFill alloc] initWithColor:[CPTColor colorWithCGColor:[NSColor colorWithRed:251 / 255. green:107 / 255. blue:92 / 255. alpha:1].CGColor]];
    plot.areaBaseValue = CPTDecimalFromString(@"0");
    plot.dataSource = self;
    
    plot.areaFill2 = [[CPTFill alloc] initWithColor:[CPTColor colorWithCGColor:[NSColor colorWithRed:251 / 255. green:107 / 255. blue:92 / 255. alpha:1].CGColor]];
    plot.areaBaseValue2 = CPTDecimalFromString(@"0");
    
//    CPTGradient *gradient = [CPTGradient gradientWithBeginningColor:
//                             [CPTColor colorWithCGColor:[NSColor colorWithRed:175 / 255. green:175 / 255. blue:175 / 255. alpha:0.15].CGColor]
//                                                        endingColor:
//                             [CPTColor colorWithCGColor:[NSColor colorWithRed:175 / 255. green:175 / 255. blue:175 / 255. alpha:0.1].CGColor]];
//    gradient.angle = -90;
    
    [self.graph addPlot:plot toPlotSpace:plotSpace];
    
    self.indicatorLayer = [[MQIndicatorLayer alloc] initWithFrame:self.hostingView.bounds];
    [self.hostingView.layer addSublayer:self.indicatorLayer];
    self.indicatorLayer.percentagePoint = CGPointMake(-100, -100);
    [self.indicatorLayer setNeedsDisplay];
    
    self.plot = plot;
}

#pragma mark - Plot Data Source Methods

- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    return _dataForPlot.count;
}

- (NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    if (fieldEnum == CPTScatterPlotFieldX) {
        return @(index);
    } else {
        return _dataForPlot[index];
    }
}

@end
