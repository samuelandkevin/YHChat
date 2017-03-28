//
//  YHChatTextLayout.h
//  YHChat
//
//  Created by samuelandkevin on 17/3/23.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import <YYKit/YYKit.h>

@interface YHChatTextLayout : NSObject

@property (nonatomic, assign) CGFloat textHeight; //文本高度(包括下方留白)
@property (nonatomic, strong) YYTextLayout *textLayout; //文本

- (void)layoutWithText:(NSString *)text fontSize:(CGFloat)fontSize textColor:(UIColor *)textColor matchTextColor:(UIColor *)matchTextColor matchTextHighlightBGColor:(UIColor *)matchTextHighlightBGColor;
@end
