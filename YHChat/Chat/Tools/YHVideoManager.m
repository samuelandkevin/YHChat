//
//  YHVideoManager.m
//  YHChat
//
//  Created by samuelandkevin on 17/3/2.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "YHVideoManager.h"
#import <AVFoundation/AVFoundation.h>


#define kVideoType @".mp4"        // video类型
#define kChatVideoPath @"Chat/Video"  // video子路径

@interface YHVideoManager()<AVCaptureFileOutputRecordingDelegate>

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureMovieFileOutput *captureMovieOutput;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *preLayer;
@property (nonatomic, copy)   RecordingFinished finished;

@end

@implementation YHVideoManager

+ (instancetype)shareInstanced{
    static YHVideoManager *g_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_instance = [[YHVideoManager alloc] init];
    });
    return g_instance;
}


- (void)setVideoPreviewLayer:(UIView *)videoLayerView
{
    // 创建会话
    [self session];
    // 创建视频设备
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *inputVideo = [AVCaptureDeviceInput deviceInputWithDevice:[devices firstObject] error:nil];
    if (!inputVideo) {
        DDLog(@"deviceInput wrong!");
        return;
    }
    // 创建麦克风设备
    AVCaptureDevice *deviceAudio = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    // 摄像头输入输出流
    AVCaptureDeviceInput *inputAudio = [AVCaptureDeviceInput deviceInputWithDevice:deviceAudio error:nil];
    _session.sessionPreset = AVCaptureSessionPreset640x480;
    // 将输入输出设备添加到会话中
    if ([_session canAddInput:inputVideo]) {
        [_session addInput:inputVideo];
    }
    if ([_session canAddInput:inputAudio]) {
        [_session addInput:inputAudio];
    }
    if ([_session canAddOutput:self.captureMovieOutput]) {
        [_session addOutput:self.captureMovieOutput];
    }
    AVCaptureVideoPreviewLayer *preLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    preLayer.videoGravity = AVLayerVideoGravityResizeAspectFill; // 填充
    //    preLayer.videoGravity = AVLayerVideoGravityResize; // 按可见区域大小录制视频
    preLayer.frame = videoLayerView.bounds;
    
    videoLayerView.layer.masksToBounds = YES;
    [videoLayerView layoutIfNeeded];
    [videoLayerView.layer addSublayer:preLayer];
    _preLayer = preLayer;
    [_session startRunning];
}

- (BOOL)canRecordViedo
{
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        return NO;
    } else {
        return YES;
    }
}

- (void)stopRecordingVideo:(RecordingFinished)finished
{
    _finished = finished;
    [_captureMovieOutput stopRecording];
}

// cancel recording
- (void)cancelRecordingVideoWithFileName:(NSString *)videoName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *videoPath = [self videoPathWithFileName:videoName];
    if (!videoPath) return;
    BOOL isRemoveSucceed = [fileManager removeItemAtPath:videoPath error:nil];
    if (isRemoveSucceed) {
        DDLog(@"remove succeed!");
    }
}


#pragma mark - Private Method

- (NSString *)videoPathWithFileName:(NSString *)videoName fileDir:(NSString *)fileDir {
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:fileDir];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirExist = [fileManager fileExistsAtPath:path];
    if (!isDirExist) {
        BOOL isCreatDir = [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        if (!isCreatDir) {
            DDLog(@"create folder failed");
            return nil;
        }
    }
    return [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@",videoName,kVideoType]];
}

// video的路径
- (NSString *)videoPathWithFileName:(NSString *)videoName
{
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:kChatVideoPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirExist = [fileManager fileExistsAtPath:path];
    if (!isDirExist) {
        BOOL isCreatDir = [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        if (!isCreatDir) {
            DDLog(@"create folder failed");
            return nil;
        }
    }
    return [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@",videoName,kVideoType]];
}

- (NSString *)videoPathForMP4:(NSString *)namePath
{
    NSString *videoPath   = [[YHVideoManager shareInstanced] videoPathWithFileName:[[namePath lastPathComponent] stringByDeletingPathExtension]];
    NSString *mp4Path     = [[videoPath stringByDeletingPathExtension] stringByAppendingPathExtension:@"mp4"];
    return mp4Path;
}





// 接收到的视频保存路径(文件以fileKey为名字)
- (NSString *)receiveVideoPathWithFileKey:(NSString *)fileKey
{
    return [self videoPathWithFileName:fileKey];
}

- (NSURL *)convertMp4:(NSURL *)movUrl {
    NSURL *mp4Url = nil;
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:movUrl options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    
    if ([compatiblePresets containsObject:AVAssetExportPresetHighestQuality]) {
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset
                                                                              presetName:AVAssetExportPresetHighestQuality];
        mp4Url = [movUrl copy];
        mp4Url = [mp4Url URLByDeletingPathExtension];
        mp4Url = [mp4Url URLByAppendingPathExtension:@"mp4"];
        exportSession.outputURL = mp4Url;
        exportSession.shouldOptimizeForNetworkUse = YES;
        exportSession.outputFileType = AVFileTypeMPEG4;
        dispatch_semaphore_t wait = dispatch_semaphore_create(0l);
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            switch ([exportSession status]) {
                case AVAssetExportSessionStatusFailed: {
                    DDLog(@"failed, error:%@.", exportSession.error);
                } break;
                case AVAssetExportSessionStatusCancelled: {
                    DDLog(@"cancelled.");
                } break;
                case AVAssetExportSessionStatusCompleted: {
                    DDLog(@"completed.");
                } break;
                default: {
                    DDLog(@"others.");
                } break;
            }
            dispatch_semaphore_signal(wait);
        }];
        long timeout = dispatch_semaphore_wait(wait, DISPATCH_TIME_FOREVER);
        if (timeout) {
            DDLog(@"timeout.");
        }
        if (wait) {
            wait = nil;
        }
    }
    
    return mp4Url;
}


#pragma mark - Getter

- (AVCaptureSession *)session
{
    if (!_session) {
        _session = [[AVCaptureSession alloc] init];
    }
    return _session;
}

- (AVCaptureMovieFileOutput *)captureMovieOutput
{
    if (!_captureMovieOutput) {
        _captureMovieOutput = [[AVCaptureMovieFileOutput alloc] init];
    }
    return _captureMovieOutput;
}

@end
