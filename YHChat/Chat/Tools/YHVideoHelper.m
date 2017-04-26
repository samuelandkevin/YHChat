//
//  YHVideoHelper.m
//  YHChat
//
//  Created by samuelandkevin on 17/3/2.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "YHVideoHelper.h"


#define kVideoType @".mp4"            // video类型
#define kChatVideoPath @"Chat/Video"  // video子路径
typedef void(^PropertyChangeBlock)(AVCaptureDevice *captureDevice);

@interface YHVideoHelper()<AVCaptureFileOutputRecordingDelegate>

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDeviceInput *inputVideo;
@property (nonatomic, strong) AVCaptureDeviceInput *inputAudio;
@property (nonatomic, strong) AVCaptureMovieFileOutput *captureMovieOutput;
@property (nonatomic, strong) AVCaptureStillImageOutput *captureStillImageOutput;  //照片输出流
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *preLayer;
@property (nonatomic, copy)   RecordingFinished finished;
@property (nonatomic, copy)   PhotoFinished photoBlock;
@end

@implementation YHVideoHelper

+ (instancetype)shareInstanced{
    static YHVideoHelper *g_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_instance = [[self alloc] init];
    });
    return g_instance;
}


- (void)setVideoView:(__weak UIView *)videoView{
    // 1.创建会话
    [self session];

    
    // 2.创建输入设备
    // 创建视频设备
    AVCaptureDevice *deviceVideo = [self getCameraDeviceWithPosition:AVCaptureDevicePositionBack];//取得后置摄像头
    if (!deviceVideo) {
        DDLog(@"取得后置摄像头时出现问题.");
        return ;
    }

    // 创建麦克风设备
    AVCaptureDevice *deviceAudio = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    
    // 3.创建输入输出流
    NSError *error = nil;
    //根据输入设备初始化设备输入对象，用于获得输入数据
    _inputVideo = [[AVCaptureDeviceInput alloc] initWithDevice:deviceVideo error:&error];
    if (error) {
        DDLog(@"取得设备输入对象时出错，错误原因：%@",error.localizedDescription);
        return;
    }
    
    _inputAudio = [AVCaptureDeviceInput deviceInputWithDevice:deviceAudio error:nil];
    if([_session canSetSessionPreset:AVCaptureSessionPreset1280x720]){
        _session.sessionPreset = AVCaptureSessionPreset1280x720;
    }else if([_session canSetSessionPreset:AVCaptureSessionPreset640x480]){
        _session.sessionPreset = AVCaptureSessionPreset640x480;
    }
    
    [self captureMovieOutput];
    [self captureStillImageOutput];
    

    // 4.将输入输出设备添加到会话中
    if ([_session canAddInput:_inputVideo]) {
        [_session addInput:_inputVideo];
    }
    if ([_session canAddInput:_inputAudio]) {
        [_session addInput:_inputAudio];
    }
    if ([_session canAddOutput:_captureMovieOutput]) {
        [_session addOutput:_captureMovieOutput];
    }
    if ([_session canAddOutput:_captureStillImageOutput]) {
        [_session addOutput:_captureStillImageOutput];
    }
    
    // 5.显示视频图层
    AVCaptureVideoPreviewLayer *preLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    preLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    preLayer.frame        = videoView.bounds;
    [videoView.layer addSublayer:preLayer];
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

// begin recording
- (void)startRecordingVideoWithFileName:(NSString *)videoName
{
    AVCaptureConnection *connection = [_captureMovieOutput connectionWithMediaType:AVMediaTypeVideo];
    // 预览图层和视频方向保持一致
    connection.videoOrientation = [_preLayer connection].videoOrientation;
    if (!connection) {
        DDLog(@"capture connection wrong!");
        return;
    }
    NSString *videoPath = [self videoPathWithFileName:videoName];
    NSURL *urlPath = [NSURL fileURLWithPath:videoPath];
    [_captureMovieOutput startRecordingToOutputFileURL:urlPath recordingDelegate:self];
}

// stop recording
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

// take photo
- (void)takePhoto:(PhotoFinished)complete{
    
    _photoBlock = complete;
    
    WeakSelf
    //根据设备输出获得连接
    AVCaptureConnection *connection = [_captureStillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    if (!connection) {
        DDLog(@"connection is wrong");
        complete(NO,@"connection is wrong");
        return;
    }
    
    //根据连接取得设备输出的数据
    [_captureStillImageOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (!error) {
            
            if (imageDataSampleBuffer) {
                NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                UIImage *image = [UIImage imageWithData:imageData];
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
                if (weakSelf.photoBlock) {
                    weakSelf.photoBlock(YES,image);
                }
            }else{
                if (weakSelf.photoBlock) {
                    weakSelf.photoBlock(NO,@"no imageDataSampleBuffer");
                }
            }
            
        }else{
            if (weakSelf.photoBlock) {
                weakSelf.photoBlock(NO,error.localizedDescription);
            }
        }
        
    }];
}


- (void)exit
{
    [_session removeInput:_inputAudio];
    [_session removeInput:_inputVideo];
    [_session removeOutput:_captureMovieOutput];
    [_session removeOutput:_captureStillImageOutput];
    [_session stopRunning];
}


//切换摄像头方向
- (void)changeCameraDevicePosition{
    
    AVCaptureDevice *currentDevice = [_inputVideo device];
    AVCaptureDevicePosition currentPosition = [currentDevice position];
    [self removeNotificationFromCaptureDevice:currentDevice];
    AVCaptureDevice *toChangeDevice;
    AVCaptureDevicePosition toChangePosition =
    currentPosition == AVCaptureDevicePositionFront ? AVCaptureDevicePositionBack : AVCaptureDevicePositionFront;
   
    
    toChangeDevice = [self getCameraDeviceWithPosition:toChangePosition];
    [self addNotificationToCaptureDevice:toChangeDevice];
    
    
    //获得要调整的设备输入对象
    NSError *error = nil;
    AVCaptureDeviceInput *toChangeDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:toChangeDevice error:&error];
    if (error) {
        DDLog(@"%@",error.localizedDescription);
        return;
    }
    
    //改变会话的配置前一定要先开启配置，配置完成后提交配置改变
    [self.session beginConfiguration];
    
    //移除原有输入对象
    [self.session removeInput:_inputVideo];
 
    //添加新的输入对象
    if ([self.session canAddInput:toChangeDeviceInput]) {
        [self.session addInput:toChangeDeviceInput];
        _inputVideo = toChangeDeviceInput;
    }
    
    //提交会话配置
    [self.session commitConfiguration];
    
    [self setFlashModeButtonStatus];
}

