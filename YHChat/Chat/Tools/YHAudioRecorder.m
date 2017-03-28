//
//  YHAudioRecorder.m
//  YHChat
//
//  Created by samuelandkevin on 17/3/2.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "YHAudioRecorder.h"
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import "HHUtils.h"
#import "YHFileTool.h"
#import "VoiceConverter.h"


#define kChildPath   @"Chat/Recorder"
#define kRecoderType @".wav"
#define kAmrType @"amr"
#define kMinRecordDuration 1.0 //最短录音时长


@interface YHAudioRecorder()<AVAudioRecorderDelegate,AVAudioPlayerDelegate>{
    NSDate *_startRecordDate;
    NSDate *_endRecordDate;
    void (^recordFinish)(NSString *recordPath);
    void (^recordPower)(float progress);
}

@property (nonatomic,strong) AVAudioRecorder *audioRecorder;
@property (nonatomic,strong) AVAudioPlayer *audioPlayer;
@property (nonatomic,strong) NSTimer *timerUpdateMeters;
@property (nonatomic,copy)   NSString *recordFileName;

@end



@implementation YHAudioRecorder

+ (instancetype)shareInstanced{
    static YHAudioRecorder *g_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_instance = [[YHAudioRecorder alloc] init];
    });
    return g_instance;
}


- (BOOL)canRecord
{
    __block BOOL bCanRecord = YES;
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending)
    {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
            [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
                bCanRecord = granted;
            }];
        }
    }
    return bCanRecord;
}


#pragma mark - Private



#pragma mark - Lazy Load
/**
 *  取得录音文件设置
 *
 *  @return 录音设置
 */
- (NSDictionary *)getAudioSetting{
    NSMutableDictionary *dicM = [NSMutableDictionary dictionary];
    //设置录音格式
    [dicM setObject:@(kAudioFormatLinearPCM) forKey:AVFormatIDKey];
    //设置录音采样率，8000是电话采样率，对于一般录音已经够了
    [dicM setObject:@(8000) forKey:AVSampleRateKey];
    //设置通道,这里采用单声道
    [dicM setObject:@(1) forKey:AVNumberOfChannelsKey];
    //每个采样点位数,分为8、16、24、32
    [dicM setObject:@(8) forKey:AVLinearPCMBitDepthKey];
    //是否使用浮点数采样
    [dicM setObject:@(YES) forKey:AVLinearPCMIsFloatKey];
    //....其他设置等
    return dicM;
}

- (NSTimer *)timerUpdateMeters{
    if (!_timerUpdateMeters) {
        _timerUpdateMeters = [NSTimer scheduledTimerWithTimeInterval:0.3f target:self selector:@selector(powerChange) userInfo:nil repeats:YES];
    }
    return _timerUpdateMeters;
}

- (void)powerChange{
    [_audioRecorder updateMeters];
    float power= [_audioRecorder averagePowerForChannel:0];//取得第一个通道的音频，注意音频强度范围时-160到0,声音越大power绝对值越小
    CGFloat progress = (1.0/160)*(power + 160);
    if (recordPower) {
        recordPower(progress);
    }
    DDLog(@"语音功率:%f",progress);
}


#pragma mark -


#pragma mark - 录音文件
// 录音文件主路径
- (NSString *)recorderMainPath
{
    NSString *path = [[YHFileTool getAppCacheDirectory] stringByAppendingPathComponent:kChildPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirExist = [fileManager fileExistsAtPath:path];
    if (!isDirExist) {
        BOOL isCreatDir = [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        if (!isCreatDir) {
            DDLog(@"create folder failed");
            return nil;
        }
    }
    return path;
}

// fileName的录音文件路径
- (NSString *)recorderPathWithFileName:(NSString *)fileName
{
    NSString *mainPath = [self recorderMainPath];
    return [mainPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@",fileName,kRecoderType]];
}

#pragma mark - Public Method
// start recording
- (void)startRecordingWithFileName:(NSString *)fileName
                        completion:(void(^)(NSError *error))completion
                        power:(void(^)(float progress))power{
    self.curRecordFileName = fileName;
    recordPower = power;
    NSError *error = nil;
    if (![self canRecord]) {
    
        [HHUtils showAlertWithTitle:@"无法录音" message:@"请在iPhone的“设置-隐私-麦克风”选项中，允许iCom访问你的手机麦克风。" okTitle:@"确定" cancelTitle:nil dismiss:^(BOOL resultYes) {
        }];
        
        if (completion) {
            error = [NSError errorWithDomain:NSLocalizedString(@"error", @"没权限") code:122 userInfo:nil];
            completion(error);
            if (recordPower) {
                recordPower(0);
            }
        }
        return;
    }else{
        [self timerUpdateMeters];
        
        //0.取消当前的录制
        if ([_audioRecorder isRecording]){
            [_audioRecorder stop];
            [self cancelCurrentRecording];
            return;
        }
        
        //1.设置策略
        NSError *errorCategory = nil;
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&errorCategory];
        if(errorCategory){
            DDLog(@"%@", [errorCategory description]);
        }
        
        //2.初始化录音设备
        NSURL *url = [[NSURL alloc] initFileURLWithPath:[self recorderPathWithFileName:fileName]];
        NSDictionary *settings = [self getAudioSetting];
        _audioRecorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
        _audioRecorder.delegate = self;
        _audioRecorder.meteringEnabled = YES;//如果要监控声波则必须设置为YES
        if (!_audioRecorder || error) {
            _audioRecorder = nil;
            if (completion) {
                error = [NSError errorWithDomain:NSLocalizedString(@"error.initRecorderFail", @"Failed to initialize AVAudioRecorder") code:123 userInfo:nil];
                completion(error);
                if (recordPower) {
                    recordPower(0);
                }
                
            }
            return;
        }
        _startRecordDate = [NSDate date];
        [_audioRecorder prepareToRecord];
        [_audioRecorder record];
        
        if (completion) {
            completion(error);
        }

    }

}

// stop  recording
- (void)stopRecordingWithCompletion:(void(^)(NSString *recordPath))completion
{
    
    //关闭定时器
    [self.timerUpdateMeters invalidate];
    _timerUpdateMeters = nil;
    
    _endRecordDate = [NSDate date];
    NSTimeInterval recordTimeInterval = [_endRecordDate timeIntervalSinceDate:_startRecordDate];
    if ([_audioRecorder isRecording]) {
        if (recordTimeInterval < kMinRecordDuration) {
            if (completion) {
                completion(shortRecord);
            }
            if (recordPower){
                recordPower(0);
            }
         
            [self cancelCurrentRecording];
            [self removeCurrentRecordFile];
            DDLog(@"record time duration is too short");
            return;
        }
        recordFinish = completion;

        WeakSelf
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [weakSelf.audioRecorder stop];
            DDLog(@"record time duration :%f", recordTimeInterval);
        });
        
        
    }
    
}

