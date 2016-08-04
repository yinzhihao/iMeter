//
//  UIColor+Util.m
//  iMeter
//
//  Created by yinzhihao on 16/8/4.
//  Copyright © 2016年 zcsmart. All rights reserved.
//

#import "UIColor+Util.h"

@implementation UIColor (Util)

+ (UIColor *)colorWithHex:(UInt32)hexValue alpha:(CGFloat)alpha
{
    return [UIColor colorWithRed:(CGFloat)((hexValue & 0xFF0000) >> 16) / 255.0
                           green:(CGFloat)((hexValue & 0xFF00) >> 8) / 255.0
                            blue:(CGFloat)(hexValue & 0xFF) / 255.0
                           alpha:alpha];
}

+ (UIColor *)colorWithHex:(UInt32)hexValue
{
    return [self colorWithHex:hexValue alpha:1.0];
}

+ (UIColor *)themeColor
{
    return [self colorWithHex:0x167bc1];
}

+ (UIColor *)buttonColor
{
    return [self colorWithHex:0x167bc1];
}

+ (UIColor *)buttonDisableTextColor
{
    return [self colorWithHex:0x73b3e1];
}

+ (UIColor *)backColor
{
    return [self colorWithHex:0xefeef4];
}

+ (UIColor *)warnColor
{
    return [self colorWithHex:0xe8442e];
}

+ (UIColor *)textColor
{
    return [self colorWithHex:0x333333];
}

+ (UIColor *)textLightColor
{
    return [self colorWithHex:0x666666];
}

+ (UIImage *)imageFromColor:(UIColor *)color size:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
