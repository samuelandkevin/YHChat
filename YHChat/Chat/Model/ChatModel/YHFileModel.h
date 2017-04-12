//
//  YHFileModel.h
//  YHChat
//
//  Created by YHIOS002 on 17/3/28.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "YHChatServiceDefs.h"



@interface YHFileModel : NSObject

@property (nonatomic,copy) NSString *sessionID;   //会话ID
@property (nonatomic,copy) NSString *fileName;    //文件名
@property (nonatomic,copy) NSString *filePathInServer; //服务器的文件路径
@property (nonatomic,copy) NSString *filePathInLocal;  //本地文件路径
@property (nonatomic,assign) CGFloat fileSize;    //文件大小（float显示）
@property (nonatomic,copy) NSString *fileSizeStr; //文件大小（字符串显示）
@property (nonatomic,copy) NSString *ext; //后缀名
@property (nonatomic,assign,readonly) NSNumber *fileType; //文件类型
@property (nonatomic,assign) BOOL isSelected;
@property (nonatomic,assign) FileStatus status;
@property (nonatomic,assign) float downLoadProgress;//下载进度值 (0-1）
@end
