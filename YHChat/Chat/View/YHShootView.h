//
//  YHShootView.h
//  YHChat
//
//  Created by samuelandkevin on 2017/4/25.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YHShootBotView.h"

@interface YHShootView : UIView

//返回
- (void)onBackHandler:(void(^)())handler;
//选择回调 (图片类型的obj为UIImage,视频类型的obj为路径NSString)
- (void)chooseHandler:(void(^)(ShootType type,id obj))complete;
@end
