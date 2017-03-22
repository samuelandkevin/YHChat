//
//  YHChatImageView.h
//  YHChat
//
//  Created by YHIOS002 on 17/3/22.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YHChatImageView : UIImageView

@property (nonatomic,copy) void(^retweetBlock)(UIImage *image);//转发
@property (nonatomic,copy) void(^withDrawBlock)(UIImage *image);//撤回
@property (nonatomic,assign) BOOL isReceiver;

@end
