//
//  CellChatVoiceLeft.h
//  YHChat
//
//  Created by samuelandkevin on 17/2/27.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CellChatBase.h"

@class CellChatVoiceLeft;
@protocol CellChatVoiceLeftDelegate <NSObject>

- (void)playInLeftCellWithVoicePath:(NSString *)voicePath;

@optional
- (void)retweetVoice:(NSString *)voicePath inLeftCell:(CellChatVoiceLeft *)leftCell;//转发语音

@end

@interface CellChatVoiceLeft : CellChatBase
@property (nonatomic,weak)id<CellChatVoiceLeftDelegate>delegate;
@end
