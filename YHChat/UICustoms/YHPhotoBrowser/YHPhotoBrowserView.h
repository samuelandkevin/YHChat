//
//  YHPhotoBrowserView.h
//  YHPhotoBrowser
//
//  Created by samuelandkevin on 16-12-14.
//  Copyright (c) 2016年 samuelandkevin. All rights reserved.
//

#import <UIKit/UIKit.h>


@class YHButton, YHPhotoBrowserView;

@protocol YHPhotoBrowserViewDelegate <NSObject>

@required

- (UIImage *)photoBrowser:(YHPhotoBrowserView *)browser placeholderImageForIndex:(NSInteger)index;

@optional

- (NSURL *)photoBrowser:(YHPhotoBrowserView *)browser highQualityImageURLForIndex:(NSInteger)index;

@end


@interface YHPhotoBrowserView : UIView <UIScrollViewDelegate>

@property (nonatomic, weak) UIView *sourceImagesContainerView;//图片容器
@property (nonatomic, assign) NSInteger currentImageIndex;//当前显示的图片在相册的位置
@property (nonatomic, assign) NSInteger imageCount;//图片数量

@property (nonatomic, weak) UIView *currentImageView;//当前要显示的图片

@property (nonatomic, weak) id<YHPhotoBrowserViewDelegate> delegate;

- (void)show;

@end
