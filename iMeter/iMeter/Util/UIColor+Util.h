//
//  UIColor+Util.h
//  iMeter
//
//  Created by yinzhihao on 16/8/4.
//  Copyright © 2016年 zcsmart. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Util)

+ (UIColor *)colorWithHex:(UInt32)hexValue alpha:(CGFloat)alpha;

+ (UIColor *)colorWithHex:(UInt32)hexValue;

+ (UIColor *)themeColor;

+ (UIColor *)buttonColor;

+ (UIColor *)buttonDisableTextColor;

+ (UIColor *)backColor;

+ (UIColor *)warnColor;

+ (UIColor *)textColor;

+ (UIColor *)textLightColor;


+ (UIImage *)imageFromColor:(UIColor *)color size:(CGSize)size;


@end
