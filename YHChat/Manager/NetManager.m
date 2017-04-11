//
//  NetManager.m
//  MyProject
//
//  Created by user on 14-3-24.
//
//

#import "NetManager.h"


static NSMutableArray *sg_requestTasks;


@interface NetManager ()
@property (nonatomic,strong) AFNetworkReachabilityManager *reachablityManager;
@property (nullable, nonatomic, copy)YHNetWorkStatusChange netWorkStatusChange;
@end

@implementation NetManager

+ (NetManager*)sharedInstance {
    static NetManager  *g_sharedInstance = nil;
    static dispatch_once_t pre = 0;
    dispatch_once(&pre, ^{
        g_sharedInstance = [[NetManager alloc] init];
    });
    
    return g_sharedInstance;
}

- (id)init {
    self = [super init];
    if (!self) {
        return nil;
    }

    return self;
}

- (NSMutableArray *)allTasks {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (sg_requestTasks == nil) {
            sg_requestTasks = [[NSMutableArray alloc] init];
        }
    });
    
    return sg_requestTasks;
}

- (void)cancelAllRequest {
    
    @synchronized(self) {
        [[self allTasks] enumerateObjectsUsingBlock:^(YHURLSessionTask * _Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([task isKindOfClass:[YHURLSessionTask class]]) {
                [task cancel];
            }
        }];
        
        [[self allTasks] removeAllObjects];
    };
}

- (void)cancelRequestWithURL:(NSString *)url {
    if (url == nil) {
        return;
    }
    
    @synchronized(self) {
        [[self allTasks] enumerateObjectsUsingBlock:^(YHURLSessionTask * _Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([task isKindOfClass:[YHURLSessionTask class]]
                && [task.currentRequest.URL.absoluteString hasSuffix:url]) {
                [task cancel];
                [[self allTasks] removeObject:task];
                return;
            }
        }];
    };
}

- (AFHTTPSessionManager *)requestManager{
    
    if (!_requestManager) {
    
        _requestManager = [AFHTTPSessionManager manager];
        _requestManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        _requestManager.requestSerializer = [AFHTTPRequestSerializer serializer];
        _requestManager.requestSerializer.timeoutInterval = kReqTimeOutInterval;
         _requestManager.operationQueue.maxConcurrentOperationCount = 3;
        
    }
    return _requestManager;
}

#pragma mark - 网络状态监听
//初始化网络状态
- (void)initNetWorkStatus{
    self.reachablityManager = [AFNetworkReachabilityManager sharedManager];

    switch (self.reachablityManager.networkReachabilityStatus) {
        case AFNetworkReachabilityStatusUnknown:
        {
            DDLog(@"当前网络为:未知网络");
            self.currentNetWorkStatus = YHNetworkStatus_Unknown;
        }
            break;
            
        case AFNetworkReachabilityStatusNotReachable:
        {
            DDLog(@"没有网络");
            self.currentNetWorkStatus = YHNetworkStatus_NotReachable;
        }
            break;
            
        case AFNetworkReachabilityStatusReachableViaWWAN:
        {
            DDLog(@"当前网络为:手机自带网络");
            self.currentNetWorkStatus = YHNetworkStatus_ReachableViewWWAN;
        }
            break;
            
        case AFNetworkReachabilityStatusReachableViaWiFi:
        {
            DDLog(@"当前网络为:WIFI");
            self.currentNetWorkStatus = YHNetworkStatus_ReachableViaWiFi;
        }
            break;
    }
}

