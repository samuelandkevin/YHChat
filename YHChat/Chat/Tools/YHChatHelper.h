//
//  YHChatHelper.h
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 17/2/22.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YHChatServiceDefs.h"

@class YHChatModel;
@interface YHChatHelper : NSObject

//从本地创建一条消息
+ (YHChatModel *)creatMessage:(NSString *)msg msgType:(YHMessageType)msgType  toID:(NSString *)toID;

@end
