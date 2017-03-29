//
//  YHDownLoadManager.m
//  samuelandkevin
//
//  Created by samuelandkevin on 17/1/12.
//  Copyright © 2017年 YHSoft. All rights reserved.
//

#import "YHDownLoadManager.h"
#import "NetManager.h"
#import "YHSqilteConfig.h"

#define kDownloadAudioMAXCount 3      //下载音频数量限制
#define kDownloadOfficeFileMAXCount 3 //下载办公格式文件数量限制

@interface YHDownLoadModel : NSObject

@property (nonatomic,copy) NSString *filePath;
@property (nonatomic,copy) void (^complete)(BOOL success,id obj);
@property (nonatomic,copy) void (^progress)(int64_t bytesWritten, int64_t totalBytesWritten);
@property (nonatomic,assign) BOOL isDownLoading;

@end

@implementation YHDownLoadModel

@end


@interface YHDownLoadManager()
@property (nonatomic,strong)NSMutableArray *downLoadAudioQueue;
@property (nonatomic,strong)NSMutableArray *downLoadOfficeFileQueue;
@end

@implementation YHDownLoadManager

#pragma mark - Lazy Load

- (NSMutableArray *)downLoadAudioQueue{
    if (!_downLoadAudioQueue) {
        _downLoadAudioQueue = [NSMutableArray new];
    }
    return _downLoadAudioQueue;
}

- (NSMutableArray *)downLoadOfficeFileQueue{
    if (!_downLoadOfficeFileQueue) {
        _downLoadOfficeFileQueue = [NSMutableArray new];
    }
    return _downLoadOfficeFileQueue;
}

#pragma mark - Public
+ (YHDownLoadManager *)sharedInstance {
    static YHDownLoadManager  *g_sharedInstance = nil;
    static dispatch_once_t pre = 0;
    dispatch_once(&pre, ^{
        g_sharedInstance = [[YHDownLoadManager alloc] init];
    });
    
    return g_sharedInstance;
}



