//
//  UIImage+Extension.h
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 17/2/24.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Extension)

//图片压缩
+ (UIImage *)compressImage:(UIImage *)oriImg;
//生成带箭头的图片
+ (UIImage *)imageArrowWithSize:(CGSize)imageSize
                          image:(UIImage *)image
                       isSender:(BOOL)isSender;

+ (CGSize)handleImgSize:(CGSize)retSize;
+ (CGSize)handleImgSize:(CGSize)imgSize
                maxSize:(CGSize)maxSize;
@end
