//
//  YHChatModel.h
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 16/12/29.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "YHChatServiceDefs.h"
#import "YHChatTextLayout.h"
#import "YHFileModel.h"
#import "YHGIFModel.h"

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
@property (nonatomic,assign) int msgType;          //消息类型 // 0是文本 1是图片 2是语音 3是文件 4是gif
@property (nonatomic,assign) int direction;
@property (nonatomic,assign) int status; //消息状态（撤回：1,未撤回：0）

/*****自定义,以后可能并入服务器****/
@property (nonatomic,assign) YHMessageDeliveryState deliveryState;//消息发送状态


/******以下非服务器返回字段******/
@property (nonatomic,assign) CGSize imageSize;
@property (nonatomic,assign) CGFloat cellHeight;
@property (nonatomic,assign) BOOL isSelected;  //被选中
@property (nonatomic,assign) BOOL showCheckBox;//显示勾选框
@property (nonatomic,strong) YHChatTextLayout *layout;
@property (nonatomic,strong) YHFileModel *fileModel;
@property (nonatomic,strong) YHGIFModel  *gifModel;
@end

#pragma mark - 聊天的音频文件
@interface YHAudioModel : NSObject
@property (nonatomic,copy) NSString *ext;    //后缀格式
@property (nonatomic,assign) float  duration;//时长
@property (nonatomic,copy) NSURL *url;       //音频url

/******以下非服务器返回字段******/

@end