//下载聊天语音
- (void)downLoadAudioWithRequestUrl:(NSString *)requestUrl complete:(void (^)(BOOL success,id obj))complete progress:(void(^)(int64_t bytesWritten, int64_t totalBytesWritten))progress{
    
    NSFileManager *fileM = [NSFileManager defaultManager];
    if(![fileM fileExistsAtPath:ChatRecordDir]){
        if (![fileM fileExistsAtPath:YHUserDir]) {
            [fileM createDirectoryAtPath:YHUserDir withIntermediateDirectories:YES attributes:nil error:nil];
        }
        if (![fileM fileExistsAtPath:YHChatLogDir]) {
            [fileM createDirectoryAtPath:YHChatLogDir withIntermediateDirectories:YES attributes:nil error:nil];
        }
        if (![fileM fileExistsAtPath:ChatRecordDir]) {
            [fileM createDirectoryAtPath:ChatRecordDir withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    
    [self _downLoadFileWithRequestUrl:requestUrl downLoadQueue:self.downLoadAudioQueue saveInDir:ChatRecordDir saveFileName:nil maxConcurrentCount:kDownloadAudioMAXCount complete:complete progress:progress];
}


//下载办公文件（pdf,word,ppt,xls）
- (void)downOfficeDocWithRequestUrl:(NSString *)requestUrl rename:(NSString *)rename sessionID:(NSString *)sessionID complete:(void (^)(BOOL success,id obj))complete progress:(void(^)(int64_t bytesWritten, int64_t totalBytesWritten))progress{

    if (!requestUrl) {
        complete(NO,@"download url is nil");
        progress(0,0);
        return;
    }
    NSFileManager *fileM = [NSFileManager defaultManager];
    if(![fileM fileExistsAtPath:OfficeDir]){
        if (![fileM fileExistsAtPath:YHUserDir]) {
            [fileM createDirectoryAtPath:YHUserDir withIntermediateDirectories:YES attributes:nil error:nil];
        }
        if (![fileM fileExistsAtPath:YHChatLogDir]) {
            [fileM createDirectoryAtPath:YHChatLogDir withIntermediateDirectories:YES attributes:nil error:nil];
        }
        if (![fileM fileExistsAtPath:OfficeDir]) {
            [fileM createDirectoryAtPath:OfficeDir withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    
    //保存在本地的文件名(唯一名字)
    NSString *saveFileName = [requestUrl lastPathComponent];
    //
   
    [self _downLoadFileWithRequestUrl:requestUrl downLoadQueue:self.downLoadOfficeFileQueue saveInDir:OfficeDir saveFileName:saveFileName maxConcurrentCount:kDownloadOfficeFileMAXCount complete:^(BOOL success, id obj) {
        if(success){
            complete(YES,obj);
        }else{
             complete(NO,obj);
        }
    } progress:progress];

}



#pragma mark - Private

- (void)_downLoadFileWithRequestUrl:(NSString *)requestUrl downLoadQueue:(NSMutableArray *)downLoadQueue saveInDir:(NSString *)saveInDir saveFileName:(NSString *)saveFileName maxConcurrentCount:(int)maxConcurrentCount complete:(void (^)(BOOL success,id obj))complete progress:(void(^)(int64_t bytesWritten, int64_t totalBytesWritten))progress{

    
    if (!saveInDir) {
        complete(NO,@"please choose dir to downLoad file");
        progress(0,0);
        return;
    }
    
    NSString *fileName = [requestUrl lastPathComponent];
    if (saveFileName) {
        fileName = saveFileName;
    }
    
    NSString *saveFilePath = [saveInDir stringByAppendingPathComponent:fileName];
    
    //任务已经存在下载队列中
    BOOL taskInDownLoadQueue = NO;
    for (YHDownLoadModel *model in downLoadQueue) {
        if ([model.filePath isEqualToString:saveFilePath]) {
            taskInDownLoadQueue = YES;
            break;
        }
    }
    
    //任务不在下载队列中
    if(!taskInDownLoadQueue){
        YHDownLoadModel *model = [YHDownLoadModel new];
        model.filePath = saveFilePath;
        model.complete = complete;
        model.progress = progress;
        [downLoadQueue addObject:model];
        
        if (downLoadQueue.count <= maxConcurrentCount) {
            model.isDownLoading = YES;
            
            [self _doDownLoadWithRequestUrl:requestUrl model:model maxConcurrentCount:maxConcurrentCount downloadQueue:downLoadQueue saveInDir:saveInDir saveFileName:saveFileName complete:complete progress:progress];
            
        }
        
        
    }

}


- (void)_doDownLoadWithRequestUrl:(NSString *)requestUrl model:(YHDownLoadModel *)model maxConcurrentCount:(int)maxConcurrentCount downloadQueue:( NSMutableArray *)downloadQueue saveInDir:(NSString *)saveInDir saveFileName:(NSString *)saveFileName complete:(void (^)(BOOL success,id obj))complete progress:(void(^)(int64_t bytesWritten, int64_t totalBytesWritten))progress{

    WeakSelf
    [[NetManager sharedInstance] downLoadWithRequestUrl:requestUrl saveInDir:saveInDir saveFileName:saveFileName complete:^(BOOL success, id obj) {
        complete(success,obj);
        
        model.isDownLoading = NO;
        [downloadQueue removeObject:model];
        
        YHDownLoadModel *lastModel = downloadQueue.lastObject;
        if (lastModel) {
            if (!lastModel.isDownLoading) {
                
                [weakSelf _downLoadFileWithRequestUrl:requestUrl downLoadQueue:downloadQueue saveInDir:saveInDir saveFileName:saveFileName maxConcurrentCount:maxConcurrentCount complete:lastModel.complete progress:lastModel.progress];
            }
        }

    } progress:^(NSProgress *downloadProgress) {
        if (model.progress) {
             model.progress(downloadProgress.completedUnitCount,downloadProgress.totalUnitCount);
        }
       
    }];
}







@end
