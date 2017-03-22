//
//  HHUtils.m
//  HipHopBattle
//
//  Created by Troy on 14-6-26.
//  Copyright (c) 2014年 Dope Beats Co.,Ltd. All rights reserved.
//

#import "HHUtils.h"
#import <AVFoundation/AVFoundation.h>
#import <CommonCrypto/CommonCrypto.h>
//#import "HHCommon.h"
//#include <sys/syscall.h>
#import <sys/utsname.h>
#import "AppDelegate.h"
#import <CommonCrypto/CommonDigest.h>
#import "NSDate+Extension.h"

#define FileHashDefaultChunkSizeForReadingData 1024*512
#define kCommonAlertTag         10



CFStringRef FileMD5HashCreateWithPath(CFStringRef filePath,size_t chunkSizeForReadingData) {
    // Declare needed variables
    CFStringRef result = NULL;
    CFReadStreamRef readStream = NULL;
    // Get the file URL
    CFURLRef fileURL =
    CFURLCreateWithFileSystemPath(kCFAllocatorDefault,
                                  (CFStringRef)filePath,
                                  kCFURLPOSIXPathStyle,
                                  (Boolean)false);
    if (!fileURL) goto done;
    // Create and open the read stream
    readStream = CFReadStreamCreateWithFile(kCFAllocatorDefault,
                                            (CFURLRef)fileURL);
    if (!readStream) goto done;
    bool didSucceed = (bool)CFReadStreamOpen(readStream);
    if (!didSucceed) goto done;
    // Initialize the hash object
    CC_MD5_CTX hashObject;
    CC_MD5_Init(&hashObject);
    // Make sure chunkSizeForReadingData is valid
    if (!chunkSizeForReadingData) {
        chunkSizeForReadingData = FileHashDefaultChunkSizeForReadingData;
    }
    // Feed the data to the hash object
    bool hasMoreData = true;
    while (hasMoreData) {
        uint8_t buffer[chunkSizeForReadingData];
        CFIndex readBytesCount = CFReadStreamRead(readStream,(UInt8 *)buffer,(CFIndex)sizeof(buffer));
        if (readBytesCount == -1) break;
        if (readBytesCount == 0) {
            hasMoreData = false;
            continue;
        }
        CC_MD5_Update(&hashObject,(const void *)buffer,(CC_LONG)readBytesCount);
    }
    // Check if the read operation succeeded
    didSucceed = !hasMoreData;
    // Compute the hash digest
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &hashObject);
    // Abort if the read operation failed
    if (!didSucceed) goto done;
    // Compute the string result
    char hash[ 2 * sizeof(digest) + 1 ];
    for (size_t i = 0; i < sizeof(digest); ++i) {
        snprintf(hash + (2 * i), 3, "%02x", (int)(digest[i]));
    }
    hash[ 2 * sizeof(digest) ] = '\0';
    result = CFStringCreateWithCString(kCFAllocatorDefault,(const char *)hash,kCFStringEncodingUTF8);
    
done:
    if (readStream) {
        CFReadStreamClose(readStream);
        CFRelease(readStream);
    }
    if (fileURL) {
        CFRelease(fileURL);
    }
    return result;
}

@interface AssistObject : NSObject
@property (nonatomic, copy)    HHAlertCallback     callbackForAlert;

@property (nonatomic, copy)     NSString            *title;
@property (nonatomic, copy)     NSString            *message;
@property (nonatomic, weak)     id                  alertView;
//@property (nonatomic, strong)   NSMutableArray      *alertViews;
@end

@interface HHUIAlertView : UIAlertView

@property (nonatomic, strong) HHAlertCallback   dismissCallback;

@end

@implementation HHUIAlertView

@end


static AssistObject *g_assistObj = nil;

@interface HHUtils ()<UIAlertViewDelegate>


@end


@implementation HHUtils

+ (long long)freeDiskSpaceInBytes{
    struct statfs buf;
    long long freespace = -1;
    if(statfs("/var", &buf) >= 0){
        freespace = (long long)(buf.f_bsize * buf.f_bfree);
    }
    
    return freespace;
}


