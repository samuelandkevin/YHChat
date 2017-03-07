//
//  YHExpressionInputView.h
//  
//
//  Created by samuelandkevin on 17/2/8.
//  Copyright (C) 2017 samuelandkevin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YHExpressionInputViewDelegate <NSObject>

//点击发送按钮
- (void)didTapSendBtn;

@optional
- (void)emoticonInputDidTapText:(NSString *)text;
- (void)emoticonInputDidTapBackspace;

@end

/// 表情键盘
@interface YHExpressionInputView : UIView
@property (nonatomic, weak) id<YHExpressionInputViewDelegate> delegate;
@property (nonatomic, strong) UITextView *textView;
+ (instancetype)sharedView;
@end
