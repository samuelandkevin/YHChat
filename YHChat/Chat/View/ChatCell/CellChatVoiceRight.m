//
//  CellChatVoiceRight.m
//  YHChat
//
//  Created by samuelandkevin on 17/2/27.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "CellChatVoiceRight.h"
#import <Masonry/Masonry.h>
#import "YHChatModel.h"
#import <HYBMasonryAutoCellHeight/UITableViewCell+HYBMasonryAutoCellHeight.h>
#import "YHAudioPlayer.h"
#import "YHChatImageView.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface CellChatVoiceRight()

@property (nonatomic,strong) YHChatImageView *imgvBubble;
@property (nonatomic,strong) UIImageView *imgvVoiceIcon;
@property (nonatomic,strong) UILabel *lbDuration;
@end


@implementation CellChatVoiceRight

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    
    _imgvBubble = [YHChatImageView new];
    _imgvBubble.isReceiver = YES;
    UIImage *imgBubble = [UIImage imageNamed:@"chat_bubbleRight"];
    imgBubble = [imgBubble resizableImageWithCapInsets:UIEdgeInsetsMake(30, 15, 30, 30) resizingMode:UIImageResizingModeStretch];
    _imgvBubble.image = imgBubble;
    [self.contentView addSubview:_imgvBubble];
    _imgvBubble.userInteractionEnabled = YES;
    [_imgvBubble addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onGestureBubble:)]];
    
    
    WeakSelf
    
    _imgvBubble.retweetVoiceBlock = ^(){
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(retweetVoice:inRightCell:)]) {
            NSString *voicePath = [weakSelf voicePath];
            [weakSelf.delegate retweetVoice:voicePath inRightCell:weakSelf];
        }
    };
    
    _imgvBubble.withDrawVoiceBlock = ^(){
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(withDrawVoice:inRightCell:)]) {
            NSString *voicePath = [weakSelf voicePath];
            [weakSelf.delegate withDrawVoice:voicePath inRightCell:weakSelf];
        }
    };
    
    
    _imgvVoiceIcon = [UIImageView new];
    _imgvVoiceIcon.image = [UIImage imageNamed:@"right-3"];
    UIImage *image1 = [UIImage imageNamed:@"right-1"];
    UIImage *image2 = [UIImage imageNamed:@"right-2"];
    UIImage *image3 = [UIImage imageNamed:@"right-3"];
    _imgvVoiceIcon.animationDuration = 0.8;
    _imgvVoiceIcon.animationImages = @[image1, image2, image3];
    [self.contentView addSubview:_imgvVoiceIcon];
    
    _lbDuration = [UILabel new];
    _lbDuration.textAlignment = NSTextAlignmentRight;
    _lbDuration.font = [UIFont systemFontOfSize:12.0f];
    [self.contentView addSubview:_lbDuration];
    
    [self layoutUI];
}

- (void)layoutUI{
    __weak typeof(self) weakSelf = self;
    [self layoutCommonUI];

    [self.lbName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf.imgvAvatar.mas_left).offset(-10);
    }];
    
    [self.imgvAvatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf.contentView).offset(-5);
    }];
    
    [_imgvBubble mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.lbName.mas_bottom).offset(5);
        make.right.equalTo(weakSelf.imgvAvatar.mas_left).offset(-5);
        make.size.mas_equalTo(CGSizeMake(113, 40));
    }];
    
    [self.activityV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakSelf.imgvBubble.mas_centerY);
        make.right.equalTo(weakSelf.imgvBubble.mas_left).offset(-5);
        make.width.height.mas_equalTo(20);
    }];
    
    [self.imgvSendMsgFail mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakSelf.imgvBubble.mas_centerY);
        make.right.equalTo(weakSelf.imgvBubble.mas_left).offset(-5);
        make.width.height.mas_equalTo(20);
    }];
    
    [_imgvVoiceIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf.imgvBubble.mas_right).offset(-15);
        make.centerY.equalTo(weakSelf.imgvBubble.mas_centerY);
    }];
    
    [_lbDuration mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf.imgvBubble.mas_left).offset(-5);
        make.centerY.equalTo(weakSelf.imgvBubble.mas_centerY);
    }];
    
    self.hyb_lastViewInCell = _imgvBubble;
    self.hyb_bottomOffsetToCell = 5;
    
}


#pragma mark - Public
- (void)voiceImageBeginAnimation{
    [_imgvVoiceIcon startAnimating];

}
- (void)voiceImageStopAnimation{
    [_imgvVoiceIcon stopAnimating];
}

#pragma mark - Super

- (void)onAvatarGesture:(UIGestureRecognizer *)aRec{
    [super onAvatarGesture:aRec];
    //    if (aRec.state == UIGestureRecognizerStateEnded) {
    //        if (_delegate && [_delegate respondsToSelector:@selector(tapRightAvatar:)]) {
    //            [_delegate tapRightAvatar:nil];
    //        }
    //    }
}

- (void)onImgSendMsgFailGesture:(UIGestureRecognizer *)aRec{
    [super onImgSendMsgFailGesture:aRec];
    //    if (aRec.state == UIGestureRecognizerStateEnded) {
    //        if(_delegate && [_delegate respondsToSelector:@selector(tapSendMsgFailImg)]){
    //            [_delegate tapSendMsgFailImg];
    //        }
    //    }
}

#pragma mark - Private
- (NSString *)voicePath{
    WeakSelf
    NSString *path = weakSelf.model.msgContent;
    path = [path stringByReplacingOccurrencesOfString:@"voice[" withString:@""];
    path = [path stringByReplacingOccurrencesOfString:@"]" withString:@""];
    return path;
}

#pragma mark - Gesture
- (void)onGestureBubble:(UIGestureRecognizer *)aRec{
    if (aRec.state == UIGestureRecognizerStateEnded){
        if (_delegate && [_delegate respondsToSelector:@selector(playInRightCellWithVoicePath:)]) {
            NSString *voicePath = [self voicePath];
            [_delegate playInRightCellWithVoicePath:voicePath];
            
            
            //播放录音
            [_imgvVoiceIcon startAnimating];
            WeakSelf
            [[YHAudioPlayer shareInstanced] playWithUrlString:voicePath progress:^(float progress) {
                if (progress == 1) {
                    DDLog(@"finish playing");
                }
                [weakSelf.imgvVoiceIcon stopAnimating];
            }];
        }
    }
}

- (void)setupModel:(YHChatModel *)model{
    [super setupModel:model];
    self.lbName.text = self.model.speakerName;
    self.lbTime.text = self.model.createTime;
    [self.imgvAvatar sd_setImageWithURL:self.model.speakerAvatar placeholderImage:[UIImage imageNamed:@"common_avatar_80px"]];
//    _lbDuration.text = @"1 '";
}

#pragma mark - Life
- (void)dealloc{
    //DDLog(@"%s dealloc",__func__);
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