//设置焦点
- (void)setFoucsWithPoint:(CGPoint)point{
    
    //将UI坐标转化为摄像头坐标
    CGPoint cameraPoint = [self.preLayer captureDevicePointOfInterestForPoint:point];
    [self focusWithMode:AVCaptureFocusModeAutoFocus exposureMode:AVCaptureExposureModeAutoExpose atPoint:cameraPoint];
}

#pragma mark - Private Method 录制视频

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
    NSString *videoPath   = [self videoPathWithFileName:[[namePath lastPathComponent] stringByDeletingPathExtension]];
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


// file size
- (CGFloat)getFileSize:(NSString *)path
{
    NSDictionary *outputFileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
    CGFloat fileSize = [outputFileAttributes fileSize]/1024.0/1024.0;
    DDLog(@"file size : %f",fileSize);
    return fileSize;
}


// compress video
- (NSString *)compressVideo:(NSString *)path finished:(RecordingFinished)finish
{
    NSURL *url = [NSURL fileURLWithPath:path];
    // 获取文件资源
    AVURLAsset *avAsset = [[AVURLAsset alloc] initWithURL:url options:nil];
    // 导出资源属性
    NSArray *presets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    // 是否包含中分辨率，如果是低分辨率AVAssetExportPresetLowQuality则不清晰
    if ([presets containsObject:AVAssetExportPresetMediumQuality]) {
        // 重定义资源属性
        
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPresetHighestQuality];
        // 压缩后的文件路径
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-ddHH:mm:ss"];
        NSString *videoName = [formatter stringFromDate:[NSDate date]];
        NSString *outPutPath = [self videoPathWithFileName:videoName];
        exportSession.outputURL = [NSURL fileURLWithPath:outPutPath];
        exportSession.shouldOptimizeForNetworkUse = YES;// 是否对网络进行优化
        exportSession.outputFileType = AVFileTypeMPEG4; // 转成MP4
        // 导出
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            if ([exportSession status] == AVAssetExportSessionStatusCompleted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self getFileSize:outPutPath];
                    // 这里完成了压缩
                    if (finish) finish(outPutPath);
                    
                });
            }
        }];
        return outPutPath;
    }
    return nil;
}


