//
//  CTFrameParser.m
//  CoreTextDemo
//
//  Created by user on 15/9/7.
//  Copyright (c) 2015年 ztchena. All rights reserved.
//

#import "CTFrameParser.h"

@implementation CTFrameParser

static CGFloat ascentCallback(void *ref){
    return [(NSNumber*)[(__bridge NSDictionary*)ref objectForKey:@"height"] floatValue];
}

static CGFloat descentCallback(void *ref){
    return 0;
}

static CGFloat widthCallback(void *ref){
    return [(NSNumber*)[(__bridge NSDictionary*)ref objectForKey:@"width"] floatValue];
}

+ (NSMutableDictionary *)attributesWithConfig:(CTFrameParserConfig *)config
{
    CGFloat fontSize = config.fontSize;
    // 设置字体
    CTFontRef fontRef = CTFontCreateWithName((CFStringRef)@"ArialMT", fontSize, NULL);
    CGFloat lineSpacing = config.lineSpace;
    const CFIndex kNumberOfSettings = 3;
    // 设置段落样式: 行间距
    CTParagraphStyleSetting theSettings[kNumberOfSettings] = {
        { kCTParagraphStyleSpecifierLineSpacingAdjustment, sizeof(CGFloat), &lineSpacing },
        { kCTParagraphStyleSpecifierMaximumLineSpacing, sizeof(CGFloat), &lineSpacing },
        { kCTParagraphStyleSpecifierMinimumLineSpacing, sizeof(CGFloat), &lineSpacing }
    };
    // 创建段落样式
    CTParagraphStyleRef theParagraphRef = CTParagraphStyleCreate(theSettings, kNumberOfSettings);
    
    UIColor * textColor = config.textColor;
    // 设置 Attributes: 文字颜色, 字体大小, 段落样式
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    dict[(id)kCTForegroundColorAttributeName] = (id)textColor.CGColor;
    dict[(id)kCTFontAttributeName] = (__bridge id)fontRef;
    dict[(id)kCTParagraphStyleAttributeName] = (__bridge id)theParagraphRef;
    // 释放内存
    CFRelease(theParagraphRef);
    CFRelease(fontRef);
    return dict;
}

// 用于提供对外的接口，调用方法二实现从一个 JSON 的模版文件中读取内容，然后调用方法五生成CoreTextData
+ (CoreTextData *)parseTemplateFile:(NSString *)path
                             config:(CTFrameParserConfig*)config
{
    NSMutableArray *imageArray = [NSMutableArray array];
    NSMutableArray *linkArray = [NSMutableArray array];
    NSAttributedString *content = [self loadTemplateFile:path config:config imageArray:imageArray linkArray:linkArray];
    CoreTextData *data = [self parseAttributedContent:content config:config];
    data.imageArray = imageArray;
    data.linkArray = linkArray;
    return data;
}

// 读取 JSON 文件内容，并且调用方法三获得从NSDictionary到NSAttributedString的转换结果
+ (NSAttributedString *)loadTemplateFile:(NSString *)path
                                  config:(CTFrameParserConfig *)config
                              imageArray:(NSMutableArray *)imageArray
                               linkArray:(NSMutableArray *)linkArray
{
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSMutableAttributedString *result = [[NSMutableAttributedString alloc] init];
    if (data) {
        NSArray *array = [NSJSONSerialization JSONObjectWithData:data
                                                         options:NSJSONReadingAllowFragments
                                                           error:nil];
        if ([array isKindOfClass:[NSArray class]]) {
            for (NSDictionary *dict in array) {
                NSString *type = dict[@"type"];
                if ([type isEqualToString:@"txt"]) {
                    NSAttributedString *as = [self parseAttributedContentFromNSDictionary:dict
                                                                                   config:config];
                    [result appendAttributedString:as];
                } else if ([type isEqualToString:@"img"]) {
                    // 创建 CoreTextImageData
                    CoreTextImageData *imageData = [[CoreTextImageData alloc] init];
                    imageData.name = dict[@"name"];
                    imageData.position = [result length];
                    [imageArray addObject:imageData];
                    // 创建空白占位符，并且设置它的 CTRunDelegate 信息
                    NSAttributedString *as = [self parseImageDataFromNSDictionary:dict
                                                                           config:config];
                    [result appendAttributedString:as];
                } else if ([type isEqualToString:@"link"]) {
                    NSUInteger startPos = result.length;
                    NSAttributedString *as = [self parseAttributedContentFromNSDictionary:dict
                                                                                   config:config];
                    [result appendAttributedString:as];
                    // 创建 CoreTextLinkData
                    NSUInteger length = result.length - startPos;
                    NSRange linkRange = NSMakeRange(startPos, length);
                    CoreTextLinkData *linkData = [[CoreTextLinkData alloc] init];
                    linkData.title = dict[@"content"];
                    linkData.url = dict[@"url"];
                    linkData.range = linkRange;
                    [linkArray addObject:linkData];
                }
            }
        }
    }
    return result;
}

