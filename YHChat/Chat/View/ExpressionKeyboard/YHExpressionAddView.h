//
//  YHExpressionAddView.h
//  Expression
//
//  Created by samuelandkevin on 17/2/9.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YHExtraModel;
@interface YHExpressionAddCell : UICollectionViewCell
@property (nonatomic,strong) YHExtraModel *model;

@end

@protocol YHExpressionAddViewDelegate <NSObject>

- (void)extraItemDidTap:(YHExtraModel *)model;

@end

@interface YHExpressionAddView : UIView

@property (nonatomic,weak)id<YHExpressionAddViewDelegate>delegate;
+ (instancetype)sharedView;

@end
