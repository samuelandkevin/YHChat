//
//  CellChatBase.h
//  YHChat
//
//  Created by samuelandkevin on 17/2/27.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YHChatModel.h"

@class CellChatBase;

@protocol CellChatBaseDelegate <NSObject>

@optional
- (void)onCheckBoxAtIndexPath:(NSIndexPath *)indexPath model:(YHChatModel *)model;

@end

@interface CellChatBase : UITableViewCell

#pragma mark - Public Data
extern const float kAvatarWidth;//头像宽/高
@property (nonatomic,strong) YHChatModel *model;
@property (nonatomic,assign) NSIndexPath *indexPath;
@property (nonatomic,assign) id<CellChatBaseDelegate>baseDelegate;
@property (nonatomic,assign) BOOL showCheckBox;
#pragma mark - Public 控件
@property (nonatomic,strong) UILabel *lbTime;    //发言时间
@property (nonatomic,strong) UIView  *viewTimeBG;//发言时间背景
@property (nonatomic,strong) UILabel *lbName;    //发言人名字
@property (nonatomic,strong) UIImageView *imgvAvatar;//发布者头像
@property (nonatomic,strong) UIActivityIndicatorView *activityV;//loading
@property (nonatomic,strong) UIImageView *imgvSendMsgFail;//发送失败图标
@property (nonatomic,strong) UIButton *btnCheckBox;//选择框

#pragma mark - Public Gesture

//点击用户头像
- (void)onAvatarGesture:(UIGestureRecognizer *)aRec;

//点击发送失败图标
- (void)onImgSendMsgFailGesture:(UIGestureRecognizer *)aRec;

#pragma mark - Public Method
//设置Model
- (void)setupModel:(YHChatModel *)model;

//点击勾选框
- (void)onBtnCheckBox:(UIButton *)sender;

//布局共有的UI
- (void)layoutCommonUI;

//显示勾选框
//- (void)showCheckBox;

//隐藏勾选框
//- (void)hideCheckBox;
@end
