//
//  YHChatHelper.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 17/2/22.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "YHChatHelper.h"
#import "YHChatModel.h"

@implementation YHChatHelper

#pragma mark - Public
+ (YHChatModel *)creatMessage:(NSString *)msg msgType:(YHMessageType)msgType  toID:(NSString *)toID {
    YHChatModel *model  = [YHChatModel new];
    model.speakerId     = MYUID;
    model.speakerAvatar = MYAVTARURL;
    model.direction     = 0;
    model.msgType       = msgType;
    model.audienceId = toID;
    model.chatType   = msgType;
    model.msgContent = msg;
    model.timestamp  = [YHChatHelper currentMsgTime];
    return model;
}

// current message time
+ (int)currentMsgTime
{
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    int iTime     = (int)(time * 1000);
    return iTime;
}
@end
