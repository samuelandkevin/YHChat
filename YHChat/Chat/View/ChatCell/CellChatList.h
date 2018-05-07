//
//  CellChatList.h
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 17/2/20.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YHChatListModel;
@class CellChatList;

@protocol CellChatListDelegate<NSObject>
- (void)touchOnCell:(CellChatList *)cell;
- (void)onAvatarInCell:(CellChatList *)cell;
@end

@interface CellChatList : UITableViewCell

@property (nonatomic,strong) YHChatListModel *model;
@property (nonatomic,weak) id <CellChatListDelegate> touchDelegate;
@end