+(NSString*)getFileMD5WithPath:(NSString*)path
{
    return (__bridge_transfer NSString *)FileMD5HashCreateWithPath((__bridge  CFStringRef)path,FileHashDefaultChunkSizeForReadingData);
}

+ (NSString *)getFileMD5WithData:(NSData *)data {
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
//    MD5_CTX smd5;
//    MD5_Init(&smd5);
//    MD5_Update(&smd5, data.bytes, data.length);
//    MD5_Final(digest, &smd5);
    
    
    CC_MD5( data.bytes, (UInt32)data.length, digest );
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [result appendFormat:@"%02x", digest[i]];
    return result;
}

+ (UIView *)rotate360DegreeWithView:(UIImageView *)imageView {
    
    
    [imageView.layer removeAnimationForKey:@"rotateView"];
    CABasicAnimation *animation = [ CABasicAnimation
                                   animationWithKeyPath: @"transform.rotation.z" ];
    //    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    animation.fromValue     = @(0.0);
    //围绕Z轴旋转，垂直与屏幕
    animation.toValue       = @(-M_PI);
    //    [ NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI, 0.0, 0.0, 1.0) ];
    animation.duration = 0.5;
    
    //旋转效果累计，先转180度，接着再旋转180度，从而实现360旋转
    animation.cumulative = YES;
    animation.repeatCount = HUGE_VALF;
    
    [imageView.layer addAnimation:animation forKey:@"rotateView"];
    return imageView;
}

+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)msg dismiss:(HHAlertCallback)callback {
    
    return [self showAlertWithTitle:title message:msg okTitle:@"确定" cancelTitle:@"取消" dismiss:callback];
}

+ (void)showSingleButtonAlertWithTitle:(NSString *)title message:(NSString *)msg okTitle:(NSString *)okString dismiss:(HHAlertCallback)callback {
    return [self showAlertWithTitle:title message:msg okTitle:okString cancelTitle:nil inViewController:[UIApplication sharedApplication].keyWindow.rootViewController dismiss:callback];
}

+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)msg okTitle:(NSString *)okString cancelTitle:(NSString *)cancelString dismiss:(HHAlertCallback)callback {
    
    return [self showAlertWithTitle:title message:msg okTitle:okString cancelTitle:cancelString inViewController:[UIApplication sharedApplication].keyWindow.rootViewController dismiss:callback];
}

+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)msg okTitle:(NSString *)okString cancelTitle:(NSString *)cancelString inViewController:(UIViewController *)vc dismiss:(HHAlertCallback)callback
{
    if (!g_assistObj) {
        g_assistObj = [AssistObject new];
    }
    
    NSString *titleString = title?title:@"提示";
    if ([[UIDevice currentDevice].systemVersion floatValue]< 8.0) {
        HHUIAlertView *alert = [[HHUIAlertView alloc] initWithTitle:titleString message:msg delegate:g_assistObj cancelButtonTitle:cancelString otherButtonTitles:okString, nil];
        alert.dismissCallback = callback;
        alert.tag = kCommonAlertTag;
        [alert show];
        g_assistObj.alertView = alert;
    }
    else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
        
        if (cancelString) {
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:cancelString style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (callback) {
                        callback( NO );
                    }
//                    g_assistObj.callbackForAlert(NO);
//                    g_assistObj.callbackForAlert = nil;
                });
                
            }];
            [alert addAction:cancel];
        }
        
        UIAlertAction *ok = [UIAlertAction actionWithTitle:okString style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (callback) {
                    callback( YES );
                }
//                g_assistObj.callbackForAlert(YES);
//                g_assistObj.callbackForAlert = nil;
            });
            
        }];
        [alert addAction:ok];
        
        dispatch_async(dispatch_get_main_queue(), ^ {
            [vc presentViewController:alert animated:YES completion:nil];
        });
        
        g_assistObj.alertView = alert;
    }
}

+ (void)dismissAlertWithClickedButtonIndex:(NSInteger)buttonIndex
                             animated:(BOOL)animated {
    if (g_assistObj.alertView) {
        if ([g_assistObj.alertView isKindOfClass:[UIAlertView class]]) {
            [g_assistObj.alertView dismissWithClickedButtonIndex:buttonIndex animated:animated];
        }
        else if ([g_assistObj.alertView isKindOfClass:[UIAlertController class]]) {
            [g_assistObj.alertView dismissViewControllerAnimated:animated completion:nil];
        }
    }
}

