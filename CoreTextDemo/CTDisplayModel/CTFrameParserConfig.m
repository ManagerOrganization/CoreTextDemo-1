//
//  CTFrameParserConfig.m
//  CoreTextDemo
//
//  Created by user on 15/9/7.
//  Copyright (c) 2015年 ztchena. All rights reserved.
//

#import "CTFrameParserConfig.h"

@implementation CTFrameParserConfig

// 重写初始化方法
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.width = 200.0f;
        self.fontSize = 16.0f;
        self.lineSpace = 8.0f;
        self.textColor = RGB(108, 108, 108);
    }
    return self;
}

@end
