//
//  CellChatBase.h
//  YHChat
//
//  Created by YHIOS002 on 17/2/27.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YHChatModel.h"

@interface CellChatBase : UITableViewCell

#pragma mark - Public Data
extern const float kAvatarWidth;//头像宽/高
@property (nonatomic,strong) YHChatModel *model;
#pragma mark - Public 控件
@property (nonatomic,strong) UILabel *lbTime;    //发言时间
@property (nonatomic,strong) UIView  *viewTimeBG;//发言时间背景
@property (nonatomic,strong) UILabel *lbName; //发言人名字
@property (nonatomic,strong) UIImageView *imgvAvatar;//发布者头像
@property (nonatomic,strong) UIActivityIndicatorView *activityV;//loading
@property (nonatomic,strong) UIImageView *imgvSendMsgFail;//发送失败图标

#pragma mark - Public Gesture
//点击用户头像
- (void)onAvatarGesture:(UIGestureRecognizer *)aRec;
//点击发送失败图标
- (void)onImgSendMsgFailGesture:(UIGestureRecognizer *)aRec;

#pragma mark - Public Method
- (void)setupModel:(YHChatModel *)model;

//布局共有的UI
- (void)layoutCommonUI;
@end
