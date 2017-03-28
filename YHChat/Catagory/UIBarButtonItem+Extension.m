//
//  UIBarButtonItem+Extension.m
//  YHChat
//
//  Created by samuelandkevin on 17/3/23.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "UIBarButtonItem+Extension.h"
#import <objc/runtime.h>

@interface UIBarButtonItem()
@property (nonatomic,copy) void(^btnBlock)();
@end

@implementation UIBarButtonItem (Extension)
static const char *btnBlockKey = "btnBlockKey";

- (void (^)())btnBlock{
    return objc_getAssociatedObject(self, btnBlockKey);
}

- (void)setBtnBlock:(void (^)())btnBlock{
    objc_setAssociatedObject(self, btnBlockKey, btnBlock, OBJC_ASSOCIATION_COPY);
}

#pragma mark - Public
+ (UIBarButtonItem *)backItemWithTarget:(id)target selector:(SEL)selector{
    
    return  [self barButtonItemWithFrame:CGRectMake(0, 0, 40, 40) imgName:@"common_leftArrow" imageEdgeInsets:UIEdgeInsetsMake(0, -30, 0, 0) target:target selector:selector];
}

/**********UIBarButtonItem为文字的设置**********/

+ (UIBarButtonItem *)leftItemWithTitle:(NSString *)title target:(id)target selector:(SEL)selector{
    return [self barButtonItemWithFrame:CGRectMake(0, 0, 40, 40) title:title target:target selector:selector block:nil];
}

+ (UIBarButtonItem *)leftItemWithTitle:(NSString *)title target:(id)target selector:(SEL)selector block:(void(^)(UIButton *btn))block{
    return  [self barButtonItemWithFrame:CGRectMake(0, 0, 40, 40) title:title target:target selector:selector block:block];
}

+ (UIBarButtonItem *)rightItemWithTitle:(NSString *)title target:(id)target selector:(SEL)selector{
    return [self barButtonItemWithFrame:CGRectMake(0, 0, 40, 40) title:title target:target selector:selector block:nil];
}

+ (UIBarButtonItem *)rightItemWithTitle:(NSString *)title target:(id)target selector:(SEL)selector block:(void(^)(UIButton *btn))block{
    return  [self barButtonItemWithFrame:CGRectMake(0, 0, 40, 40) title:title target:target selector:selector block:block];
}


/**********UIBarButtonItem为图片的设置**********/

+ (UIBarButtonItem *)leftItemWithImgName:(NSString *)imgName target:(id)target selector:(SEL)selector{
    return  [self barButtonItemWithFrame:CGRectMake(0, 0, 44, 44) imgName:imgName imageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 20) target:target selector:selector];
}

+ (UIBarButtonItem *)leftItemWithImgName:(NSString *)imgName target:(id)target selector:(SEL)selector block:(void(^)(UIButton *btn))block{
    return  [self barButtonItemWithFrame:CGRectMake(0, 0, 44, 44) imgName:imgName imageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 20) target:target selector:selector block:block];
}

+ (UIBarButtonItem *)rightItemWithImgName:(NSString *)imgName target:(id)target selector:(SEL)selector{
    
    return  [self barButtonItemWithFrame:CGRectMake(0, 0, 44, 44) imgName:imgName imageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -20) target:target selector:selector];
    
}

+ (UIBarButtonItem *)rightItemWithImgName:(NSString *)imgName target:(id)target selector:(SEL)selector block:(void(^)(UIButton *btn))block{
    return  [self barButtonItemWithFrame:CGRectMake(0, 0, 44, 44) imgName:imgName imageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -20) target:target selector:selector block:block];
}

#pragma mark - Private

+ (UIButton *)barButtonWithFrame:(CGRect)frame imgName:(NSString *)imgName imageEdgeInsets:(UIEdgeInsets)imageEdgeInsets target:(id)target selector:(SEL)selector{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame = frame;
    [btn setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:18];
    btn.titleLabel.textColor = [UIColor whiteColor];
    [btn addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    btn.imageEdgeInsets = imageEdgeInsets;
    return btn;
}

+ (UIBarButtonItem *)barButtonItemWithFrame:(CGRect)frame imgName:(NSString *)imgName imageEdgeInsets:(UIEdgeInsets)imageEdgeInsets target:(id)target selector:(SEL)selector {
    
    UIButton *btn = [self barButtonWithFrame:frame imgName:imgName imageEdgeInsets:imageEdgeInsets target:target selector:selector];
    
    return  [[UIBarButtonItem alloc] initWithCustomView:btn];
}

+ (UIBarButtonItem *)barButtonItemWithFrame:(CGRect)frame imgName:(NSString *)imgName imageEdgeInsets:(UIEdgeInsets)imageEdgeInsets target:(id)target selector:(SEL)selector block:(void(^)(UIButton *btn))block{
    
    UIButton *btn = [self barButtonWithFrame:frame imgName:imgName imageEdgeInsets:imageEdgeInsets target:target selector:selector];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    if (block) {
        item.btnBlock = block;
        if (item.btnBlock) {
            item.btnBlock(btn);
        }
    }
    return  item;
}


+ (UIBarButtonItem *)barButtonItemWithFrame:(CGRect)frame title:(NSString *)title target:(id)target selector:(SEL)selector block:(void(^)(UIButton *btn))block{
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame = frame;
    [btn setTitle:title forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:18];
    btn.titleLabel.textColor = [UIColor whiteColor];
    [btn addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    if (block) {
        item.btnBlock = block;
        if (item.btnBlock) {
            item.btnBlock(btn);
        }
    }
    return  item;
}

@end
