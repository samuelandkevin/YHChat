//
//  YHPhotoBrowserConfig.h
//  YHPhotoBrowser
//
//  Created by aier on 15-2-9.
//  Copyright (c) 2016年 samuelandkevin. All rights reserved.
//


typedef enum {
    YHWaitingViewModeLoopDiagram, // 环形
    YHWaitingViewModePieDiagram   // 饼型
} YHWaitingViewMode;

// 图片保存成功提示文字
#define YHPhotoBrowserSaveImageSuccessText @" 保存成功 ";

// 图片保存失败提示文字
#define YHPhotoBrowserSaveImageFailText @" 保存失败 ";

// browser背景颜色
#define YHPhotoBrowserBackgrounColor [UIColor colorWithRed:0 green:0 blue:0 alpha:0.95]

// browser中图片间的margin
#define YHPhotoBrowserImageViewMargin 10

// browser中显示图片动画时长
#define YHPhotoBrowserShowImageAnimationDuration 0.25f

// browser中显示图片动画时长
#define YHPhotoBrowserHideImageAnimationDuration 0.25f

// 图片下载进度指示进度显示样式（SDWaitingViewModeLoopDiagram 环形，SDWaitingViewModePieDiagram 饼型）
#define YHWaitingViewProgressMode SDWaitingViewModeLoopDiagram

// 图片下载进度指示器背景色
#define YHWaitingViewBackgroundColor [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7]

// 图片下载进度指示器内部控件间的间距
#define YHWaitingViewItemMargin 10


