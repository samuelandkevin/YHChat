//
//  YHChatImageView.h
//  YHChat
//
//  Created by samuelandkevin on 17/3/22.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YHChatImageView : UIImageView

@property (nonatomic,copy) void(^retweetImageBlock)(UIImage *image);//转发图片
@property (nonatomic,copy) void(^withDrawImageBlock)(UIImage *image);//撤回图片

@property (nonatomic,copy) void(^retweetVoiceBlock)();//转发语音
@property (nonatomic,copy) void(^withDrawVoiceBlock)();//撤回语音

@property (nonatomic,assign) BOOL isReceiver;

@end
