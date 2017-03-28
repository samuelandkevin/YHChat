//
//  YHUploadManager.h
//  samuelandkevin
//
//  Created by samuelandkevin on 17/1/12.
//  Copyright © 2017年 YHSoft. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface YHUploadManager : NSObject


+ (YHUploadManager*)sharedInstance;

/*
 *  上传聊天语音
 *  @param recordPath       后台返回的Url
 *  @param progress         上传进度
 *  @param complete         成功失败回调
 */
- (void)uploadChatRecordWithPath:(NSString *)recordPath complete:(void (^)(BOOL success,id obj))complete progress:(void(^)(int64_t bytesWritten, int64_t totalBytesWritten))progress;

/*
 *  上传办公格式的文件        （PDF,Word,Excel）
 *  @param filePath         后台返回的Url
 *  @param progress         上传进度
 *  @param complete         成功失败回调
 */
- (void)uploadOfficeFileWithPath:(NSString *)filePath complete:(void (^)(BOOL success,id obj))complete progress:(void(^)(int64_t bytesWritten, int64_t totalBytesWritten))progress;

@end
