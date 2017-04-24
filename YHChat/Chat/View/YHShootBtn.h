//
//  YHShootBtn.h
//  YHChat
//
//  Created by YHIOS002 on 2017/4/18.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>


@interface YHShootBtn : UIView

@property (nonatomic,assign) UIView *superView;


//选择视频
- (void)chooseVideoHandler:(void(^)(NSString *path))complete;
//停止拍摄
- (void)stopShootingHandler:(void(^)(NSString *path))complete;
//取消拍摄
- (void)cancelShooting;

@end