#pragma mark - Private Method 摄像头
/**
 *  取得指定位置的摄像头
 *
 *  @param position 摄像头位置
 *
 *  @return 摄像头设备
 */
- (AVCaptureDevice *)getCameraDeviceWithPosition:(AVCaptureDevicePosition)position{
    NSArray *cameras= [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *camera in cameras) {
        if ([camera position] == position) {
            return camera;
        }
    }
    return nil;
}


/**
 *  改变设备属性的统一操作方法
 *
 *  @param propertyChange 属性改变操作
 */
- (void)changeDeviceProperty:(PropertyChangeBlock)propertyChange{
    AVCaptureDevice *captureDevice= [self.inputVideo device];
    NSError *error;
    //注意改变设备属性前一定要首先调用lockForConfiguration:调用完之后使用unlockForConfiguration方法解锁
    if ([captureDevice lockForConfiguration:&error]) {
        propertyChange(captureDevice);
        [captureDevice unlockForConfiguration];
    }else{
        DDLog(@"设置设备属性过程发生错误，错误信息：%@",error.localizedDescription);
    }
}

/**
 *  设置闪光灯模式
 *
 *  @param flashMode 闪光灯模式
 */
-(void)setFlashMode:(AVCaptureFlashMode )flashMode{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isFlashModeSupported:flashMode]) {
            [captureDevice setFlashMode:flashMode];
        }
    }];
}
/**
 *  设置聚焦模式
 *
 *  @param focusMode 聚焦模式
 */
-(void)setFocusMode:(AVCaptureFocusMode )focusMode{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isFocusModeSupported:focusMode]) {
            [captureDevice setFocusMode:focusMode];
        }
    }];
}
/**
 *  设置曝光模式
 *
 *  @param exposureMode 曝光模式
 */
-(void)setExposureMode:(AVCaptureExposureMode)exposureMode{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isExposureModeSupported:exposureMode]) {
            [captureDevice setExposureMode:exposureMode];
        }
    }];
}
/**
 *  设置聚焦点
 *
 *  @param point 聚焦点
 */
-(void)focusWithMode:(AVCaptureFocusMode)focusMode exposureMode:(AVCaptureExposureMode)exposureMode atPoint:(CGPoint)point{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isFocusModeSupported:focusMode]) {
            [captureDevice setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        if ([captureDevice isFocusPointOfInterestSupported]) {
            [captureDevice setFocusPointOfInterest:point];
        }
        if ([captureDevice isExposureModeSupported:exposureMode]) {
            [captureDevice setExposureMode:AVCaptureExposureModeAutoExpose];
        }
        if ([captureDevice isExposurePointOfInterestSupported]) {
            [captureDevice setExposurePointOfInterest:point];
        }
    }];
}



/**
 *  设置闪光灯按钮状态
 */
