//
//  YHVideoManager.h
//  YHChat
//
//  Created by samuelandkevin on 17/3/2.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^RecordingFinished)(NSString *path);

@interface YHVideoManager : NSObject

+ (instancetype)shareInstanced;

- (void)setVideoPreviewLayer:(UIView *)videoLayerView;
- (BOOL)canRecordViedo;
- (void)startRecordingVideoWithFileName:(NSString *)videoName;
- (void)cancelRecordingVideoWithFileName:(NSString *)videoName;
- (void)stopRecordingVideo:(RecordingFinished)finished;

- (void)exit;


@end
