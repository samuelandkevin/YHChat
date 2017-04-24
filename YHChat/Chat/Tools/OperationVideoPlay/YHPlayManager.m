//
//  YHPlayManager.m
//  YHChat
//
//  Created by samuelandkevin on 17/4/24.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "YHPlayManager.h"
#import "VideoPlayOperation.h"

@implementation YHPlayManager
@synthesize videoDecode;
@synthesize videoQueue;

+ (YHPlayManager*)sharedInstanced
{
    static YHPlayManager *sharedAccountManagerInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedAccountManagerInstance = [[self alloc] init];
        sharedAccountManagerInstance.videoDecode = [[NSMutableDictionary alloc]init];
        sharedAccountManagerInstance.videoQueue  = [[NSOperationQueue alloc]init];
        sharedAccountManagerInstance.videoQueue.maxConcurrentOperationCount=10;
        
    });
    return sharedAccountManagerInstance;
}


- (void)startWithLocalPath:(NSString *)filePath WithVideoBlock:(VideoCode)videoImage{
    [self checkVideoPath:filePath wihtBlock:videoImage];
}


- (VideoPlayOperation *)checkVideoPath:(NSString *)filePath wihtBlock:(VideoCode)videoBlock
{
    if (!videoQueue) {
        videoQueue = [[NSOperationQueue alloc]init];
        videoQueue.maxConcurrentOperationCount = 10000;
    }
    if (!videoDecode) {
        videoDecode = [[NSMutableDictionary alloc]init];
    }
    VideoPlayOperation *videoOperation = nil;

    
    [self cancelVideo:filePath];
    videoOperation = [[VideoPlayOperation alloc] init ];

    __weak VideoPlayOperation *weakplay=videoOperation;
    videoOperation.videoBlock = videoBlock;
    [videoOperation addExecutionBlock:^{
        [weakplay  videoPlayTask:filePath];
    }];
    [videoOperation setCompletionBlock:^{
        [videoDecode removeObjectForKey:filePath];
        if (weakplay.stopBlock) {
            weakplay.stopBlock(filePath);
        }
    }];
    [videoDecode setObject:videoOperation forKey:filePath];
    [videoQueue  addOperation:videoOperation];
    return videoOperation;
}


- (void)reloadVideo:(VideoStop) stop withFile:(NSString *)filePath {
    VideoPlayOperation *videoOperation = nil;
    if ([videoDecode objectForKey:filePath]) {
        videoOperation = [videoDecode objectForKey:filePath];
        videoOperation.stopBlock=stop;
    }
}

-(void)cancelVideo:(NSString *)filePath
{
    VideoPlayOperation *videoOperation = nil;
    if ([videoDecode objectForKey:filePath]) {
        videoOperation=[videoDecode objectForKey:filePath];
        if (videoOperation.isCancelled) {
            return;
        }
        [videoOperation setCompletionBlock:nil];
        
        videoOperation.stopBlock  = nil;
        videoOperation.videoBlock = nil;
        [videoOperation cancel];
        if (videoOperation.isCancelled) {
            [videoDecode removeObjectForKey:filePath];
        }
    }
}

-(void)cancelAllVideo
{
    if (videoQueue) {
        NSMutableDictionary *tpDict=[NSMutableDictionary dictionaryWithDictionary:videoDecode];
        for (NSString *key in tpDict) {
            [self cancelVideo:key];
        }
        [videoDecode removeAllObjects];
        [videoQueue cancelAllOperations];
    }
}



@end
