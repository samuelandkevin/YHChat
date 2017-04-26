//
//  YHVideoHelper.h
//  YHChat
//
//  Created by samuelandkevin on 17/3/2.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//  摄像工具

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

typedef void(^RecordingFinished)(NSString *path);
typedef void(^PhotoFinished)(BOOL success,id obj);

@interface YHVideoHelper : NSObject

+ (instancetype)shareInstanced;

- (void)setVideoView:(__weak UIView *)videoView;//设置展示视频的view
- (BOOL)canRecordViedo; //可以录视频
- (void)startRecordingVideoWithFileName:(NSString *)videoName;//开始录视频
- (void)cancelRecordingVideoWithFileName:(NSString *)videoName;//取消录视频
- (void)stopRecordingVideo:(RecordingFinished)finished;//结束录视频
- (void)takePhoto:(PhotoFinished)complete;//拍照
- (void)exit;//退出

- (void)changeCameraDevicePosition;//切换摄像头方向
- (void)setFoucsWithPoint:(CGPoint)point;//设置焦点
@end
