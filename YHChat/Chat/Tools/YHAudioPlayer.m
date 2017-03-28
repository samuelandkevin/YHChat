//
//  YHAudioPlayer.m
//  YHChat
//
//  Created by samuelandkevin on 17/3/2.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "YHAudioPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import "YHDownLoadManager.h"
#import "VoiceConverter.h"

@interface YHAudioPlayer()<AVAudioPlayerDelegate>
@property (nonatomic,strong) AVAudioPlayer *player;
@property (nonatomic,copy) void(^progress)(float progress);
@end

@implementation YHAudioPlayer

+ (instancetype)shareInstanced{
    static YHAudioPlayer *g_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_instance = [[YHAudioPlayer alloc] init];
    });
    return g_instance;
}

- (void)playWithUrlString:(NSString *)url progress:(void(^)(float progress))progress{
    self.progress = progress;
    
    //播放本地音频
    if([url hasPrefix:@"local://"]){
        NSString *path = [url stringByReplacingOccurrencesOfString:@"local://" withString:@""];
        [self _fristPlayWithResourcePath:path];
        return;
    }
    
    //播放流媒体
    WeakSelf
    [[YHDownLoadManager sharedInstance] downLoadAudioWithRequestUrl:url complete:^(BOOL success, id obj) {
        if (success) {
            DDLog(@"%@",obj);
            [weakSelf _fristPlayWithResourcePath:obj];
     
        }else{
            DDLog(@"%@",obj);
            
        }
    } progress:^(int64_t bytesWritten, int64_t totalBytesWritten) {
        
    }];

    
}

- (void)_fristPlayWithResourcePath:(NSString *)resourcePath{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSURL *aUrl = [NSURL URLWithString:resourcePath];
        NSError *error = nil;
        //初始化播放器，注意这里的Url参数只能时文件路径，不支持HTTP Url
        self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:aUrl error:&error];
        //设置播放器属性
        _player.numberOfLoops=0;//设置为0不循环
        _player.delegate = self;
        [_player prepareToPlay];//加载音频文件到缓存
        if(error){
            DDLog(@"初始化播放器过程发生错误,错误信息:%@",error.localizedDescription);
            if (self.progress) {
                self.progress(0);
            }
        }
        [self play];
    });
}


- (BOOL)isPlaying{
    return [_player isPlaying];
}

- (void)play{
    if (![_player isPlaying]) {
        [_player play];
    }
}

- (void)pause{
    if ([_player isPlaying]) {
        [_player pause];
    }
}


#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    DDLog(@"audioPlayerDidFinishPlaying");
    [self pause];
    _player = nil;
    if (self.progress) {
        self.progress(1);
    }
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError * __nullable)error{
    DDLog(@"audioPlayerDecodeErrorDidOccur");
    if (self.progress) {
        self.progress(0);
    }
}



@end
