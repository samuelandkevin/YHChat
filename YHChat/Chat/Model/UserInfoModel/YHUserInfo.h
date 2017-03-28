//
//  YHUserInfo.h
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 16/4/25.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//  当前用户Model

#import <Foundation/Foundation.h>
#import "YHUserSetting.h"
#import "YHWorkExperienceModel.h"
#import "YHEducationExperienceModel.h"
#import <UIKit/UIKit.h>

typedef enum : NSUInteger
{
	updateFinish = 101,
	updateFailure,
} UpdateStatus;

//好友状态
typedef NS_ENUM(int,FriendShipStatus){
    FriendShipStatus_NotpassValidtion = 0,//未通过验证
    FriendShipStatus_isMyFriend,          //是我的好友
    FriendShipStatus_Reject               //已拒绝
};

//添加好友的状态 (服务器返回：0 别人申请加我为好友 1 我申请加别人为好友  ->解析后 自定义101 别人申请加我为好友 102 我申请加别人为好友)
typedef NS_ENUM(int,AddFriendStatus){
    AddFriendStatus_otherPersonAddMe = 101,  //别人申请加我为好友
    AddFriendStatus_IAddOtherPerson           //我申请加别人为好友
};

//身份类型
typedef NS_ENUM(int,IdentityOption){
    Identity_NormalUser = 0,    //普通用户
    Identity_BigName            //大咖
};

//性别   服务器返回1是男，0是女 ,自定义男101，女100
typedef NS_ENUM(short,Gender){
    Gender_Women = 100,
    Gender_Man
};

@interface YHUserInfo : NSObject {
	BOOL _isRegister;
}

@property (nonatomic, assign)   BOOL isSelfModel;   //用户Model是当前用户还是客人
@property (nonatomic, assign)   BOOL isRegister;    //是否已注册,判断是否是游客
@property (nonatomic, assign) UpdateStatus updateStatus;
@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *accessToken;  //令牌
@property (nonatomic, copy) NSString *taxAccount;   //税道账号
@property (nonatomic, copy) NSString *mobilephone;  //手机号  （可以用手机号/税道账号来登录）
@property (nonatomic, copy) NSString *userName;     //姓名
@property (nonatomic, assign) Gender sex;           // 1-男， 0-女
@property (nonatomic, copy) NSURL *avatarUrl;       //用户头像缩略图URL
@property (nonatomic, copy) NSURL *oriAvaterUrl;    //用户头像原图URL
@property (nonatomic, copy) NSString *intro;        //个人简介
@property (nonatomic, copy) NSString *industry;     //行业职能
@property (nonatomic, copy) NSString *job;          //职位
@property (nonatomic, copy) NSString *province;     //省份
@property (nonatomic, copy) NSString *workCity;     //工作城市
@property (nonatomic, copy) NSString *workLocation; //工作地点
@property (nonatomic, copy) NSString *loginTime;    //登录时间
@property (nonatomic, copy) NSString *company;      //公司名称
@property (nonatomic, copy) NSString *email;        //电邮
@property (nonatomic, assign) int dynamicCount;     //动态数量
@property (nonatomic, copy) NSString *visitTime;    //访问时间
/**
 *  用户头像，用strong因为修改头像时要保存引用
 */
@property (nonatomic, strong)   UIImage *avatarImage;

@property (nonatomic, assign)   short fromType;    //来自哪个平台
@property (nonatomic, assign)   BOOL isOfficial;   //官方账号
@property (nonatomic, assign)   int nNewFansCount; //新粉丝数量
@property (nonatomic, assign)   int fansCount;     //粉丝数量
@property (nonatomic, assign)   int followCount;   //关注的人数量
@property (nonatomic, assign)   int likeCount;     //点赞数量

@property (nonatomic, assign) IdentityOption identity;              //身份类型
@property (nonatomic, assign) FriendShipStatus friShipStatus;         //好友关系状态
@property (nonatomic, assign) AddFriendStatus addFriStatus;          //添加好友的状态   (服务器返回：0 别人申请加我为好友 1 我申请加别人为好友  ->解析后 自定义101 别人申请加我为好友 102 我申请加别人为好友)

@property (nonatomic, assign)   BOOL isFollowed;      //已经被关注

@property (nonatomic, assign)   int photoCount;             //用户照片数量
@property (nonatomic, strong)   NSMutableArray *photoAlbum; //相册

@property (nonatomic, strong)   YHUserSetting *userSetting; //用户设置

@property (nonatomic, strong)   NSMutableArray *jobTags;                                                //职位标签
@property (nonatomic, strong)   NSMutableArray <YHWorkExperienceModel *> *workExperiences;           //工作经历
@property (nonatomic, strong)   NSMutableArray <YHEducationExperienceModel *> *eductaionExperiences; //教育经历
@property (nonatomic, copy)     NSString *department;        //部门
@property (nonatomic, assign)   BOOL isInMyBlackList;  //在我的黑名单


//以下为非服务器返回字段
@property (nonatomic, assign) int  curReqPage;//记录当前请求页码
@end
