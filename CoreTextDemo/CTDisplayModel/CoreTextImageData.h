//
//  CoreTextImageData.h
//  CoreTextDemo
//
//  Created by user on 15/9/9.
//  Copyright (c) 2015年 ztchena. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoreTextImageData : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSInteger position;
// 此坐标 CoreText 的坐标系，而不是 UIKit 的坐标系
@property (nonatomic, assign) CGRect imagePosition;

@end
