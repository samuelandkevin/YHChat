//
//  CellChatImageRight.h
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 17/2/22.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CellChatBase.h"

@class CellChatImageRight;
@protocol CellChatImageRightDelegate <NSObject>

@optional
- (void)retweetImage:(UIImage *)image inRightCell:(CellChatImageRight *)rightCell;//转发图片
- (void)withDrawImage:(UIImage *)image inRightCell:(CellChatImageRight *)rightCell;//撤回图片

@end


@interface CellChatImageRight : CellChatBase

@property (nonatomic,weak)id<CellChatImageRightDelegate>delegate;

@end