-(void)setFlashModeButtonStatus{
    AVCaptureDevice *captureDevice = [self.inputVideo device];
    AVCaptureFlashMode flashMode=captureDevice.flashMode;
    if([captureDevice isFlashAvailable]){
//        self.flashAutoButton.hidden = NO;
//        self.flashOnButton.hidden   = NO;
//        self.flashOffButton.hidden  = NO;
//        self.flashAutoButton.enabled= YES;
//        self.flashOnButton.enabled=YES;
//        self.flashOffButton.enabled=YES;
        switch (flashMode) {
            case AVCaptureFlashModeAuto:
//                self.flashAutoButton.enabled=NO;
                break;
            case AVCaptureFlashModeOn:
//                self.flashOnButton.enabled=NO;
                break;
            case AVCaptureFlashModeOff:
//                self.flashOffButton.enabled=NO;
                break;
            default:
                break;
        }
    }else{
//        self.flashAutoButton.hidden=YES;
//        self.flashOnButton.hidden=YES;
//        self.flashOffButton.hidden=YES;
    }
}


#pragma mark - 通知
/**
 *  给输入设备添加通知
 */
- (void)addNotificationToCaptureDevice:(AVCaptureDevice *)captureDevice{
    //注意添加区域改变捕获通知必须首先设置设备允许捕获
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        captureDevice.subjectAreaChangeMonitoringEnabled=YES;
    }];
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    //捕获区域发生改变
    [notificationCenter addObserver:self selector:@selector(areaChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:captureDevice];
}

- (void)removeNotificationFromCaptureDevice:(AVCaptureDevice *)captureDevice{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:captureDevice];
}

/**
 *  移除所有通知
 */
- (void)removeNotification{
    NSNotificationCenter *notificationCenter= [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self];
}

- (void)addNotificationToCaptureSession:(AVCaptureSession *)captureSession{
    NSNotificationCenter *notificationCenter= [NSNotificationCenter defaultCenter];
    //会话出错
    [notificationCenter addObserver:self selector:@selector(sessionRuntimeError:) name:AVCaptureSessionRuntimeErrorNotification object:captureSession];
}

/**
 *  设备连接成功
 *
 *  @param notification 通知对象
 */
-(void)deviceConnected:(NSNotification *)notification{
    DDLog(@"设备已连接...");
}

/**
 *  设备连接断开
 *
 *  @param notification 通知对象
 */
-(void)deviceDisconnected:(NSNotification *)notification{
    DDLog(@"设备已断开.");
}
/**
 *  捕获区域改变
 *
 *  @param notification 通知对象
 */
-(void)areaChange:(NSNotification *)notification{
    DDLog(@"捕获区域改变...");
}

/**
 *  会话出错
 *
 *  @param notification 通知对象
 */
-(void)sessionRuntimeError:(NSNotification *)notification{
    DDLog(@"会话发生错误.");
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

- (AVCaptureStillImageOutput *)captureStillImageOutput{
    if (!_captureStillImageOutput) {
        _captureStillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        NSDictionary *outputSettings = @{AVVideoCodecKey:AVVideoCodecJPEG};
        [_captureStillImageOutput setOutputSettings:outputSettings];//输出设置
    }
    return _captureStillImageOutput;
}

#pragma mark - AVCaptureFileOutputRecordingDelegate

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections
{
    
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    if ([self getFileSize:[outputFileURL path]] == 0.0) {
        return;
    }
    // 转换
    NSURL *mp4Url = [self convertMp4:outputFileURL];
    [self getFileSize:[mp4Url path]];
    [self compressVideo:[mp4Url path] finished:^(NSString *path) {
        if (path) {
            _finished(path);
        }
        // 删除原录制的文件
        if ([[NSFileManager defaultManager] fileExistsAtPath:outputFileURL.path]) {
            [[NSFileManager defaultManager] removeItemAtPath:outputFileURL.path error:nil];
        }
    }];
    // 直接转大小不会改变
    //    [self getFileSize:filePath];
    //    _finished([mp4Url path]);
}


@end