//开始监听网络状态
- (void)startMonitoring
{
    [self initNetWorkStatus];
 
    __weak typeof(self)weakSelf = self;
    [self.reachablityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
            {
                DDLog(@"当前网络为:未知网络");
                weakSelf.currentNetWorkStatus = YHNetworkStatus_Unknown;
            }
                break;
                
            case AFNetworkReachabilityStatusNotReachable:
            {
                DDLog(@"没有网络");
                weakSelf.currentNetWorkStatus = YHNetworkStatus_NotReachable;
            }
                break;
                
            case AFNetworkReachabilityStatusReachableViaWWAN:
            {
               DDLog(@"当前网络为:手机自带网络");
                weakSelf.currentNetWorkStatus = YHNetworkStatus_ReachableViewWWAN;
            }
                break;
                
            case AFNetworkReachabilityStatusReachableViaWiFi:
            {
                DDLog(@"当前网络为:WIFI");
                weakSelf.currentNetWorkStatus = YHNetworkStatus_ReachableViaWiFi;
            }
                break;
        }
        
        if (weakSelf.netWorkStatusChange) {
            weakSelf.netWorkStatusChange(weakSelf.currentNetWorkStatus);
        }
    }];
    [self.reachablityManager startMonitoring];
  
}

- (void)netWorkStatusChange:(YHNetWorkStatusChange)netWorkStatusChange{
    
    self.netWorkStatusChange = netWorkStatusChange;
    
}


#pragma mark - Life
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Private

/**
 *  打印请求路径
 *
 *  @param Url          Url
 *  @param params       请求参数字典
 *  @param protocolName 协议名字
 *
 *  @return 请求路径
 */
- (NSString *)requestPathWithUrl:(NSString *)Url params:(NSDictionary *)params protocolName:(NSString *)protocolName{
    
#ifdef DEBUG
    NSMutableString *maStr = [NSMutableString stringWithString:@"?"];
    for (NSString *key in params.allKeys) {
        
        id value = params[key];
        NSString *str= [NSString stringWithFormat:@"%@=%@&",key,value];
        [maStr appendString:str];
        
    }
    NSString *result       = [maStr substringToIndex:maStr.length-1];
    NSString *requestPath  = [NSString stringWithFormat:@"%@%@",Url,result];
    DDLog(@"%@ requestPath :%@",protocolName,requestPath);
    return requestPath;
#else
    return nil;
#endif
}

//基于AFN封装的Get请求 (---此段代码不要随便修改---)
- (void)getWithRequestUrl:(NSString *)requestUrl parameters:(NSDictionary*)parameters complete:(NetManagerCallback)complete progress:(void(^)(NSProgress *downloadProgress))progress{
    
    if(self.currentNetWorkStatus == YHNetworkStatus_NotReachable){
        complete(NO,kNetWorkFailTips);
        progress([NSProgress new]);
        return;
    }
    

    YHURLSessionTask *session = [self.requestManager GET:requestUrl parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        progress(uploadProgress);
    }
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             
             [[self allTasks] removeObject:task];
             
             NSDictionary *jsonObj = nil;
             if([self canParseResponseObject:responseObject jsonObj:&jsonObj]){
                 
                 if([self isRequestSuccessWithJsonObj:jsonObj]){
                     complete(YES,jsonObj);
                 }
                 else{
//                     NSString *error = nil;
//                     isNSStringClass(jsonobj[kRetMsg], error);
                     complete(NO,jsonObj);
                 }
             }
             else{
                 complete(NO,kParseError);
             }
             
             
         }
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             
             [[self allTasks] removeObject:task];

             complete(NO,error);
         }];
    
    if (session) {

        [[self allTasks] addObject:session];
    }
}

//基于AFN封装的Post请求 (---此段代码不要随便修改---)
- (void)postWithRequestUrl:(NSString *)requestUrl parameters:(NSDictionary*)parameters complete:(NetManagerCallback)complete progress:(void(^)(NSProgress *uploadProgress))progress{
   
    if(self.currentNetWorkStatus == YHNetworkStatus_NotReachable){
        complete(NO,kNetWorkFailTips);
        progress([NSProgress new]);
        return;
    }
   

   YHURLSessionTask *session = [self.requestManager  POST:requestUrl parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
            progress(uploadProgress);
    }
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              
             [[self allTasks] removeObject:task];
              
              NSDictionary *jsonObj = nil;
              if([self canParseResponseObject:responseObject jsonObj:&jsonObj]){
                  
                  if([self isRequestSuccessWithJsonObj:jsonObj])
                  {
                      complete(YES,jsonObj);
                  }
                  else
                  {

                      complete(NO,jsonObj);
                  }
              }
              else{
                  complete(NO,kParseError);
              }
              
              
          }
          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              
              [[self allTasks] removeObject:task];

              complete(NO,error);
          }];
    
    if (session) {
        [[self allTasks] addObject:session];
    }
    
}

