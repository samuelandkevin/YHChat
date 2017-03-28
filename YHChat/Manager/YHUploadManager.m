//
//  YHUploadManager.m
//  samuelandkevin
//
//  Created by samuelandkevin on 17/1/12.
//  Copyright © 2017年 YHSoft. All rights reserved.
//

#import "YHUploadManager.h"
#import "NetManager.h"
#import "YHChatModel.h"
//#import "YHDebug.h"


#define kUploadAudioMAXCount 3      //上传音频数量限制
#define kUploadOfficeFileMAXCount 3 //上传办公格式文件数量限制

@interface YHUploadModel : NSObject

@property (nonatomic,copy) NSString *filePath;
@property (nonatomic,copy) void (^complete)(BOOL success,id obj);
@property (nonatomic,copy) void(^progress)(int64_t bytesWritten, int64_t totalBytesWritten);
@property (nonatomic,assign) BOOL isUploading;

@end

@implementation YHUploadModel


@end

@interface YHUploadManager()
@property (nonatomic,strong)NSMutableArray *uploadAudioQueue;//上传音频数组
@property (nonatomic,strong)NSMutableArray *uploadOfficeFileQueue;
@end

@implementation YHUploadManager

+ (YHUploadManager*)sharedInstance {
    static YHUploadManager  *g_sharedInstance = nil;
    static dispatch_once_t pre = 0;
    dispatch_once(&pre, ^{
        g_sharedInstance = [[YHUploadManager alloc] init];
    });
    return g_sharedInstance;
}

- (NSMutableArray *)uploadAudioQueue{
    if (!_uploadAudioQueue) {
        _uploadAudioQueue = [NSMutableArray new];
    }
    return _uploadAudioQueue;
}

- (NSMutableArray *)uploadOfficeFileQueue{
    if (!_uploadOfficeFileQueue) {
        _uploadOfficeFileQueue = [NSMutableArray new];
    }
    return _uploadOfficeFileQueue;
}

#pragma mark - Public
//上传聊天语音
- (void)uploadChatRecordWithPath:(NSString *)recordPath complete:(void (^)(BOOL success,id obj))complete progress:(void(^)(int64_t bytesWritten, int64_t totalBytesWritten))progress{
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@",kBaseURL,kPathUploadRecordFile];
    
    NSDictionary *params = @{
                             @"accessToken":MYTOKEN
                             };

    [self _uploadFileInQueue:self.uploadAudioQueue filePath:recordPath requestUrl:requestUrl fileNameInServer:@"file" maxConcurrentCount:kUploadAudioMAXCount mimeType:@"audio/wav" params:params complete:^(BOOL success, id obj){
        if (success) {
            id dictData  = obj[@"data"];
            if(![dictData isKindOfClass:[NSDictionary class]]){
                complete(NO,kServerReturnEmptyData);
                return ;
            }
            NSDictionary *dict = dictData;
            
            YHAudioModel *retModel = [YHAudioModel new];
            
            NSString *url     = dict[@"url"];
            retModel.url      = [NSURL URLWithString:url];
            retModel.duration = [dict[@"duration"] floatValue];
            retModel.ext      = dict[@"ext"];
            
            complete(YES,retModel);
        }else{
            complete(NO,obj);
        }
    } progress:progress];
    
}


//上传办公格式的文件
- (void)uploadOfficeFileWithPath:(NSString *)filePath complete:(void (^)(BOOL success,id obj))complete progress:(void(^)(int64_t bytesWritten, int64_t totalBytesWritten))progress{

    NSString *requestUrl = [NSString stringWithFormat:@"%@%@",kBaseURL,kPathUploadOfficeFile];
    
    NSString *mimeType = [self _getMIMETypeWithFilePath:filePath];
    
    NSDictionary *params = @{
                             @"accessToken":MYTOKEN
                             };
    [self _uploadFileInQueue:self.uploadOfficeFileQueue filePath:filePath requestUrl:requestUrl fileNameInServer:@"files" maxConcurrentCount:kUploadOfficeFileMAXCount mimeType:mimeType params:params complete:^(BOOL success, id obj) {
        if (success) {
            id dictData  = obj[@"data"];
            if(![dictData isKindOfClass:[NSDictionary class]]){
                complete(NO,kServerReturnEmptyData);
                return ;
            }
            NSDictionary *dict = dictData;
   
            NSString *urlStr  = dict[@"url"];
            NSURL *url        = [NSURL URLWithString:urlStr];
            complete(YES,url);
        }else{
            complete(NO,obj);
        }

    } progress:progress];
}