+ (NSDictionary *)parseUrlParameters:(NSURL *)url {
    NSMutableDictionary *retMd = [NSMutableDictionary dictionary];
    NSString *query = [url query];
    if (!query || query.length == 0) {
        return retMd;
    }
    
    NSArray *parameters = [query componentsSeparatedByString:@"&"];
    for (NSString *str in parameters) {
        NSArray *keyValue   = [str componentsSeparatedByString:@"="];
        [retMd setObject:keyValue[1] forKey:keyValue[0]];
    }
    
    return retMd;
}

+ (void)postTip:(NSString *)tipsTitle RGB16:(int)rgbValue complete:(void(^)())completeCallback {

    [self postTip:tipsTitle RGBcolorRed:((float)((rgbValue & 0xFF0000) >> 16)) \
            green:((float)((rgbValue & 0xFF00) >> 8)) \
             blue:((float)(rgbValue & 0xFF)) \
         keepTime:1.0 \
         complete:completeCallback];
    
}

+ (void)postTip:(NSString *)tipsTitle RGB16:(int)rgbValue keepTime:(NSTimeInterval)interval complete:(void(^)())completeCallback {
    [self postTip:tipsTitle RGBcolorRed:((float)((rgbValue & 0xFF0000) >> 16)) \
            green:((float)((rgbValue & 0xFF00) >> 8)) \
             blue:((float)(rgbValue & 0xFF)) \
         keepTime:interval \
         complete:completeCallback];
}

+ (void)postTip:(NSString *)tipsTitle RGBcolorRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue keepTime:(NSTimeInterval)time complete:(void(^)())completeCallback {
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    UILabel *labelBanner = [[UILabel alloc] initWithFrame:CGRectMake(0, -20, keyWindow.frame.size.width, 20)];
    labelBanner.font = [UIFont systemFontOfSize:10.0f];
    labelBanner.text = tipsTitle;
    labelBanner.textAlignment = NSTextAlignmentCenter;
    labelBanner.backgroundColor = [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1];
    labelBanner.textColor = [UIColor colorWithRed:239/255.0 green:239/255.0 blue:239/255.0 alpha:1];
    
    keyWindow.windowLevel = UIWindowLevelStatusBar + 1.0f;
    [keyWindow addSubview:labelBanner];
    
    [UIView animateWithDuration:0.3 animations:^{
        //显示出来
        labelBanner.transform = CGAffineTransformMakeTranslation(0, 20);
        
    } completion:^(BOOL finished) {
        //停留0.5
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //回去
            [UIView animateWithDuration:0.5 animations:^{
                labelBanner.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                keyWindow.windowLevel = UIWindowLevelNormal;
                if (completeCallback) {
                    completeCallback();
                }
                
            }];
            
        });
    }];
}

+ (NSString *)md5HexDigest:(NSString*)input{
    
    const char *cStr = [input UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (CC_LONG)input.length, digest );
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [result appendFormat:@"%02x", digest[i]];
    return result;
    
}

+ (NSString *)getDeviceVersion {
    NSString *deviceType;
    struct utsname systemInfo;
    uname(&systemInfo);
    deviceType = [NSString stringWithCString:systemInfo.machine
                                    encoding:NSUTF8StringEncoding];
    return deviceType;
}

