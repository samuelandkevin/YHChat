//
//  YHChatHelper.h
//  YHChat
//
//  Created by YHIOS002 on 17/2/22.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YHChatServiceDefs.h"

@class YHChatModel;
@interface YHChatHelper : NSObject


/**
 随机生成totalCount数量的聊天记录 (模拟服务器返回的数据)

 @param totalCount 数量
 @return YHChatModel的数组
 */
+ (NSArray <YHChatModel *>*)randomGenerateChatModel:(int)totalCount;

//从本地创建一条消息
+ (YHChatModel *)creatMessage:(NSString *)msg msgType:(YHMessageType)msgType  toID:(NSString *)toID;

@end
