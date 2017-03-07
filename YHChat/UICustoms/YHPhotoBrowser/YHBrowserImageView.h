//
//  YHBrowserImageView.h
//  YHPhotoBrowserView
//
//  Created by samuelandkevin on 16-12-14.
//  Copyright (c) 2016年 samuelandkevin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YHWaitingView.h"


@interface YHBrowserImageView : UIImageView <UIGestureRecognizerDelegate>

@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, assign, readonly) BOOL isScaled;
@property (nonatomic, assign) BOOL hasLoadedImage;

- (void)eliminateScale; // 清除缩放

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder;

- (void)doubleTapToZommWithScale:(CGFloat)scale;

- (void)clear;

@end