//基于AFN封装的delete请求 (---此段代码不要随便修改---)
- (void)deleteWithRequestUrl:(NSString *)requestUrl parameters:(NSDictionary*)parameters complete:(NetManagerCallback)complete{

    if(self.currentNetWorkStatus == YHNetworkStatus_NotReachable){
        complete(NO,kNetWorkFailTips);
        return;
    }
    

    YHURLSessionTask *session = [self.requestManager  DELETE:requestUrl parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [[self allTasks] removeObject:task];
        
        NSDictionary *jsonObj = nil;
        if([self canParseResponseObject:responseObject jsonObj:&jsonObj]){
            
            if([self isRequestSuccessWithJsonObj:jsonObj])
            {
                complete(YES,jsonObj);
            }
            else
            {
//                NSString *error = nil;
//                isNSStringClass(jsonobj[kRetMsg], error);
                complete(NO,jsonObj);
            }
        }
        else{
            complete(NO,kParseError);
        }

        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [[self allTasks] removeObject:task];
        
        complete(NO,error);
    }];
    
    if (session) {
        [[self allTasks] addObject:session];
    }

}

//基于AFN封装的put请求 (---此段代码不要随便修改---)
- (void)putWithRequestUrl:(NSString *)requestUrl parameters:(NSDictionary*)parameters complete:(NetManagerCallback)complete{
    
    if(self.currentNetWorkStatus == YHNetworkStatus_NotReachable){
        complete(NO,kNetWorkFailTips);
        return;
    }
 
    YHURLSessionTask *session = [self.requestManager  PUT:requestUrl parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [[self allTasks] removeObject:task];
        
        NSDictionary *jsonObj = nil;
        if([self canParseResponseObject:responseObject jsonObj:&jsonObj]){
            
            if([self isRequestSuccessWithJsonObj:jsonObj])
            {
                complete(YES,jsonObj);
            }
            else
            {
//                NSString *error = nil;
//                isNSStringClass(jsonobj[kRetMsg], error);
                complete(NO,jsonObj);
            }
        }
        else{
            complete(NO,kParseError);
        }
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [[self allTasks] removeObject:task];
        
        complete(NO,error);
    }];
    
    if (session) {
        [[self allTasks] addObject:session];
    }

}

/**
 *  上传图片  (---此段代码不要随便修改---)
 *
 *  @param url        url
 *  @param parameters 参数
 *  @param imageArray 图片数组
 *  @param fileNames  图片的名字数组（可以为空,默认是以日期格式为名字）
 *  @param name       对应网站上[upload.php中]处理文件的[字段"file"]
 *  @param mimeType   上传文件的[mimeType]
 *  @param progress   进度值
 *  @param complete   成功失败回调
 */