+ (NSString*)phoneType
{
    NSString *platform = getDeviceVersion();
    //iPhone
    if ([platform isEqualToString:@"iPhone1,1"])   return@"iPhone 1G";
    if ([platform isEqualToString:@"iPhone1,2"])   return@"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"])   return@"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"])   return@"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,2"])   return@"Verizon iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"])   return@"iPhone 4 (CDMA)";
    if ([platform isEqualToString:@"iPhone4,1"])   return @"iPhone 4s";
    if ([platform isEqualToString:@"iPhone5,1"])   return @"iPhone 5 (GSM/WCDMA)";
    if ([platform isEqualToString:@"iPhone4,2"])   return @"iPhone 5 (CDMA)";
    if ([platform isEqualToString:@"iPhone6,1"]) return @"iPhone 5S";
    
    if ([platform isEqualToString:@"iPhone6,2"]) return @"iPhone 5S";
    
    if ([platform isEqualToString:@"iPhone7,1"]) return @"iPhone 6";
    
    if ([platform isEqualToString:@"iPhone7,2"]) return @"iPhone 6 Plus";
    if ([platform isEqualToString:@"iPhone8,1"]) return @"iPhone 6s";
    if ([platform isEqualToString:@"iPhone8,2"]) return @"iPhone 6s Plus";
    
    //iPot Touch
    if ([platform isEqualToString:@"iPod1,1"])     return@"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])     return@"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])     return@"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])     return@"iPod Touch 4G";
    if ([platform isEqualToString:@"iPod5,1"])     return@"iPod Touch 5G";
    //iPad
    if ([platform isEqualToString:@"iPad1,1"])     return@"iPad";
    if ([platform isEqualToString:@"iPad2,1"])     return@"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"])     return@"iPad 2 (GSM)";
    if ([platform isEqualToString:@"iPad2,3"])     return@"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"iPad2,4"])     return@"iPad 2 New";
    if ([platform isEqualToString:@"iPad2,5"])     return@"iPad Mini (WiFi)";
    if ([platform isEqualToString:@"iPad3,1"])     return@"iPad 3 (WiFi)";
    if ([platform isEqualToString:@"iPad3,2"])     return@"iPad 3 (CDMA)";
    if ([platform isEqualToString:@"iPad3,3"])     return@"iPad 3 (GSM)";
    if ([platform isEqualToString:@"iPad3,4"])     return@"iPad 4 (WiFi)";
    if ([platform isEqualToString:@"i386"] || [platform isEqualToString:@"x86_64"])        return@"Simulator";
    
    return platform;
}

+ (NSString *)phoneSystem{
    return [NSString stringWithFormat:@"%@%@",[UIDevice currentDevice].systemName,[UIDevice currentDevice].systemVersion];
}

+ (NSString *)appStoreNumber{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

+ (NSString *)appBulidNumber{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}


#pragma mark - Lazy Load



///**
// *  格式化日期
// *
// *  @param dateFormat 日期格式，etg：@"yyyy-MM-dd HH:mm:ss"
// *
// *  @return 字符串
// */
//- (NSString *)toStringByformat:(NSString *)dateFormat
//{
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateFormat:dateFormat];
//    NSString *returnString = [formatter stringFromDate:self];
//    ARC_RELEASE(dateFormatter);
//    return returnString;
//}

#pragma mark - 格式化显示时间 4月12日

//+ (NSDate *)dateFromString:(NSString *)dateString{
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    
//    [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
//    NSDate *destDate= [dateFormatter dateFromString:dateString];
//    return destDate;
//    
//}


@end

@implementation AssistObject


#pragma mark - AlertDelegate

- (void)alertView:(HHUIAlertView *)alertView
didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == kCommonAlertTag) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (buttonIndex == 1) {
//                _callbackForAlert( YES );
                alertView.dismissCallback( YES );
            }
            else {
                alertView.dismissCallback( NO );
//                _callbackForAlert( NO );
            }
//            _callbackForAlert = NULL;
        });
    }
    
}

@end

int getFileSize(NSString *path)
{
    NSFileManager * filemanager = [[NSFileManager alloc]init];
    if([filemanager fileExistsAtPath:path]){
        NSDictionary * attributes = [filemanager attributesOfItemAtPath:path error:nil];
        NSNumber *theFileSize;
        if ( (theFileSize = [attributes objectForKey:NSFileSize]) )
            return  [theFileSize intValue];
        else
            return -1;
    }
    else
    {
        return -1;
    }
}

NSString* getDeviceVersion()
{

    NSString *deviceType;
    struct utsname systemInfo;
    uname(&systemInfo);
    deviceType = [NSString stringWithCString:systemInfo.machine
                                    encoding:NSUTF8StringEncoding];
    return deviceType;
}

