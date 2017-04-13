//
//  YHFileTool.h
//  YHSOFT
//
//  Created by samuelandkevin on 16/9/17.
//  Copyright (c) 2016年 samuelandkevin Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface YHFileTool : NSObject

+ (NSString *)getAppSupportDataDirectory;
+ (NSString *)getAppCacheDirectory;
+ (NSString *)getTempDataCacheDirectory;
+ (NSString *)getDataCacheDirectory;
+ (NSArray *)GetFilesListAtPath:(NSString *)dirPath withType:(NSString *)type;
+ (NSString *)getWebrootDirectory;

// 文件主目录
+ (NSString *)fileMainPath;
// 文件大小
+ (NSString *)filesize:(NSString *)path;
+ (CGFloat)fileSizeWithPath:(NSString *)path;
+ (BOOL)fileExistsAtPath:(NSString *)path;
+ (BOOL)removeFileAtPath:(NSString *)path;
@end
