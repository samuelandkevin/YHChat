//
//  YHExpressionKeyboard.h
//  Expression
//
//  Created by samuelandkevin on 17/2/7.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YHExpressionKeyboard;
@protocol YHExpressionKeyboardDelegate <NSObject>

//点击发送
- (void)sendBtnDidTap:(NSString *)text;

@optional
//根据键盘是否弹起，设置tableView frame
- (void)keyboard:(YHExpressionKeyboard *)keyBoard changeDuration:(CGFloat)durtaion;
//选择了“+”内容
- (void)didSelectExtraItem:(NSString *)itemName;

@end


@interface YHExpressionKeyboard : UIView


@property (nonatomic, assign) int maxNumberOfRowsToShow;//最大显示行

//初始化
- (instancetype)initWithViewController:(UIViewController <YHExpressionKeyboardDelegate>*)viewController;

//结束编辑
- (void)endEditing;

@end
