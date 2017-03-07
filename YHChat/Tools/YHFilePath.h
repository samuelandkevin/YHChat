//
//  YHFilePath.h
//  YHSOFT
//
//  Created by samuelandkevin on 16/9/17.
//  Copyright (c) 2016年 samuelandkevin Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YHFilePath : NSObject

+ (NSString *)getAppSupportDataDirectory;
+ (NSString *)getAppCacheDirectory;
+ (NSString *)getTempDataCacheDirectory;
+ (NSString *)getDataCacheDirectory;
+ (NSArray *)GetFilesListAtPath:(NSString *)dirPath withType:(NSString *)type;
+ (NSString *)getWebrootDirectory;

@end
