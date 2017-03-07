//
//  YHExpressionKeyboard.h
//  Expression
//
//  Created by samuelandkevin on 17/2/7.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - @protocol YHExpressionKeyboardDelegate
@class YHExpressionKeyboard;
@protocol YHExpressionKeyboardDelegate <NSObject>

@required
//点击发送
- (void)didTapSendBtn:(NSString *)text;

//录音相关
- (void)didStartRecordingVoice;
- (void)didStopRecordingVoice;
- (void)didCancelRecordingVoice;
- (void)didDragInside:(BOOL)inside;

@optional
//根据键盘是否弹起，设置tableView frame
- (void)keyboard:(YHExpressionKeyboard *)keyBoard changeDuration:(CGFloat)durtaion;
//选择了“+”内容
- (void)didSelectExtraItem:(NSString *)itemName;

@end


#pragma mark - YHExpressionKeyboard

@interface YHExpressionKeyboard : UIView

@property (nonatomic, assign) int maxNumberOfRowsToShow;//最大显示行


/**
 初始化方式

 @param viewController YHExpressionKeyboard所在的控制器
 @param aboveView 在viewController的view中,位于YHExpressionKeyboard上方的视图,（用于设置aboveView的滚动）
 @return YHExpressionKeyboard
 */
- (instancetype)initWithViewController:( UIViewController <YHExpressionKeyboardDelegate>*)viewController aboveView:( UIView *)aboveView;


/**
 结束编辑
 */
- (void)endEditing;

@end
