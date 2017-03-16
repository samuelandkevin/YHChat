//
//  YHLinkLabel.m
//  PikeWay
//
//  Created by YHIOS002 on 16/8/25.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

#import "YHLinkLabel.h"

@implementation YHLinkLabel

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupTap];
    }
    return self;
}

- (void)awakeFromNib
{
    [self setupTap];
    [super awakeFromNib];
}

/** 设置敲击手势 */
- (void)setupTap
{
    //已经在stroyboard设置了与用户交互,也可以用纯代码设置
    self.userInteractionEnabled = YES;
    
    //当前控件是label 所以是给label添加敲击手势
    [self addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuDidHide) name:UIMenuControllerDidHideMenuNotification object:nil];
}


- (void)longPress:(UILongPressGestureRecognizer *)gesture
{
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [self becomeFirstResponder];
        UIMenuController *menu = [UIMenuController sharedMenuController];
        if(menu.isMenuVisible) return;
        menu.menuItems = @[
                           [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(customCopy:)],[[UIMenuItem alloc] initWithTitle:@"转发" action:@selector(retweet:)]
                           ];
        
        [menu setTargetRect:self.bounds inView:self];
        //    [menu setTargetRect:self.frame inView:self.superview];
        [menu setMenuVisible:YES animated:YES];
        
        self.backgroundColor = RGBCOLOR(230, 230, 230);
    }
    
    
    
}

#pragma mark - NSNotification
- (void)menuDidHide{
    [self finishChoosing];
}


#pragma mark - UIMenuController相关

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (
        ((action == @selector(customCopy:) || (action == @selector(retweet:))) && self.text)
        )
        return YES;
    
    return NO;
}
#pragma mark - 监听MenuItem的点击事件/** 剪切 */
- (void)cut:(UIMenuController *)menu
{    //UIPasteboard 是可以在应用程序与应用程序之间共享的 \
    (应用程序:你的app就是一个应用程序 比如你的QQ消息可以剪切到百度查找一样)
    // 将label的文字存储到粘贴板
    [UIPasteboard generalPasteboard].string = self.text;
    // 清空文字
    self.text = nil;
    [self finishChoosing];
}


- (void)customCopy:(UIMenuController *)menu
{
    // 将label的文字存储到粘贴板
    [UIPasteboard generalPasteboard].string = self.text;
    [self finishChoosing];
}

- (void)retweet:(UIMenuController *)menu{

    WeakSelf
    if (self.retweetBlock) {
        weakSelf.retweetBlock(weakSelf.text);
    }
    [self finishChoosing];
}


- (void)paste:(UIMenuController *)menu
{
    // 将粘贴板的文字赋值给label
    self.text = [UIPasteboard generalPasteboard].string;
    [self finishChoosing];
}

#pragma mark - Private
//选择完毕
- (void)finishChoosing{
    self.backgroundColor = [UIColor clearColor];
}

#pragma mark - Life
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
