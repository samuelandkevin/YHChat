//
//  TestData.h
//  YHChat
//
//  Created by samuelandkevin on 17/2/27.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//  模拟服务器数据

#import <Foundation/Foundation.h>
@class YHChatModel;
@class YHChatListModel;

@interface TestData : NSObject

/**
 随机生成totalCount数量的聊天记录 (模拟服务器返回的数据)
 
 @param totalCount 数量
 @return YHChatModel的数组
 */
+ (NSArray <YHChatModel *>*)randomGenerateChatModel:(int)totalCount aChatListModel:(YHChatListModel *)aChatListModel;


/**
 //随机生成totalCount数量的聊天列表 (模拟服务器返回的数据)

 @param totalCount 数量
 @return YHChatListModel的数组
 */
+ (NSArray <YHChatListModel *>*)randomGenerateChatListModel:(int)totalCount;

@end
