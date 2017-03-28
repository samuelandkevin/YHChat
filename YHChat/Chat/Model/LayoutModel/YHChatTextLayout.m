//
//  YHChatTextLayout.m
//  YHChat
//
//  Created by samuelandkevin on 17/3/23.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "YHChatTextLayout.h"
#import "YHExpressionHelper.h"
/**
 文本 Line 位置修改
 将每行文本的高度和位置固定下来，不受中英文/Emoji字体的 ascent/descent 影响
 */
@interface YHChatTextLinePositionModifier : NSObject <YYTextLinePositionModifier>
@property (nonatomic, strong) UIFont *font; // 基准字体 (例如 Heiti SC/PingFang SC)
@property (nonatomic, assign) CGFloat paddingTop; //文本顶部留白
@property (nonatomic, assign) CGFloat paddingBottom; //文本底部留白
@property (nonatomic, assign) CGFloat lineHeightMultiple; //行距倍数
- (CGFloat)heightForLineCount:(NSUInteger)lineCount;
@end

@implementation YHChatTextLinePositionModifier


- (instancetype)init {
    self = [super init];
    
    if (kiOS9Later) {
        _lineHeightMultiple = 1.34;   // for PingFang SC
    } else {
        _lineHeightMultiple = 1.3125; // for Heiti SC
    }
    
    return self;
}

- (void)modifyLines:(NSArray *)lines fromText:(NSAttributedString *)text inContainer:(YYTextContainer *)container {
    //CGFloat ascent = _font.ascender;
    CGFloat ascent = _font.pointSize * 0.86;
    
    CGFloat lineHeight = _font.pointSize * _lineHeightMultiple;
    for (YYTextLine *line in lines) {
        CGPoint position = line.position;
        position.y = _paddingTop + ascent + line.row  * lineHeight;
        line.position = position;
    }
}

- (id)copyWithZone:(NSZone *)zone {
    YHChatTextLinePositionModifier *one = [self.class new];
    one->_font = _font;
    one->_paddingTop = _paddingTop;
    one->_paddingBottom = _paddingBottom;
    one->_lineHeightMultiple = _lineHeightMultiple;
    return one;
}

- (CGFloat)heightForLineCount:(NSUInteger)lineCount {
    if (lineCount == 0) return 0;
    //    CGFloat ascent = _font.ascender;
    //    CGFloat descent = -_font.descender;
    CGFloat ascent = _font.pointSize * 0.86;
    CGFloat descent = _font.pointSize * 0.14;
    CGFloat lineHeight = _font.pointSize * _lineHeightMultiple;
    return _paddingTop + _paddingBottom + ascent + descent + (lineCount - 1) * lineHeight;
}

@end

@implementation YHChatTextLayout

- (void)layoutWithText:(NSString *)text fontSize:(CGFloat)fontSize textColor:(UIColor *)textColor matchTextColor:(UIColor *)matchTextColor matchTextHighlightBGColor:(UIColor *)matchTextHighlightBGColor{
    YHChatTextLinePositionModifier *modifier = [YHChatTextLinePositionModifier new];
    modifier.font = [UIFont fontWithName:@"Heiti SC" size:fontSize];
    modifier.paddingTop = 0;
    modifier.paddingBottom = 0;
    
    YYTextContainer *container = [YYTextContainer new];
    container.size = CGSizeMake(SCREEN_WIDTH - 133, HUGE);
    container.linePositionModifier = modifier;
    NSMutableAttributedString *maStr = [YHExpressionHelper attributedStringWithText:text fontSize:fontSize textColor:textColor matchTextColor:matchTextColor matchTextHighlightBGColor:matchTextHighlightBGColor];
    _textLayout = [YYTextLayout layoutWithContainer:container text:maStr];
    if (!_textLayout) return;
    
    _textHeight = [modifier heightForLineCount:_textLayout.rowCount];
}

@end


