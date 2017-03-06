//
//  CellChatVoiceRight.h
//  YHChat
//
//  Created by YHIOS002 on 17/2/27.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CellChatBase.h"


@class CellChatVoiceRight;
@protocol CellChatVoiceRightDelegate <NSObject>

- (void)playInRightCellWithVoicePath:(NSString *)voicePath;

@end

@interface CellChatVoiceRight : CellChatBase
@property (nonatomic,weak)id<CellChatVoiceRightDelegate>delegate;

- (void)voiceImageBeginAnimation;
- (void)voiceImageStopAnimation;
@end
