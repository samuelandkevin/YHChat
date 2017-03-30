//
//  YHSqilteConfig.h
//  samuelandkevin
//
//  Created by samuelandkevin on 17/1/10.
//  Copyright © 2017年 YHSoft. All rights reserved.
//

#ifndef YHSqilteConfig_h
#define YHSqilteConfig_h

//#import "YHDebug.h"
/**********common宏定义**************/
#define kDatabaseVersionKey     @"YH_DBVersion" //数据库版本
//Doc目录
#define YHDocumentDir [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]

//Cache目录
#define YHCacheDir [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]

//用户目录 (包含聊天目录)
#define YHUserDir [YHDocumentDir stringByAppendingPathComponent:MYUID]



/********************登录用户信息表*****************/

#define YHLoginDir [YHUserDir stringByAppendingPathComponent:@"Login"]


//获取登录用户路径  dir:目录名称 userID:登录用户ID
static inline NSString *pathLoginWithDir( NSString *dir,NSString *userID){
    NSString *pathLog = [dir stringByAppendingPathComponent:[NSString stringWithFormat:@"login_%@.sqlite",userID]];
    return pathLog;
}

//Login表名的命名方式
static inline NSString *tableNameLogin(NSString *userID){
    
    return [NSString stringWithFormat:@"login_%@",[userID stringByReplacingOccurrencesOfString:@"-" withString:@""]];
}



/********************聊天表*****************/
//聊天目录 (包括:群聊目录 + 单聊目录 + 语音目录 + 办公文件目录)
#define YHChatLogDir [YHUserDir stringByAppendingPathComponent:@"ChatLog"]

//群聊目录
#define GroupChatLogDir [YHChatLogDir stringByAppendingPathComponent:@"GroupChat"]

//单聊目录
#define PriChatLogDir [YHChatLogDir stringByAppendingPathComponent:@"PriChat"]

//语音目录
#define ChatRecordDir [YHChatLogDir stringByAppendingPathComponent:@"RecordChat"]

//办公文件目录
#define OfficeDir [YHChatLogDir stringByAppendingPathComponent:@"OfficeDoc"]


//获取聊天记录路径  dir:目录名称 sessionID:会话ID
static inline NSString *pathLogWithDir( NSString *dir,NSString *sessionID){
    NSString *pathLog = [dir stringByAppendingPathComponent:[NSString stringWithFormat:@"yh_%@.sqlite",sessionID]];
    return pathLog;
}

//ChatLog表名的命名方式
static inline NSString *tableNameChatLog(NSString *sessionID){
    
    return [NSString stringWithFormat:@"yh_%@",[sessionID stringByReplacingOccurrencesOfString:@"-" withString:@""]];
}


/********************聊天文件目录表*****************/


//聊天文件表路径
static inline NSString *pathChatFileWithDir( NSString *dir,NSString *sessionID){
    NSString *path = [dir stringByAppendingPathComponent:[NSString stringWithFormat:@"chatFile_%@.sqlite",sessionID]];
    return path;
}

//聊天文件表名的命名方式
static inline NSString *tableNameChatFile(NSString *sessionID){
    
    return [NSString stringWithFormat:@"chatFile_%@",[sessionID stringByReplacingOccurrencesOfString:@"-" withString:@""]];
}




/********************动态表*****************/

//动态目录 (包括：我的动态 + 公共动态 + 好友动态)
#define YHDynDir [YHUserDir stringByAppendingPathComponent:@"Dynamic"]
//我的动态目录
#define YHMyDynDir [YHDynDir stringByAppendingPathComponent:@"MyDyn"]
//公共动态目录
#define YHPublicDynDir [YHDynDir stringByAppendingPathComponent:@"Public"]
//好友动态目录
#define YHFrisDynsDir [YHDynDir stringByAppendingPathComponent:@"FrisDyns"]


//获取聊天记录路径  dir:目录名称 sessionID:会话ID
static inline NSString *pathDynWithDir( NSString *dir,NSString *userID){
    NSString *pathLog = [dir stringByAppendingPathComponent:[NSString stringWithFormat:@"dyn_%@.sqlite",userID]];
    return pathLog;
}

//Dyn表名的命名方式
static inline NSString *tableNameDyn(int dynTag,NSString *userID){
    
    NSString *strID = nil;
    if (dynTag < 0) {
        //我的动态 / 好友动态
        strID = userID;
    }else{
        //公共的动态标签
        strID = [NSString stringWithFormat:@"public%d",dynTag];
    }
    return [NSString stringWithFormat:@"dyn_%@",[strID stringByReplacingOccurrencesOfString:@"-" withString:@""]];
}


/********************好友表*****************/
//好友列表目录 (我的好友 或者 好友的好友)
#define YHFrisDir [YHUserDir stringByAppendingPathComponent:@"Fris"]

//Fris表路径
static inline NSString *pathFrisWithDir( NSString *dir,NSString *friID){
    NSString *pathLog = [dir stringByAppendingPathComponent:[NSString stringWithFormat:@"fri_%@.sqlite",friID]];
    return pathLog;
}

//Fris表名的命名方式
static inline NSString *tableNameFris(NSString *friID){
    
    return [NSString stringWithFormat:@"fri_%@",[friID stringByReplacingOccurrencesOfString:@"-" withString:@""]];
}


/********************我的访客表*****************/
//访客目录
#define YHVisitorsDir [YHCacheDir stringByAppendingPathComponent:@"Vistors"]


//访客表路径
static inline NSString *pathVistorsWithDir( NSString *dir,NSString *intervieweeID){
    NSString *pathLog = [dir stringByAppendingPathComponent:[NSString stringWithFormat:@"interviewee_%@.sqlite",intervieweeID]];
    return pathLog;
}

//Fris表名的命名方式
static inline NSString *tableNameVisitors(NSString *intervieweeID){
    
    return [NSString stringWithFormat:@"vis_%@",[intervieweeID stringByReplacingOccurrencesOfString:@"-" withString:@""]];
}

/********************办公文件表*****************/
//办公文件表路径
static inline NSString *pathOfficeFileWithDir(NSString *dir){
    NSString *pathLog = [dir stringByAppendingPathComponent:[NSString stringWithFormat:@"officeFile.sqlite"]];
    return pathLog;
}

//办公文件表名的命名方式
static inline NSString *tableNameOfficeFile(){
    return @"officeFile";
}


#endif /* YHSqilteConfig_h */
