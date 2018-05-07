//
//  YHChatListModel.h
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 17/2/23.
//  Copyright © 2017年 YHSoft. All rights reserved.
//  聊天列表

#import <Foundation/Foundation.h>
#import "YHChatTouch.h"

@interface YHChatListModel : NSObject

@property (nonatomic,copy) NSString *chatId;
@property (nonatomic,assign)BOOL isGroupChat;
@property (nonatomic,copy) NSString *lastContent;
@property (nonatomic,assign) int msgType;
@property (nonatomic,copy) NSString *userId;
@property (nonatomic,copy) NSString *sessionUserId;
@property (nonatomic,copy) NSString *sessionUserName;
@property (nonatomic,assign) BOOL isRead;
@property (nonatomic,assign) int memberCount;
@property (nonatomic,copy) NSString *groupName;
@property (nonatomic,copy) NSString *creatTime;
@property (nonatomic,copy) NSString *lastCreatTime;
@property (nonatomic,strong) NSArray < NSURL *> *sessionUserHead;
@property (nonatomic,copy) NSString *msgId;
@property (nonatomic,assign) int status;
@property (nonatomic,copy) NSString *updateTime;

@property (nonatomic,strong) YHChatTouch *touchModel;
@end