- (void)uploadWithRequestUrl:(NSString *)url parameters:(NSDictionary *)parameters imageArray:(NSArray <UIImage *>*)imageArray fileNames:(NSArray< NSString *>*)fileNames name:(NSString *)name mimeType:(NSString *)mimeType  progress:(YHUploadProgress)progress complete:(NetManagerCallback)complete
{
    
    if(self.currentNetWorkStatus == YHNetworkStatus_NotReachable){
        complete(NO,kNetWorkFailTips);
        progress(0,0);
        return;
    }
    
 
    YHURLSessionTask *session =
    [self.requestManager  POST:url
       parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData)
     {
         
       
            //1.上传单张或多张图片
            for(NSInteger i = 0; i < imageArray.count; i++)
            {
                
               
                    //获取图片Image
                UIImage *image     = imageArray[i];
                
                NSData * imageData = nil;
                    //压缩
                @autoreleasepool {
                    imageData = UIImageJPEGRepresentation(image, 0.5);
                }
                
                    //2.上传的参数名
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    formatter.dateFormat       = @"yyyyMMddHHmmss";
                    NSString *strData          = [formatter stringFromDate:[NSDate date]];
                    
                    
                    //取出单个图片名字
                    NSString *fileName = @"";
                    if (i < fileNames.count) {
                        fileName = fileNames[i];
                    }
                    
                    //保存在服务器的文件名
                    NSString *fileNameInServer = @"";
                    if (!fileName.length)
                    {
                        fileNameInServer   = [NSString stringWithFormat:@"%@.jpg",strData];
                    }
                    else
                    {
                        
                        NSString *strExt = @"";//扩展名
                        NSString *strName= @"";
                        NSArray *arrName = [fileName componentsSeparatedByString:@"."];
                        if(arrName.count > 1){
                            strExt = [arrName lastObject];
                        }
                        NSInteger length = (fileName.length - strExt.length - 1);
                        if(length >= 0){
                            strName = [fileName substringToIndex:length];
                        }
                        
                        if(!strExt.length){
                            strExt = @"png";//默认图片后续为.png
                        }
                        
                        fileNameInServer   = [NSString stringWithFormat:@"%@%@.%@",strData,strName,strExt];
                    }
                    
                    //3.上传图片，以文件流的格式
                    [formData appendPartWithFileData:imageData name:name fileName:fileNameInServer mimeType:mimeType];
                
               
            }
       
        
     }
         progress:^(NSProgress * _Nonnull uploadProgress)
     {
         
         if (progress) {
             progress(uploadProgress.completedUnitCount, uploadProgress.totalUnitCount);
         }
     }
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              
              [[self allTasks] removeObject:task];
              
              NSDictionary *jsonObj = nil;
              if([self canParseResponseObject:responseObject jsonObj:&jsonObj]){
                  
                  if([self isRequestSuccessWithJsonObj:jsonObj])
                  {
                      complete(YES,jsonObj);
                  }
                  else
                  {
                      NSString *error = nil;
                      isNSStringClass(jsonObj[@"msg"], error);
                      complete(NO,error);
                  }
              }
              else{
                  complete(NO,kParseError);
              }

          }
          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              
              [[self allTasks] removeObject:task];
              
              complete(NO,error);
          }];
    
    [session resume];
    
    if (session) {
        [[self allTasks] addObject:session];
    }
    
}

//上传文件请求
- (void)uploadWithRequestUrl:(NSString *)url parameters:(NSDictionary *)parameters filePath:(NSString *)filePath name:(NSString *)name mimeType:(NSString *)mimeType progress:(YHUploadProgress)progress complete:(NetManagerCallback)complete{

    if(self.currentNetWorkStatus == YHNetworkStatus_NotReachable){
        complete(NO,kNetWorkFailTips);
        progress(0,0);
        return;
    }
    
    YHURLSessionTask *session =
    [self.requestManager  POST:url
                    parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData){
         
        NSString *fileNameInServer = [filePath lastPathComponent];
        NSData *data =  [NSData dataWithContentsOfFile:filePath];
        if (data){
            [formData appendPartWithFileData:data name:name fileName:fileNameInServer mimeType:mimeType];
        }
             
     }
    progress:^(NSProgress * _Nonnull uploadProgress){
         
         if (progress) {
             progress(uploadProgress.completedUnitCount, uploadProgress.totalUnitCount);
         }
     }
    success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject){
        
        
        
        [[self allTasks] removeObject:task];
                           
        NSDictionary *jsonObj = nil;
        if([self canParseResponseObject:responseObject jsonObj:&jsonObj]){
                               
            if([self isRequestSuccessWithJsonObj:jsonObj]){
                complete(YES,jsonObj);
            }else{
                NSString *error = nil;
                isNSStringClass(jsonObj[@"msg"], error);
                complete(NO,error);
            }
         }else{
                complete(NO,kParseError);
        }
                           
    }
    failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error){
                           
        [[self allTasks] removeObject:task];
                           
        complete(NO,error);
    }];
    
    [session resume];
    
    if (session) {
        [[self allTasks] addObject:session];
    }

}


