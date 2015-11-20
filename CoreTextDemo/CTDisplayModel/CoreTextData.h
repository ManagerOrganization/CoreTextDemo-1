//
//  CoreTextData.h
//  CoreTextDemo
//
//  Created by user on 15/9/7.
//  Copyright (c) 2015年 ztchena. All rights reserved.
//  用于保存由CTFrameParser类生成的CTFrameRef实例以及CTFrameRef实际绘制需要的高度。

#import <Foundation/Foundation.h>

@interface CoreTextData : NSObject

@property (nonatomic, assign) CTFrameRef ctFrame;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, strong) NSArray *imageArray;
@property (nonatomic, strong) NSArray *linkArray;
@property (nonatomic, strong) NSAttributedString *content;

@end
