//
//  CellChatLeft.h
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 17/2/17.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YHUserInfo;
@class CellChatTextLeft;
@protocol CellChatTextLeftDelegate <NSObject>

@optional
- (void)tapLeftAvatar:(YHUserInfo *)userInfo;

@end

@class YHChatModel;
@interface CellChatTextLeft : UITableViewCell

@property (nonatomic,strong) YHChatModel *model;
@property (nonatomic,weak)id<CellChatTextLeftDelegate>delegate;
@end
