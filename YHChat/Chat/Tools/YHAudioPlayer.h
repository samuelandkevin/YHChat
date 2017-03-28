//
//  YHAudioPlayer.h
//  YHChat
//
//  Created by samuelandkevin on 17/3/2.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YHAudioPlayer : NSObject

/**
 单例

 @return YHAudioPlayer
 */
+ (instancetype)shareInstanced;

/**
 播放音频

 @param url 路径字符串
 @param progress 进度（0-1）1:代表播放完成
 */
- (void)playWithUrlString:(NSString *)url progress:(void(^)(float progress))progress;

@end
