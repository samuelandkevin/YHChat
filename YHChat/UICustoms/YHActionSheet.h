//
//  YHActionSheet.h
//  samuelandkevin
//
//  Created by samuelandkevin on 16/4/28.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  操作回调，如果用户点击空白处，不选中任何button，则 clickedIndex = NSNotFound， isCancel = YES
 *  clickedIndex 从0开始， cancelButton是最后一个， titleButton不能点击
 */
typedef void(^YHSheetCompletionHanlde)(NSInteger clickedIndex, BOOL isCancel);

@interface YHActionSheet : UIView
@property (nullable, nonatomic, copy) NSString *cancelTitle;//
@property (nullable, nonatomic, copy) NSArray *otherTitles;
@property (copy,nonatomic,nonnull)YHSheetCompletionHanlde handle;

- (nonnull instancetype)initWithCancelTitle:(nonnull NSString*)cancelTitle otherTitles:(nonnull NSArray *)otherTitles;
- (void)show;
- (void)dismissForCompletionHandle:(nullable YHSheetCompletionHanlde)handle;


@end
