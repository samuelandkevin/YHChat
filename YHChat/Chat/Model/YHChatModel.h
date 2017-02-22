//
//  YHChatModel.h
//  PikeWay
//
//  Created by YHIOS002 on 16/12/29.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "YHChatServiceDefs.h"

#pragma mark - 聊天记录Model
@interface YHChatModel : NSObject

@property (nonatomic,copy) NSString *chatId;       //聊天记录Id
@property (nonatomic,assign) int chatType;         //聊天类型（1:群聊/0:单聊）
@property (nonatomic,copy) NSString *msgContent;   //聊天内容
@property (nonatomic,copy) NSString *content;
@property (nonatomic,copy) NSString *createTime;   //发言时间
@property (nonatomic,copy) NSString *updateTime;   //最近更新时间
@property (nonatomic,copy) NSString *audienceId;   //听众Id
@property (nonatomic,copy) NSURL *audienceAvatar;  //听众头像
@property (nonatomic,copy) NSString *audienceName; //听众名字
@property (nonatomic,copy) NSString *speakerName;  //发布者名称
@property (nonatomic,copy) NSURL *speakerAvatar;   //发布者头像缩略图
@property (nonatomic,copy) NSURL *speakerAvatarOri;//发布者头像原图
@property (nonatomic,copy) NSString *speakerId;    //发布者Id
@property (nonatomic,assign) BOOL isRead;          //是否已读
@property (nonatomic,assign) int timestamp;        //时间戳
@property (nonatomic,assign) int msgType;          //消息类型（语音、文字、图片）  // 0是文本 1是图片 2是语音 3是文件
@property (nonatomic,assign) int direction;

/*****自定义,以后可能并入服务器****/
@property (nonatomic,assign) YHMessageDeliveryState deliveryState;//消息发送状态


/******以下非服务器返回字段******/
@property (nonatomic,assign) CGSize imageSize;
@property (nonatomic,assign) CGFloat cellHeight;



@end

#pragma mark - 聊天的音频文件
@interface YHAudioModel : NSObject
@property (nonatomic,copy) NSString *ext;    //后缀格式
@property (nonatomic,assign) float  duration;//时长
@property (nonatomic,copy) NSURL *url;       //音频url

/******以下非服务器返回字段******/

@end