// pause UpdateMeters
- (void)pauseUpdateMeters{
    [self.timerUpdateMeters setFireDate:[NSDate distantFuture]];
    if (recordPower) {
        recordPower(0);
    }
}

// resume UpdateMeters
- (void)resumeUpdateMeters{
    [self.timerUpdateMeters setFireDate:[NSDate distantPast]];
}

/**
 取消当前录制
 */
- (void)cancelCurrentRecording
{
    _audioRecorder.delegate = nil;
    if (_audioRecorder.recording) {
        [_audioRecorder stop];
    }
    _audioRecorder = nil;
    recordFinish = nil;
}

// 移除录音文件
- (void)removeCurrentRecordFile{
    [self removeCurrentRecordFile:self.curRecordFileName];
}

// 移除录音文件
- (void)removeCurrentRecordFile:(NSString *)fileName
{
    [self cancelCurrentRecording];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = [self recorderPathWithFileName:fileName];
    BOOL isDirExist = [fileManager fileExistsAtPath:path];
    if (isDirExist) {
        [fileManager removeItemAtPath:path error:nil];
    }
}



- (void)startPlayRecorder:(NSString *)recorderPath
{

    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *err = nil;  // 加上这两句，否则声音会很小
    [audioSession setCategory :AVAudioSessionCategoryPlayback error:&err];
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:recorderPath] error:nil];
    self.audioPlayer.numberOfLoops = 0;
    [self.audioPlayer prepareToPlay];
    self.audioPlayer.delegate = self;
    [self.audioPlayer play];
}

- (void)stopPlayRecorder:(NSString *)recorderPath
{
    [self.audioPlayer stop];
    self.audioPlayer = nil;
    self.audioPlayer.delegate = nil;
}

- (void)pause
{
    [self.audioPlayer pause];
}


// 获取语音时长
- (NSUInteger)durationWithVoiceUrl:(NSURL *)voiceUrl{
    
    NSDictionary *opts = [NSDictionary dictionaryWithObject:@(NO) forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:voiceUrl options:opts]; // 初始化视频媒体文件
    NSUInteger second = 0;
    second = urlAsset.duration.value / urlAsset.duration.timescale; // 获取视频总时长,单位秒
    return second;
}


#pragma mark - 录音机代理方法
/**
 *  录音完成，录音完成后播放录音
 *
 *  @param recorder 录音机对象
 *  @param flag     是否成功
 */

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder
                           successfully:(BOOL)flag{
    if (![self.audioRecorder isRecording]) {
        [self.audioRecorder stop];
    }
    DDLog(@"录音完成!");
    
    NSString *recordPath = [[_audioRecorder url] path];
//    // 音频格式转换
//    NSString *amrPath = [[recordPath stringByDeletingPathExtension] stringByAppendingPathExtension:kAmrType];
//    [VoiceConverter ConvertWavToAmr:recordPath amrSavePath:amrPath];
    if (recordFinish) {
        if (!flag) {
            recordPath = nil;
        }
        recordFinish(recordPath);
    }
    _audioRecorder = nil;
    recordFinish   = nil;
    
//    //移除.wav原文件
//    [self removeCurrentRecordFile:self.curRecordFileName];
    
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder
                                   error:(NSError *)error
{
    DDLog(@"audioRecorderEncodeErrorDidOccur");
}


#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player
                       successfully:(BOOL)flag
{
    [self.audioPlayer stop];
    self.audioPlayer = nil;
   
}

@end
