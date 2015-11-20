//
//  CoreTextUtils.h
//  CoreTextDemo
//
//  Created by user on 15/9/10.
//  Copyright (c) 2015年 ztchena. All rights reserved.
//  处理检测用户点击是否在链接上

#import <Foundation/Foundation.h>

@interface CoreTextUtils : NSObject

+ (CoreTextLinkData *)touchLinkInView:(UIView *)view atPoint:(CGPoint)point data:(CoreTextData *)data;

+ (CFIndex)touchContentOffsetInView:(UIView *)view atPoint:(CGPoint)point data:(CoreTextData *)data;

@end
