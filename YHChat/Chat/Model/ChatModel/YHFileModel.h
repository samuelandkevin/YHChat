//
//  YHFileModel.h
//  YHChat
//
//  Created by YHIOS002 on 17/3/28.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface YHFileModel : NSObject

@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *filePath;
@property (nonatomic,assign) CGFloat fileSize;    //文件大小（float显示）
@property (nonatomic,copy) NSString *fileSizeStr; //文件大小（字符串显示）
@property (nonatomic,copy) NSString *ext;//后缀名
@property (nonatomic,assign,readonly) NSNumber *fileType; //文件类型
@property (nonatomic,assign) BOOL isSelected;

@end
