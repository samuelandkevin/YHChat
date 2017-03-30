//
//  YHFileModel.m
//  YHChat
//
//  Created by YHIOS002 on 17/3/28.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "YHFileModel.h"
#import "YHChatHelper.h"
#import "NSObject+YHDBRuntime.h"

@implementation YHFileModel

- (void)setFileSize:(CGFloat)fileSize{
    _fileSize = fileSize;
    if ( _fileSize > 1000.0) { // 1000kb不好看，所以我就以1000为标准了
        self.fileSizeStr = [NSString stringWithFormat:@"%.1fMB",_fileSize/1024.0];
    } else {
        self.fileSizeStr = [NSString stringWithFormat:@"%.1fKB",_fileSize];
    }
}

- (void)setExt:(NSString *)ext{
    _ext = ext;
    _fileType = [YHChatHelper fileType:_ext];
}

#pragma mark - YHFMDB
+ (NSString *)yh_primaryKey{
    return @"filePathInServer";
}

+ (NSDictionary *)yh_replacedKeyFromPropertyName{
    return @{@"filePathInServer":YHDB_PrimaryKey};
}

+ (NSArray *)yh_propertyDonotSave{
    return @[@"isSelected"];
}

#pragma mark - Life Cycle
- (void)dealloc{
//    DDLog(@"%s is dealloc",__func__);
}

@end