// 生成图片空白的占位符，并且设置其 CTRunDelegate 信息
+ (NSAttributedString *)parseImageDataFromNSDictionary:(NSDictionary *)dict
                                                config:(CTFrameParserConfig *)config
{
    CTRunDelegateCallbacks callbacks;
    memset(&callbacks, 0, sizeof(CTRunDelegateCallbacks));
    callbacks.version = kCTRunDelegateVersion1;
    callbacks.getAscent = ascentCallback;
    callbacks.getDescent = descentCallback;
    callbacks.getWidth = widthCallback;
    CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks, (__bridge void *)(dict));
    
    // 使用 0xFFFC 作为空白的占位符
    unichar objectReplacementChar = 0xFFFC;
    NSString *content = [NSString stringWithCharacters:&objectReplacementChar length:1];
    NSDictionary *attributes = [self attributesWithConfig:config];
    NSMutableAttributedString *space = [[NSMutableAttributedString alloc] initWithString:content attributes:attributes];
    CFAttributedStringSetAttribute((CFMutableAttributedStringRef)space, CFRangeMake(0, 1), kCTRunDelegateAttributeName, delegate);
    CFRelease(delegate);
    return space;
}

+ (CoreTextData *)parseContent:(NSString *)content
                        config:(CTFrameParserConfig *)config
{
    NSDictionary *attributes = [self attributesWithConfig:config];
    NSAttributedString *contentString = [[NSAttributedString alloc] initWithString:content attributes:attributes];
    return [self parseAttributedContent:contentString config:config];
}

// 将NSDictionary内容转换为NSAttributedString
+ (NSAttributedString *)parseAttributedContentFromNSDictionary:(NSDictionary *)dict
                                                       config:(CTFrameParserConfig *)config
{
    NSMutableDictionary *attributes = [self attributesWithConfig:config];
    // set color
    UIColor *color = [self colorFromTemplate:dict[@"color"]];
    if (color) {
        attributes[(id)kCTForegroundColorAttributeName] = (id)color.CGColor;
    }
    // set font size
    CGFloat fontSize = [dict[@"size"] floatValue];
    if (fontSize > 0) {
        CTFontRef fontRef = CTFontCreateWithName((CFStringRef)@"ArialMT", fontSize, NULL);
        attributes[(id)kCTFontAttributeName] = (__bridge id)fontRef;
        CFRelease(fontRef);
    }
    NSString *content = dict[@"content"];
    return [[NSAttributedString alloc] initWithString:content attributes:attributes];
}

// 提供将NSString转为UIColor的功能
+ (UIColor *)colorFromTemplate:(NSString *)name
{
    if ([name isEqualToString:@"blue"]) {
        return [UIColor blueColor];
    } else if ([name isEqualToString:@"red"]) {
        return [UIColor redColor];
    } else if ([name isEqualToString:@"black"]) {
        return [UIColor blackColor];
    }
    return nil;
}

// 接受一个NSAttributedString和一个config参数，将NSAttributedString转换成CoreTextData返回
+ (CoreTextData *)parseAttributedContent:(NSAttributedString *)content
                                  config:(CTFrameParserConfig *)config
{
    // 创建 CTFramesetterRef 实例: 获取frame
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)content);
    
    // 获得要限制的区域的高度
    CGSize restricSize = CGSizeMake(config.width, CGFLOAT_MAX);
    CGSize coreTextSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), nil, restricSize, nil);
    CGFloat textHeight = coreTextSize.height;
    
    // 生成 CTFrameRef 实例
    CTFrameRef frame = [self creatFrameWithFramesetter:framesetter config:config height:textHeight];
    
    // 将生成的 CTFrameRef 实例和计算好的缓制高度保存到 CoreTextData 实例中, 最后返回 CoreTextData 实例
    CoreTextData *data = [[CoreTextData alloc] init];
    data.ctFrame = frame;
    data.height = textHeight;
    data.content = content;
    
    // 释放内存
    CFRelease(frame);
    CFRelease(framesetter);
    
    return data;
}

+ (CTFrameRef)creatFrameWithFramesetter:(CTFramesetterRef)framesetter
                                 config:(CTFrameParserConfig *)config
                                 height:(CGFloat)height
{
    // 创建绘制路径
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0, 0, config.width, height));
    // 生成 CTFrameRef 实例
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
    // 释放内存
    CFRelease(path);
    return frame;
}

@end
