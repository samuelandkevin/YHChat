//
//  CellChatVoiceRight.h
//  YHChat
//
//  Created by samuelandkevin on 17/2/27.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CellChatBase.h"


@class CellChatVoiceRight;
@protocol CellChatVoiceRightDelegate <NSObject>

- (void)playInRightCellWithVoicePath:(NSString *)voicePath;

@optional
- (void)retweetVoice:(NSString *)voicePath inRightCell:(CellChatVoiceRight *)rightCell;//转发语音
- (void)withDrawVoice:(NSString *)voicePath inRightCell:(CellChatVoiceRight *)rightCell;//撤回语音

@end

@interface CellChatVoiceRight : CellChatBase
@property (nonatomic,weak)id<CellChatVoiceRightDelegate>delegate;

- (void)voiceImageBeginAnimation;
- (void)voiceImageStopAnimation;
@end
