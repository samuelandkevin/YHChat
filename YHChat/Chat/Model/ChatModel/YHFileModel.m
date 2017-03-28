//
//  YHFileModel.m
//  YHChat
//
//  Created by YHIOS002 on 17/3/28.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "YHFileModel.h"
#import "YHChatHelper.h"

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
@end
