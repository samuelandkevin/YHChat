//
//  UIImage+Extension.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 17/2/24.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "UIImage+Extension.h"

@implementation UIImage (Extension)


// 压缩图片
+ (UIImage *)compressImage:(UIImage *)oriImg
{
    CGSize imageSize = [self handleImgSize:oriImg.size];
    UIGraphicsBeginImageContextWithOptions(imageSize, YES, 0.0);
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, imageSize.width, imageSize.height)];
    CGContextAddPath(contextRef, bezierPath.CGPath);
    CGContextClip(contextRef);
    [oriImg drawInRect:CGRectMake(0, 0, imageSize.width, imageSize.height)];
    UIImage *clipedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return clipedImage;
}

//处理图片Size
+ (CGSize)handleImgSize:(CGSize)retSize {
    CGFloat width = 0;
    CGFloat height = 0;
    if (retSize.width > retSize.height) {
        width = SCREEN_WIDTH;
        height = retSize.height / retSize.width * width;
    } else {
        height = SCREEN_HEIGHT;
        width = retSize.width / retSize.height * height;
    }
    return CGSizeMake(width, height);
}

+ (CGSize)handleImgSize:(CGSize)imgSize
                maxSize:(CGSize)maxSize{
    CGFloat width = 0;
    CGFloat height = 0;
    if (imgSize.width > imgSize.height) {
        width  = maxSize.width;
        height = imgSize.height / imgSize.width * width;
    } else {
        height = maxSize.height;
        width  = imgSize.width / imgSize.height * height;
    }
    return CGSizeMake(width, height);
}

//生成带箭头的图片
+ (UIImage *)imageArrowWithSize:(CGSize)imageSize
                            image:(UIImage *)image
                           isSender:(BOOL)isSender
{
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.0);
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    UIBezierPath *path = [self getArrowBezierPath:isSender imageSize:imageSize];
    CGContextAddPath(contextRef, path.CGPath);
    CGContextEOClip(contextRef);
    [image drawInRect:CGRectMake(0, 0, imageSize.width, imageSize.height)];
    UIImage *arrowImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return arrowImage;
}

//获取带箭头的Bezier路径
+ (UIBezierPath *)getArrowBezierPath:(BOOL)isSender
                           imageSize:(CGSize)imageSize
{
    CGFloat arrowWidth = 6;
    CGFloat marginTop = 15;
    CGFloat arrowHeight = 10;
    CGFloat imageW = imageSize.width;
    UIBezierPath *path;
    if (isSender) {
        path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, imageSize.width - arrowWidth, imageSize.height) cornerRadius:6];
        [path moveToPoint:CGPointMake(imageW - arrowWidth, 0)];
        [path addLineToPoint:CGPointMake(imageW - arrowWidth, marginTop)];
        [path addLineToPoint:CGPointMake(imageW, marginTop + 0.5 * arrowHeight)];
        [path addLineToPoint:CGPointMake(imageW - arrowWidth, marginTop + arrowHeight)];
        [path closePath];
        
    } else {
        path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(arrowWidth, 0, imageSize.width - arrowWidth, imageSize.height) cornerRadius:6];
        [path moveToPoint:CGPointMake(arrowWidth, 0)];
        [path addLineToPoint:CGPointMake(arrowWidth, marginTop)];
        [path addLineToPoint:CGPointMake(0, marginTop + 0.5 * arrowHeight)];
        [path addLineToPoint:CGPointMake(arrowWidth, marginTop + arrowHeight)];
        [path closePath];
    }
    return path;
}


@end
