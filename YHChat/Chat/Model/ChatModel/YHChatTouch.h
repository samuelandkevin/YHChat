//
//  YHChatTouch.h
//  PikeWay
//
//  Created by YHIOS002 on 2018/4/27.
//  Copyright © 2018年 YHSoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class YHChatListModel;
@class YHChatListVC;

@interface YHChatTouch : NSObject
+ (void)registerForPreviewInVC:(YHChatListVC *)vc sourceView:(UIView *)sourceView model:(YHChatListModel *)model;

@end
