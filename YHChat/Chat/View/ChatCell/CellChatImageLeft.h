//
//  CellChatImageLeft.h
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 17/2/22.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CellChatBase.h"

@class CellChatImageLeft;
@protocol CellChatImageLeftDelegate <NSObject>

@optional

- (void)retweetImage:(UIImage *)image inLeftCell:(CellChatImageLeft *)leftCell;//转发图片

@end


@interface CellChatImageLeft : CellChatBase

@property (nonatomic,weak)id<CellChatImageLeftDelegate>delegate;


@end