//下载请求
- (void)downLoadWithRequestUrl:(NSString *)requestUrl saveInDir:(NSString *)saveInDir saveFileName:(NSString *)saveFileName complete:(NetManagerCallback)complete progress:(void(^)(NSProgress *downloadProgress))progress{
   

    //url
    NSURL *url  = [NSURL URLWithString:requestUrl];
    
    if (!saveInDir) {
        complete(NO,@"please choose dir to downLoad file");
        progress([NSProgress new]);
        return;
    }
    
    //判断是否有缓存
    NSString *fileName = [url lastPathComponent];
    if (saveFileName) {
        fileName = saveFileName;
    }
    
    NSString *cacheFilePath = [saveInDir stringByAppendingPathComponent:fileName];
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:cacheFilePath]) {
        DDLog(@"打开缓存文件:\n%@",cacheFilePath);
        progress([NSProgress new]);
        complete(YES,cacheFilePath);
        return;
    }
    
    //没有缓存就下载
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        progress(downloadProgress);

    }destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSURL *fileDir      = [NSURL fileURLWithPath:saveInDir];
        NSString *aFileName = [response suggestedFilename];
        if (saveFileName) {
            aFileName = saveFileName;
        }
        NSURL *fileUrl = [fileDir URLByAppendingPathComponent:aFileName];
        return fileUrl;
        
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        NSString *path = [filePath relativePath];
        DDLog(@"下载文件到:\n%@", path);
        if (error) {
             complete(NO,error);
        }else{
            
            NSDictionary *attributes = [fm attributesOfItemAtPath:path error:nil];
            NSNumber *theFileSize = [attributes objectForKey:NSFileSize];
            if ([theFileSize floatValue] == 0) {
                 //移除容量大小为0的文件
                 [fm removeItemAtPath:path error:nil];
                 NSString *errMsg = @"下载文件大小为0,文件即将移除";
                 DDLog(@"%@",errMsg);
                 NSDictionary *dict = @{kRetMsg:errMsg,
                                       @"code":@(-999)};
                 complete(NO,dict);
            }else{
                 complete(YES,[filePath relativePath]);
            }

        }
       
    }];
    [downloadTask resume];
    
    
}

/**
 *  是否可以解析服务器返回的数据
 *
 *  @param responseObject 服务器返回的NSData对象
 *  @param jsonObj        从服务器解析后的json对象,指针的指针
 *
 *  @return YES:可以解析,NO则不可以解析
 */
- (BOOL)canParseResponseObject:(NSData *)responseObject jsonObj:(NSDictionary **)jsonObj{
    
    NSError *parseJsonError = nil;
    
    id jsonObject = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&parseJsonError];
    if (parseJsonError) {
        DDLog(@"json 解析失败:%@",parseJsonError.localizedDescription);
        return NO;
    }
    else {
        
        if (![jsonObject isKindOfClass:[NSDictionary class]]){
            DDLog(@"服务器返回的数据不是字典类型！");
            return NO;
        }
        *jsonObj = (NSDictionary *)jsonObject;
    }
    
    return YES;
}

/**
 *  该协议请求是否成功
 *
 *  @param jsonObj 字典类型的json对象
 *
 *  @return YES:成功 NO:失败
 */
- (BOOL)isRequestSuccessWithJsonObj:(NSDictionary *)jsonObj{
    int statusCode = [jsonObj[@"code"] intValue];
    if (statusCode == kSuccessCode) {
        return YES;
    }
    else
        return NO;
}


@end
