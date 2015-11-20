//
//  CTFrameParser.h
//  CoreTextDemo
//
//  Created by user on 15/9/7.
//  Copyright (c) 2015年 ztchena. All rights reserved.
//  用于生成最后绘制界面需要的CTFrameRef实例

#import <Foundation/Foundation.h>

@interface CTFrameParser : NSObject

+ (NSMutableDictionary *)attributesWithConfig:(CTFrameParserConfig *)config;

+ (CoreTextData *)parseContent:(NSString *)content config:(CTFrameParserConfig *)config;

+ (CoreTextData *)parseTemplateFile:(NSString *)path config:(CTFrameParserConfig*)config;

+ (CoreTextData *)parseAttributedContent:(NSAttributedString *)content config:(CTFrameParserConfig *)config;

@end
