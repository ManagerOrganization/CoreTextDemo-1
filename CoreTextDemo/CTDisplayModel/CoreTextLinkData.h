//
//  CoreTextLinkData.h
//  CoreTextDemo
//
//  Created by user on 15/9/10.
//  Copyright (c) 2015年 ztchena. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoreTextLinkData : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, assign) NSRange range;

@end
