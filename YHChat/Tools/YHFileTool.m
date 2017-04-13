//
//  YHFileTool.m
//  YHSOFT
//
//  Created by samuelandkevin on 16/9/17.
//  Copyright (c) 2016年 samuelandkevin Co.,Ltd. All rights reserved.
//

#import "YHFileTool.h"
#import "YHSqilteConfig.h"

@implementation YHFileTool

+ (NSString *)getTempDataCacheDirectory {
    return [[self getAppCacheDirectory] stringByAppendingPathComponent:@"appdata"];         // 1.5.3 修改，之前是 tempData目录
}

+ (NSString *)getAppCacheDirectory {
    NSString* cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [cachesDirectory stringByAppendingPathComponent:[[NSProcessInfo processInfo] processName]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}

+ (NSString *)getDataCacheDirectory {
    NSString *path = [[self getAppCacheDirectory] stringByAppendingPathComponent:@"appdata"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}

+ (NSString *)getAppSupportDataDirectory {
    NSString *libPath = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)[0];
    NSString *appsupport = [libPath stringByAppendingPathComponent:@"AppSupport"];
    return appsupport;
}

+ (NSString *)getWebrootDirectory {
    return [[self getAppSupportDataDirectory] stringByAppendingPathComponent:@"web"];
}

+ (NSArray *)GetFilesListAtPath:(NSString *)dirPath withType:(NSString *)type
{
    //    NSMutableArray *filenamelist = [NSMutableArray arrayWithCapacity:10];
    NSURL *dirURL = [NSURL fileURLWithPath:dirPath];
    if (!dirURL) {
        DDLog(@"dirPath can not create URL!");
        return @[];
    }
    //    NSArray *tmplist = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dirPath error:nil];
    NSFileManager *localFileManager=[[NSFileManager alloc] init];
    
    // Enumerate the directory (specified elsewhere in your code)
    // Request the two properties the method uses, name and isDirectory
    // Ignore hidden files
    // The errorHandler: parameter is set to nil. Typically you'd want to present a panel
    NSDirectoryEnumerator *dirEnumerator = [localFileManager enumeratorAtURL:dirURL
                                                  includingPropertiesForKeys:[NSArray arrayWithObjects:NSURLNameKey,
                                                                              NSURLIsDirectoryKey,nil]
                                                                     options:NSDirectoryEnumerationSkipsHiddenFiles | NSDirectoryEnumerationSkipsSubdirectoryDescendants
                                                                errorHandler:nil];
    
    // An array to store the all the enumerated file names in
    //    NSMutableArray *theArray=[NSMutableArray array];
    NSMutableArray *fileNames = [NSMutableArray arrayWithCapacity:10];
    // Enumerate the dirEnumerator results, each value is stored in allURLs
    for (NSURL *theURL in dirEnumerator) {
        
        // Retrieve the file name. From NSURLNameKey, cached during the enumeration.
        NSString *fileName;
        [theURL getResourceValue:&fileName forKey:NSURLNameKey error:NULL];
        
        // Retrieve whether a directory. From NSURLIsDirectoryKey, also
        // cached during the enumeration.
        NSNumber *isDirectory;
        [theURL getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:NULL];
        
        // Ignore files directory
        if ( ([isDirectory boolValue] == YES) )
        {
            [dirEnumerator skipDescendants];
        }
        else
        {
            // Add full path for non directories
            if ([isDirectory boolValue]==NO) {
                if (type) {
                    if ([[fileName pathExtension] isEqualToString:type]) {
                        [fileNames addObject:fileName];
                    }
                }
                else
                    [fileNames addObject:fileName];
                //                [theArray addObject:theURL];
            }
            
            
        }
    }
    
    return fileNames;
}

// 文件主目录
+ (NSString *)fileMainPath
{

    NSString *path = OfficeDir;
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

// 小于1024显示KB，否则显示MB
+ (NSString *)filesize:(NSString *)path
{
    CGFloat size = [self fileSizeWithPath:path];
    if ( size > 1000.0) { // 1000kb不好看，所以我就以1000为标准了
        return [NSString stringWithFormat:@"%.1fMB",size/1024.0];
    } else {
        return [NSString stringWithFormat:@"%.1fKB",size];
    }
}

+ (NSString *)fileSizeWithInteger:(NSUInteger)integer
{
    CGFloat size = integer/1024.0;
    if ( size > 1000.0) { // 1000kb不好看，所以我就以1000为标准了
        return [NSString stringWithFormat:@"%.1fMB",size/1024.0];
    } else {
        return [NSString stringWithFormat:@"%.1fKB",size];
    }
}

// 返回字节
+ (CGFloat)fileSizeWithPath:(NSString *)path
{
    NSDictionary *outputFileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
    return [outputFileAttributes fileSize]/1024.0;
}

+ (BOOL)fileExistsAtPath:(NSString *)path
{
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}


+ (BOOL)removeFileAtPath:(NSString *)path
{
    return [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}

@end
