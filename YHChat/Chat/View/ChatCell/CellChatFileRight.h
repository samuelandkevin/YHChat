//
//  CellChatFileRight.h
//  YHChat
//
//  Created by YHIOS002 on 17/3/29.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "CellChatBase.h"

@class CellChatFileRight;

@protocol CellChatFileRightDelegate <NSObject>

- (void)onChatFile:(YHFileModel *)chatFile inRightCell:(CellChatFileRight *)rightCell;

@optional
- (void)retweetFile:(YHFileModel *)chatFile inRightCell:(CellChatFileRight *)rightCell;//转发文件
- (void)withDrawFile:(YHFileModel *)chatFile inRightCell:(CellChatFileRight *)rightCell;//撤回文件
@end

@interface CellChatFileRight : CellChatBase

@property (nonatomic,assign)id<CellChatFileRightDelegate>delegate;
@end
