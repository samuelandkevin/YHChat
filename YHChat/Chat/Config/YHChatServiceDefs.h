//
//  YHChatServiceDefs.h
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 17/2/22.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//  相关宏定义

#ifndef YHChatServiceDefs_h
#define YHChatServiceDefs_h


// 消息发送状态
typedef NS_ENUM(NSUInteger, YHMessageDeliveryState) {
    YHMessageDeliveryState_Pending = 0,  // 待发送
    YHMessageDeliveryState_Delivering,   // 正在发送
    YHMessageDeliveryState_Delivered,    // 已发送，成功
    YHMessageDeliveryState_Failure,      // 发送失败
    YHMessageDeliveryState_ServiceFaid   // 发送服务器失败(可能其它错,待扩展)
};

// 消息类型
typedef NS_ENUM(NSUInteger,YHMessageType){
    YHMessageType_Text  = 0,             // 文本
    YHMessageType_Image,                 // 图片
    YHMessageType_Voice,                 // 短录音
    YHMessageType_Doc,                   // 文档
    YHMessageType_GIF,                   // 动态图
    YHMessageType_Video,                 // 短视频
    YHMessageType_TextURL,               // 文本＋链接
    YHMessageType_ImageURL,              // 图片＋链接
    YHMessageType_URL,                   // 纯链接
    YHMessageType_DrtNews,               // 送达号
    YHMessageType_NTF   = 12,            // 通知
    
    YHMessageType_DTxt  = 21,            // 纯文本
    YHMessageType_DPic  = 22,            // 文本＋单图
    YHMessageType_DMPic = 23,            // 文本＋多图
    YHMessageType_DVideo= 24,            // 文本＋视频
    YHMessageType_PicURL= 25             // 动态图文链接

};

// 群聊类型
typedef NS_ENUM(NSUInteger,YHGroupType){
    YHGroup_SELF = 0,                    // 自己
    YHGroup_DOUBLE,                      // 双人组
    YHGroup_MULTI,                       // 多人组
    YHGroup_TODO,                        // 待办
    YHGroup_QING,                        // 轻应用
    YHGroup_NATIVE,                      // 原生应用
    YHGroup_DISCOVERY,                   // 发现
    YHGroup_DIRECT,                      // 送达号
    YHGroup_NOTIFY,                      // 通知
    YHGroup_BOOK                         // 通讯录
};

// 消息状态
typedef NS_ENUM(NSUInteger,YHMessageStatus){
    YHMessageStatus_unRead = 0,          // 消息未读
    YHMessageStatus_read,                // 消息已读
    YHMessageStatus_back                 // 消息撤回
};

// 行为类型
typedef NS_ENUM(NSUInteger,YHActionType){
    YHActionType_READ = 1,               // 语音已读
    YHActionType_BACK,                   // 消息撤回
    YHActionType_UPTO,                   // 消息读数
    YHActionType_KICK,                   // 请出会话
    YHActionType_OPOK,                   // 待办已办
    YHActionType_BDRT,                   // 送达号消息撤回
    YHActionType_GUPD,                   // 群信息修改
    YHActionType_UUPD,                   // 群成员信息修改
    YHActionType_DUPD,                   // 送达号信息修改
    YHActionType_OFFL = 10,              // 请您下线
    YHActionType_STOP = 11,              // 清除所有缓存
    YHActionType_UUPN                    // 改昵称
};

// 聊天盒子状态
typedef NS_ENUM(NSInteger, YHChatBoxStatus) {
    YHChatBoxStatusNothing,     // 默认状态
    YHChatBoxStatusShowVoice,   // 录音状态
    YHChatBoxStatusShowFace,    // 输入表情状态
    YHChatBoxStatusShowMore,    // 显示“更多”页面状态
    YHChatBoxStatusShowKeyboard,// 正常键盘
    YHChatBoxStatusShowVideo    // 录制视频
};

// 订阅状态
typedef NS_ENUM(NSUInteger,YHDeliverSubcribeStatus){
    YHDeliverSubcribeStatus_Can        = 0,   // 可订阅
    YHDeliverSubcribeStatus_Already,
    YHDeliverSubcribeStatus_System
};

// 消息置顶状态
typedef NS_ENUM(NSUInteger,YHDeliverTopStatus){
    YHDeliverTopStatus_NO         = 0, // 非置顶
    YHDeliverTopStatus_YES             // 置顶
};

// 文件类型
typedef NS_ENUM(NSUInteger,YHFileType){
    YHFileType_Other = 0,                // 其它类型
    YHFileType_Audio,                    //
    YHFileType_Video,                    //
    YHFileType_Html,
    YHFileType_Pdf,
    YHFileType_Doc,
    YHFileType_Xls,
    YHFileType_Ppt,
    YHFileType_Img,
    YHFileType_Txt
};

typedef NS_ENUM(int,FileStatus){
    FileStatus_UnDownLoaded = 0,
    FileStatus_isDownLoading,
    FileStatus_HasDownLoaded
};

#endif /* YHChatServerDefs_h */
