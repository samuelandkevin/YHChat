//
//  YHChatLabel.h
//  PikeWay
//
//  Created by YHIOS002 on 16/8/25.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YYKit/YYKit.h>

@interface YHChatLabel : YYLabel

@property (nonatomic,copy) void(^retweetBlock)(NSString *text);//转发
@property (nonatomic,copy) void(^withDrawBlock)(NSString *text);//撤回
@property (nonatomic,assign) BOOL isReceiver;
@end
