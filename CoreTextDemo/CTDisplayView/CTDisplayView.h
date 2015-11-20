//
//  CTDisplayView.h
//  CoreTextDemo
//
//  Created by user on 15/9/7.
//  Copyright (c) 2015年 ztchena. All rights reserved.
//  持有CoreTextData类的实例，负责将CTFrameRef绘制到界面上

#import <UIKit/UIKit.h>

extern NSString *const CTDisplayViewImagePressedNotification;
extern NSString *const CTDisplayViewLinkPressedNotification;

@class CoreTextData;

@interface CTDisplayView : UIView

@property (nonatomic, strong) CoreTextData *data;

@end
