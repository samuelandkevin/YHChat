//
//  YHChatLabel.h
//  samuelandkevin
//
//  Created by samuelandkevin on 16/8/25.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YYKit/YYKit.h>

@interface YHChatLabel : YYLabel

@property (nonatomic,copy) void(^retweetBlock)(NSString *text);//转发
@property (nonatomic,copy) void(^withDrawBlock)(NSString *text);//撤回
@property (nonatomic,copy) void(^showMenuItemBlock)();
@property (nonatomic,assign) BOOL isReceiver;
@property (nonatomic,copy) NSString *str;//不用self.text取文本，因为和YYLabel的ignoreCommonProperties有冲突。
@end
