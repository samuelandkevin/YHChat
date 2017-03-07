//
//  YHFilePath.m
//  YHSOFT
//
//  Created by samuelandkevin on 16/9/17.
//  Copyright (c) 2016年 samuelandkevin Co.,Ltd. All rights reserved.
//

#import "YHFilePath.h"

@implementation YHFilePath

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

@end
