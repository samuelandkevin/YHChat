//
//  YHChatButton.h
//  YHChat
//
//  Created by YHIOS002 on 17/4/6.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YHChatButton : UIButton


@property (nonatomic,copy) void(^retweetFileBlock)();//转发文件
@property (nonatomic,copy) void(^withDrawFileBlock)();//撤回文件

@property (nonatomic,assign) BOOL isReceiver;

@end
