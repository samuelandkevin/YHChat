//
//  CellChatVoiceLeft.m
//  YHChat
//
//  Created by YHIOS002 on 17/2/27.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "CellChatVoiceLeft.h"
#import <Masonry/Masonry.h>
#import <HYBMasonryAutoCellHeight/UITableViewCell+HYBMasonryAutoCellHeight.h>
#import "YHChatModel.h"

@interface CellChatVoiceLeft()

@property (nonatomic,strong) UIImageView *imgvBubble;
@property (nonatomic,strong) UILabel *lbDuration;
@property (nonatomic,strong) UIImageView *imgvVoiceIcon;
@end


@implementation CellChatVoiceLeft


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
    
    _imgvBubble = [UIImageView new];
    UIImage *imgBubble = [UIImage imageNamed:@"chat_bubbleLeft"];
    imgBubble = [imgBubble resizableImageWithCapInsets:UIEdgeInsetsMake(30, 30, 30, 15) resizingMode:UIImageResizingModeStretch];
    _imgvBubble.image = imgBubble;
    [self.contentView addSubview:_imgvBubble];
    _imgvBubble.userInteractionEnabled = YES;
    [_imgvBubble addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onGestureBubble:)]];
    
    _imgvVoiceIcon = [UIImageView new];
    _imgvVoiceIcon.image = [UIImage imageNamed:@"left-3"];
    UIImage *image1 = [UIImage imageNamed:@"left-1"];
    UIImage *image2 = [UIImage imageNamed:@"left-2"];
    UIImage *image3 = [UIImage imageNamed:@"left-3"];
    _imgvVoiceIcon.animationImages = @[image1, image2, image3];
    [self.contentView addSubview:_imgvVoiceIcon];
    
    _lbDuration = [UILabel new];
    _lbDuration.textAlignment = NSTextAlignmentLeft;
    _lbDuration.font = [UIFont systemFontOfSize:12.0f];
    [self.contentView addSubview:_lbDuration];
    
    [self layoutUI];
}

- (void)layoutUI{
    __weak typeof(self) weakSelf = self;
    
    [self.lbTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf.contentView);
        make.top.equalTo(weakSelf.contentView.mas_top).offset(5);
    }];
    
    [self.imgvAvatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(kAvatarWidth);
        make.top.equalTo(weakSelf.lbTime.mas_bottom).offset(5);
        make.left.equalTo(weakSelf.contentView).offset(5);
    }];
    
    [_imgvBubble mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.imgvAvatar.mas_top);
        make.left.equalTo(weakSelf.imgvAvatar.mas_right).offset(10);
        make.size.mas_equalTo(CGSizeMake(113, 40));
    }];
    
    [_imgvVoiceIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.imgvBubble.mas_left).offset(15);
        make.centerY.equalTo(weakSelf.imgvBubble.mas_centerY);
    }];
    
    [_lbDuration mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.imgvBubble.mas_right).offset(5);
        make.centerY.mas_equalTo(weakSelf.imgvBubble.mas_centerY);
    }];
    
    self.hyb_lastViewInCell = _imgvBubble;
    self.hyb_bottomOffsetToCell = 5;
    
}

#pragma mark - Super

- (void)onAvatarGesture:(UIGestureRecognizer *)aRec{
    [super onAvatarGesture:aRec];
    //    if (aRec.state == UIGestureRecognizerStateEnded) {
    //        if (_delegate && [_delegate respondsToSelector:@selector(tapLeftAvatar:)]) {
    //            [_delegate tapLeftAvatar:nil];
    //        }
    //    }
}

#pragma mark - Gesture
- (void)onGestureBubble:(UIGestureRecognizer *)aRec{
    if (aRec.state == UIGestureRecognizerStateEnded){
        if (_delegate && [_delegate respondsToSelector:@selector(playInLeftCellWithVoicePath:)]) {
            NSString *voicePath = self.model.msgContent;
            voicePath = [voicePath stringByReplacingOccurrencesOfString:@"voice[" withString:@""];
            voicePath = [voicePath stringByReplacingOccurrencesOfString:@"]" withString:@""];
            [_delegate playInLeftCellWithVoicePath:voicePath];
        }
    }
}


- (void)setupModel:(YHChatModel *)model{
    [super setupModel:model];
    self.lbTime.text = self.model.createTime;
    _lbDuration.text = @"1 '";
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
