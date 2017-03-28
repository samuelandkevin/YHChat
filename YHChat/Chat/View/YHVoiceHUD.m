//
//  YHVoiceHUD.m
//  YHChat
//
//  Created by samuelandkevin on 17/3/7.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "YHVoiceHUD.h"

@interface YHVoiceHUD ()
@property (nonatomic,strong)NSArray *images;

@end

@implementation YHVoiceHUD


- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.animationDuration    = 0.5;
        self.animationRepeatCount = -1;
        _images                   = @[
                                      [UIImage imageNamed:@"voice_1"],
                                      [UIImage imageNamed:@"voice_2"],
                                      [UIImage imageNamed:@"voice_3"],
                                      [UIImage imageNamed:@"voice_4"],
                                      [UIImage imageNamed:@"voice_5"],
                                      [UIImage imageNamed:@"voice_6"]
                                      ];
    }
    return self;
}

- (void)setProgress:(CGFloat)progress
{
    _progress         = MIN(MAX(progress, 0.f),1.f);
    [self updateImages];
}


- (void)updateImages
{
    if (_progress == 0) {
        self.animationImages = nil;
        [self stopAnimating];
        return;
    }
    if (_progress >= 0.8 ) {
        self.animationImages = @[_images[3],_images[4],_images[5],_images[4],_images[3]];
    } else if (_progress >= 0.7){
        self.animationImages = @[_images[0],_images[1],_images[2]];
    }else{
        self.animationImages = @[_images[0]];
    }
    [self startAnimating];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
