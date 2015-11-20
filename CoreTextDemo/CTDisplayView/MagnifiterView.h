//
//  MagnifiterView.h
//  CoreTextDemo
//
//  Created by user on 15/9/7.
//  Copyright (c) 2015年 ztchena. All rights reserved.
//  放大镜

#import <UIKit/UIKit.h>

@interface MagnifiterView : UIView

@property (weak, nonatomic) UIView *viewToMagnify;
@property (nonatomic) CGPoint touchPoint;

@end
