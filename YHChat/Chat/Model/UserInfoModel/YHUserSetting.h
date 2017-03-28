//
//  YHUserSetting.h
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 16/5/2.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//  用户隐私设置

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger,Person){
    Person_All      =0,//所有人
    Person_MyFrinds    //好友
};

@interface YHUserSetting : NSObject

@property (nonatomic, assign)Person    whoCanReadMyInfo;//谁可以查看我的资料
@property (nonatomic, assign)Person    whoCanAddMetoFriend;        //谁可以把我添加为好友
@property (nonatomic, copy)NSArray *   whoCannotReadMyDynamic;     //不让他看我的动态
@property (nonatomic, copy)NSArray *    whoseDynamicIdonotRead;      //不看他的动态

@end
