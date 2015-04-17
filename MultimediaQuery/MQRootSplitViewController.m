//
//  MQRootSplitViewController.m
//  MultimediaQuery
//
//  Created by Zichuan Wang on 15/4/9.
//  Copyright (c) 2015年 zichuanwang. All rights reserved.
//

#import "MQRootSplitViewController.h"

@interface MQRootSplitViewController ()

@end

@implementation MQRootSplitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
}

- (void)awakeFromNib {
    NSViewController *left = [self.splitViewItems[0] viewController];
    [left.view addConstraint:[NSLayoutConstraint constraintWithItem:left.view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:500]];
    
    NSViewController *middle = [self.splitViewItems[1] viewController];
    [middle.view addConstraint:[NSLayoutConstraint constraintWithItem:middle.view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:352]];
    
    NSViewController *right = [self.splitViewItems[2] viewController];
    [right.view addConstraint:[NSLayoutConstraint constraintWithItem:right.view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:400]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:288 * 2]];
}

@end
