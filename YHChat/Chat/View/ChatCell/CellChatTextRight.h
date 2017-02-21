//
//  CellChatRight.h
//  YHChat
//
//  Created by YHIOS002 on 17/2/17.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import <UIKit/UIKit.h>


@class YHUserInfo;
@class CellChatTextRight;
@protocol CellChatTextRightDelegate <NSObject>

@optional
- (void)tapRightAvatar:(YHUserInfo *)userInfo;
- (void)tapSendMsgFailImg;//点击发送失败图标
@end

@class YHChatModel;

@interface CellChatTextRight : UITableViewCell

@property (nonatomic,strong) YHChatModel *model;
@property (nonatomic,weak)id<CellChatTextRightDelegate>delegate;
@end
