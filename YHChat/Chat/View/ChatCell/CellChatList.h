//
//  CellChatList.h
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 17/2/20.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YHChatListModel;
@interface CellChatList : UITableViewCell

@property (nonatomic,strong) YHChatListModel *model;
@end
