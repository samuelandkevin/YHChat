//
//  CellChatFileLeft.h
//  YHChat
//
//  Created by YHIOS002 on 17/3/29.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "CellChatBase.h"

@class CellChatFileLeft;
@protocol CellChatFileLeftDelegate <NSObject>

- (void)onChatFile:(YHFileModel *)chatFile inLeftCell:(CellChatFileLeft *)leftCell;

@end

@interface CellChatFileLeft : CellChatBase

@property (nonatomic,assign)id<CellChatFileLeftDelegate>delegate;

@end