#pragma mark - Private

- (void)_uploadFileInQueue:(NSMutableArray *)uploadQueue filePath:(NSString *)filePath requestUrl:(NSString *)requestUrl fileNameInServer:(NSString *)fileNameInServer maxConcurrentCount:(int)maxConcurrentCount mimeType:(NSString *)mimeType params:(NSDictionary *)params complete:(void (^)(BOOL success,id obj))complete progress:(void(^)(int64_t bytesWritten, int64_t totalBytesWritten))progress{
    
    
    //filePath
    if(![[NSFileManager defaultManager] fileExistsAtPath:filePath]){
        complete(NO,@"file is not Exist!");
        progress(0,0);
        return ;
    }
    
    //任务已经存在上传队列中
    BOOL taskInUploadQueue = NO;
    for (YHUploadModel *model in uploadQueue) {
        if ([model.filePath isEqualToString:filePath]) {
            taskInUploadQueue = YES;
            break;
        }
    }
    
    //任务不在上传队列中
    if(!taskInUploadQueue){
        YHUploadModel *model = [YHUploadModel new];
        model.filePath = filePath;
        model.complete = complete;
        model.progress = progress;
        [uploadQueue addObject:model];
        if (uploadQueue.count <= maxConcurrentCount) {
            model.isUploading = YES;

            [self _doUploadWithRequestUrl:requestUrl params:params model:model filePath:filePath fileNameInServer:fileNameInServer mimeType:mimeType maxConcurrentCount:maxConcurrentCount uploadQueue:uploadQueue complete:complete progress:progress];
            
        }
        
        
    }
    
}

- (void)_doUploadWithRequestUrl:(NSString *)requestUrl params:(NSDictionary *)params model:(YHUploadModel *)model filePath:(NSString *)filePath fileNameInServer:(NSString *)fileNameInServer mimeType:(NSString *)mimeType maxConcurrentCount:(int)maxConcurrentCount uploadQueue:(NSMutableArray *)uploadQueue complete:(void (^)(BOOL success,id obj))complete progress:(void(^)(int64_t bytesWritten, int64_t totalBytesWritten))progress{
    
    WeakSelf
    //上传
    [[NetManager sharedInstance] uploadWithRequestUrl:requestUrl parameters:params filePath:filePath name:fileNameInServer mimeType:mimeType progress:^(int64_t bytesWritten, int64_t totalBytesWritten) {
        progress(bytesWritten,totalBytesWritten);
    } complete:^(BOOL success, id obj) {
        
        complete(success,obj);
        
        model.isUploading = NO;
        [uploadQueue removeObject:model];
        
        YHUploadModel *lastModel = uploadQueue.lastObject;
        if (lastModel) {
            if (!lastModel.isUploading) {
                
                [weakSelf _uploadFileInQueue:uploadQueue filePath:lastModel.filePath requestUrl:requestUrl fileNameInServer:fileNameInServer maxConcurrentCount:maxConcurrentCount mimeType:mimeType params:params complete:lastModel.complete progress:lastModel.progress];
            }
        }
        
    }];
}

- (NSString *)_getMIMETypeWithFilePath:(NSString *)filePath{
    //Ext                 mimeType
    //.pdf                application/pdf
    //.ppt                application/powerpoint
    //.word .doc .docx    application/msword
    //.xls	.xlsx         application/excel
    NSString *ext = [filePath pathExtension];
    NSString *mimeType = nil;
    if ([ext isEqualToString:@"pdf"]) {
        mimeType = @"application/pdf";
    }else if([ext isEqualToString:@"ppt"] || [ext isEqualToString:@"pptx"]){
        mimeType = @"application/powerpoint";
    }else if([ext isEqualToString:@"word"] || [ext isEqualToString:@"doc"] || [ext isEqualToString:@"docx"]){
        mimeType = @"application/msword";
    }else if([ext isEqualToString:@"xls"] || [ext isEqualToString:@"xlsx"]){
        mimeType = @"application/excel";
    }else{
        mimeType = @"application/msword";
    }
    return mimeType;
}

@end