NSString * platformString ()
{
    NSString *platform = getDeviceVersion();
    //iPhone
    if ([platform isEqualToString:@"iPhone1,1"])   return@"iPhone 1G";
    if ([platform isEqualToString:@"iPhone1,2"])   return@"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"])   return@"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"])   return@"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,2"])   return@"Verizon iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"])   return@"iPhone 4 (CDMA)";
    if ([platform isEqualToString:@"iPhone4,1"])   return @"iPhone 4s";
    if ([platform isEqualToString:@"iPhone5,1"])   return @"iPhone 5 (GSM/WCDMA)";
    if ([platform isEqualToString:@"iPhone4,2"])   return @"iPhone 5 (CDMA)";
    
    //iPot Touch
    if ([platform isEqualToString:@"iPod1,1"])     return@"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])     return@"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])     return@"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])     return@"iPod Touch 4G";
    if ([platform isEqualToString:@"iPod5,1"])     return@"iPod Touch 5G";
    //iPad
    if ([platform isEqualToString:@"iPad1,1"])     return@"iPad";
    if ([platform isEqualToString:@"iPad2,1"])     return@"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"])     return@"iPad 2 (GSM)";
    if ([platform isEqualToString:@"iPad2,3"])     return@"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"iPad2,4"])     return@"iPad 2 New";
    if ([platform isEqualToString:@"iPad2,5"])     return@"iPad Mini (WiFi)";
    if ([platform isEqualToString:@"iPad3,1"])     return@"iPad 3 (WiFi)";
    if ([platform isEqualToString:@"iPad3,2"])     return@"iPad 3 (CDMA)";
    if ([platform isEqualToString:@"iPad3,3"])     return@"iPad 3 (GSM)";
    if ([platform isEqualToString:@"iPad3,4"])     return@"iPad 4 (WiFi)";
    if ([platform isEqualToString:@"i386"] || [platform isEqualToString:@"x86_64"])        return@"Simulator";
    
    return platform;
}

BOOL compareStringIdsDiff( NSArray *allphones, NSString *phonesCacheFilePath, NSArray **addlist, NSArray **removelist ) {
    NSMutableArray *cachephones = [NSMutableArray arrayWithContentsOfFile:phonesCacheFilePath];
   
    NSMutableArray *sortedAllPhones = [NSMutableArray arrayWithArray:allphones];
    [sortedAllPhones sortUsingSelector:@selector(compare:)];
    
    NSMutableArray *maAddList = [NSMutableArray array];
    NSMutableArray *maRemoveList = [NSMutableArray array];
    BOOL hasChange = NO;
    if (cachephones) {
        // 有过记录
        NSMutableIndexSet *shouldRemoveIndex = [NSMutableIndexSet indexSet];
        
        int lindx, rindx; lindx = rindx = 0;
        
        do {
            if ( lindx >= cachephones.count) {
                // 左边没有了，右边全部增加到addlist
                NSArray *subarray = [sortedAllPhones subarrayWithRange:NSMakeRange(rindx, sortedAllPhones.count - rindx)];
                [maAddList addObjectsFromArray:subarray];
                break;
            }
            
            if ( rindx >= sortedAllPhones.count) {
                // 右边没有了，左边全部回到removelist
                NSArray *subarray = [cachephones subarrayWithRange:NSMakeRange(lindx, cachephones.count - lindx)];
                [maRemoveList addObjectsFromArray:subarray];
                break;
            }
            
    
            long long lv = [cachephones[lindx] longLongValue];
            long long rv = [sortedAllPhones[rindx] longLongValue];
            if ( lv > rv ) {
                [maAddList addObject:sortedAllPhones[rindx]];
                rindx++;
            }
            else if (lv == rv) {
                lindx++;
                rindx++;
            }
            else {
                [maRemoveList addObject:cachephones[lindx]];
                [shouldRemoveIndex addIndex:lindx];
                lindx++;
            }
        } while (1);
        
        if (maAddList.count > 0 || maRemoveList.count > 0) {
            hasChange = YES;
        }
    }
    else {
        
    }
    
    [sortedAllPhones writeToFile:phonesCacheFilePath atomically:NO];
    
    if (addlist) {
        *addlist = maAddList;
    }
    if (removelist) {
        *removelist = maRemoveList;
    }
    
    return hasChange;
}
