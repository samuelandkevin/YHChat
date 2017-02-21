//
//  HHUtils.h
//  HipHopBattle
//
//  Created by Troy on 14-6-26.
//  Copyright (c) 2014年 Dope Beats Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <sys/param.h>
#include <sys/mount.h>
#import <UIKit/UIKit.h>

typedef void(^HHAlertCallback)(BOOL resultYes );
@interface HHUtils : NSObject

/**
 * 获取文件MD5值
 */
+ (NSString *)getFileMD5WithPath:(NSString*)path;
+ (NSString *)getFileMD5WithData:(NSData *)data;
+ (UIView *)rotate360DegreeWithView:(UIView *)imageView;

#pragma mark - 弹窗页面
+ (void)showSingleButtonAlertWithTitle:(NSString *)title message:(NSString *)msg okTitle:(NSString *)okString dismiss:(HHAlertCallback)callback;
+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)msg dismiss:(HHAlertCallback)callback;
+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)msg okTitle:(NSString *)okString cancelTitle:(NSString *)cancelString inViewController:(UIViewController *)vc dismiss:(HHAlertCallback)callback;
+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)msg okTitle:(NSString *)okString cancelTitle:(NSString *)cancelString dismiss:(HHAlertCallback)callback;
+ (NSDictionary *)parseUrlParameters:(NSURL *)url;

+ (void)postTip:(NSString *)tipsTitle RGB16:(int)hexColor complete:(void(^)())completeCallback;
+ (void)postTip:(NSString *)tipsTitle RGB16:(int)rgbValue keepTime:(NSTimeInterval)interval complete:(void(^)())completeCallback;
+ (void)postTip:(NSString *)tipsTitle RGBcolorRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue keepTime:(NSTimeInterval)time complete:(void(^)())completeCallback;
+ (void)dismissAlertWithClickedButtonIndex:(NSInteger)buttonIndex
                                  animated:(BOOL)animated;

+ (long long)freeDiskSpaceInBytes;

/**
 *  MD5加密字符串
 *
 *  @param input 字符串
 *
 *  @return 加密后的字符串
 */
+ (NSString *)md5HexDigest:(NSString*)input;

/**
 *  获取iPhone机型
 *
 *  @return 
 */
+ (NSString*)phoneType;

/**
 *  获取iPhone系统
 *
 *  @return eg:iOS8.1
 */
+ (NSString *)phoneSystem;

/**
 *  appStore上的版本号
 *
 *  @return
 */
+ (NSString *)appStoreNumber;
/**
 *  app开发环境版本号
 *
 *  @return
 */
+ (NSString *)appBulidNumber;


@end

#ifdef __cplusplus
extern "C" {
#endif

    
/**
 返回文件长度，以字节为单位
 */
int getFileSize(NSString *path);


NSString * getDeviceVersion();
NSString * platformString ();

/**
 比较不同数组中不同的ID（与上一次的缓存对比）
 @return 返回与是一次是否有变化
 */
BOOL compareStringIdsDiff( NSArray *allphones, NSString *phonesCacheFilePath, NSArray **addlist, NSArray **removelist );

#ifdef __cplusplus
    }
#endif
