//
//  YHAudioPlayer.h
//  YHChat
//
//  Created by YHIOS002 on 17/3/2.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YHAudioPlayer : NSObject
+ (instancetype)shareInstanced;
//播放url
- (void)playWithUrlString:(NSString *)url;
//播放url结束
- (void)playFinishWithUrlString:(NSString *)url complete:(void(^)(BOOL finish))complete;
@end
