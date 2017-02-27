//
//  NetManager.h
//  MyProject
//
//  Created by user on 14-3-24.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "YHUserInfo.h"
#import "AFNetworking.h"


/**********NetManagner的一些宏定义*************/
#define kSuccessCode 999  //请求成功状态码
#define iOSPlatform @(1) //iOS平台
#define kParseError  @"json 解析失败"
#define kReqTimeOutInterval 20    //请求超时时间
#define kServerReturnEmptyData @"返回空数据" //服务器返回空数据
#define kNetWorkFailTips            @"网络链接失败,请检查网络设置"   //断网提示
#define kNetWorkReqTimeOutTips      @"请求超时,请稍后重试"         //请求超时提示
#define kRetCode @"code"  //服务器返回的代码 key
#define kRetMsg  @"msg"   //服务器返回的描述 key

//回调时数据是否NSString类型
#define isNSStringClass(a, ret)\
{\
    ret = ([(a) isKindOfClass:[NSString class]])?(a):(@" ");\
}


/**********枚举类型************/
typedef void(^NetManagerCallback)(BOOL success, id obj);
typedef NSURLSessionTask YHURLSessionTask;

/**
 *  上传进度回调
 *
 *  @param bytesWritten      已上传的大小
 *  @param totalBytesWritten 总上传大小
 */
typedef void (^YHUploadProgress)(int64_t bytesWritten,
                                  int64_t totalBytesWritten);

typedef NS_ENUM(NSInteger ,YHNetworkStatus){
    YHNetworkStatus_Unknown      = -1,
    YHNetworkStatus_NotReachable = 0,
    YHNetworkStatus_ReachableViewWWAN,
    YHNetworkStatus_ReachableViaWiFi
};
typedef void(^YHNetWorkStatusChange)(YHNetworkStatus status);
//登录的平台
typedef NS_ENUM(int,PlatformType){
    PlatformType_QQ,
    PlatformType_Wechat,
    PlatformType_Sina
};


@interface NetManager : NSObject

@property (nonatomic,assign)YHNetworkStatus currentNetWorkStatus;
@property (nonatomic,strong)AFHTTPSessionManager *requestManager;


+ (NetManager*)sharedInstance;

/**
 *  取消所有请求
 */
- (void)cancelAllRequest;
/**
 *  取消当个请求
 *
 *  @param url URL，可以是绝对URL，也可以是path（也就是不包括baseurl）
 */
- (void)cancelRequestWithURL:(NSString *)url;


#pragma mark - 网络状态监听
- (void)startMonitoring;
- (void)netWorkStatusChange:(YHNetWorkStatusChange)netWorkStatusChange;

#pragma mark - Public

//get请求
- (void)getWithRequestUrl:(NSString *)requestUrl parameters:(NSDictionary*)parameters complete:(NetManagerCallback)complete progress:(void(^)(NSProgress *downloadProgress))progress;

//post请求
- (void)postWithRequestUrl:(NSString *)requestUrl parameters:(NSDictionary*)parameters complete:(NetManagerCallback)complete progress:(void(^)(NSProgress *uploadProgress))progress;

//delete请求
- (void)deleteWithRequestUrl:(NSString *)requestUrl parameters:(NSDictionary*)parameters complete:(NetManagerCallback)complete;

//put请求
- (void)putWithRequestUrl:(NSString *)requestUrl parameters:(NSDictionary*)parameters complete:(NetManagerCallback)complete;

//上传图片请求
- (void)uploadWithRequestUrl:(NSString *)url parameters:(NSDictionary *)parameters imageArray:(NSArray <UIImage *>*)imageArray fileNames:(NSArray< NSString *>*)fileNames name:(NSString *)name mimeType:(NSString *)mimeType  progress:(YHUploadProgress)progress complete:(NetManagerCallback)complete;

//上传文件请求
- (void)uploadWithRequestUrl:(NSString *)url parameters:(NSDictionary *)parameters filePath:(NSString *)filePath name:(NSString *)name mimeType:(NSString *)mimeType progress:(YHUploadProgress)progress complete:(NetManagerCallback)complete;

//下载请求(带有缓存)
- (void)downLoadWithRequestUrl:(NSString *)requestUrl saveInDir:(NSString *)saveInDir saveFileName:(NSString *)saveFileName complete:(NetManagerCallback)complete progress:(void(^)(NSProgress *downloadProgress))progress;

//是否可以解析服务器返回的数据
- (BOOL)canParseResponseObject:(NSData *)responseObject jsonObj:(NSDictionary **)jsonObj;

//该协议请求是否成功
- (BOOL)isRequestSuccessWithJsonObj:(NSDictionary *)jsonObj;

//打印请求路径
- (NSString *)requestPathWithUrl:(NSString *)Url params:(NSDictionary *)params protocolName:(NSString *)protocolName;


@end
