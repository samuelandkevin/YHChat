//
//  YHShootBotView.h
//  YHChat
//
//  Created by YHIOS002 on 2017/4/18.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//  拍摄底部View

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(int,ShootType){
    ShootType_Photo = 1,
    ShootType_Video
};

@interface YHShootBotView : UIView

@property (nonatomic,assign) UIView *superView;//父视图

//选择回调 (图片类型的obj为UIImage,视频类型的obj为路径NSString)
- (void)chooseHandler:(void(^)(ShootType type,id obj))complete;
//取消拍摄
- (void)cancelShooting:(void(^)())complete;
//拍摄介绍
- (void)stopShooting:(void(^)())complete;

@end
