//
//  CellChatLeft.h
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 17/2/17.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CellChatBase.h"

@class YHUserInfo;
@class CellChatTextLeft;
@protocol CellChatTextLeftDelegate <NSObject>

@optional
- (void)tapLeftAvatar:(YHUserInfo *)userInfo;
- (void)retweetMsg:(NSString *)msg inLeftCell:(CellChatTextLeft *)leftCell;//转发消息
@end

@class YHChatModel;
@interface CellChatTextLeft : CellChatBase

@property (nonatomic,weak)id<CellChatTextLeftDelegate>delegate;
@property (nonatomic,assign)NSIndexPath *indexPath;
@end
