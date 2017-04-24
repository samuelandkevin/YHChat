//
//  YHPlayManager.h
//  YHChat
//
//  Created by samuelandkevin on 17/4/24.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VideoPlayOperation.h"

@interface YHPlayManager : NSObject
{
    NSOperationQueue    *videoQueue;
    NSMutableDictionary *videoDecode;
    
}

@property(nonatomic,strong)NSMutableDictionary *videoDecode;
@property(nonatomic,strong)NSOperationQueue    *videoQueue;


+ (YHPlayManager*)sharedInstanced;
// 本地 videoPath   block中播放的imageview
- (void)startWithLocalPath:(NSString *)filePath WithVideoBlock:(VideoCode)videoImage;
- (void)reloadVideo:(VideoStop)stop withFile:(NSString *)filePath;
- (void)cancelVideo:(NSString *)filePath;
- (void)cancelAllVideo;


@end
