//
//  CellChatBase.m
//  YHChat
//
//  Created by YHIOS002 on 17/2/27.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "CellChatBase.h"
#import <Masonry/Masonry.h>
@interface CellChatBase()

@end

const float kAvatarWidth = 44.0f;//头像宽/高
@implementation CellChatBase


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        [self setupUI1];
    }
    return self;
}

- (void)setupUI1{
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = RGBCOLOR(239, 236, 236);
    
    _viewTimeBG = [UIView new];
    _viewTimeBG.backgroundColor = [UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1.0];
    [self.contentView addSubview:_viewTimeBG];
    
    _lbTime = [UILabel new];
    _lbTime.textColor = [UIColor whiteColor];
    _lbTime.textAlignment = NSTextAlignmentCenter;
    _lbTime.font = [UIFont systemFontOfSize:14.0];
    [_viewTimeBG addSubview:_lbTime];
    
    
    _lbName = [UILabel new];
    _lbName.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
    _lbName.font = [UIFont systemFontOfSize:14.0];
    [self.contentView addSubview:_lbName];
    
    
    _imgvAvatar = [UIImageView new];
    _imgvAvatar.userInteractionEnabled = YES;
    [_imgvAvatar addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onAvatarGesture:)]];
    _imgvAvatar.layer.cornerRadius = kAvatarWidth/2.0;
    _imgvAvatar.layer.masksToBounds = YES;
    _imgvAvatar.image = [UIImage imageNamed:@"common_avatar_80px"];
    [self.contentView addSubview:_imgvAvatar];
    
    
    _activityV = [UIActivityIndicatorView new];
    _activityV.hidden = YES;
    [self.contentView addSubview:_activityV];
    
    _imgvSendMsgFail = [UIImageView new];
    _imgvSendMsgFail.userInteractionEnabled = YES;
    [_imgvSendMsgFail addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onImgSendMsgFailGesture:)]];
    _imgvSendMsgFail.hidden = YES;
    _imgvSendMsgFail.image = [UIImage imageNamed:@"button_retry_comment"];
    [self.contentView addSubview:_imgvSendMsgFail];

    [self layoutCommonUI];
}

- (void)layoutCommonUI{
    WeakSelf
    [self.lbTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(weakSelf.viewTimeBG);
    }];
    
    [self.viewTimeBG mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.lbTime.mas_left).offset(-10);
        make.top.equalTo(weakSelf.lbTime.mas_top).offset(-10);
        make.right.equalTo(weakSelf.lbTime.mas_right).offset(10);
        make.bottom.equalTo(weakSelf.lbTime.mas_bottom).offset(10);
        make.centerX.equalTo(weakSelf.contentView.mas_centerX);
        make.top.equalTo(weakSelf.contentView.mas_top).offset(5);
    }];
    
    [self.lbName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.imgvAvatar.mas_top);
    }];
    
    [self.imgvAvatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(kAvatarWidth);
        make.top.equalTo(weakSelf.viewTimeBG.mas_bottom).offset(5);
    }];
    

}


#pragma mark - Gesture
- (void)onAvatarGesture:(UIGestureRecognizer *)aRec{
    if (aRec.state == UIGestureRecognizerStateEnded) {
        
    }
}

- (void)onImgSendMsgFailGesture:(UIGestureRecognizer *)aRec{
    if (aRec.state == UIGestureRecognizerStateEnded) {
        
    }
}

#pragma mark - Public Method
- (void)setupModel:(YHChatModel *)model{
    self.model = model;
}

#pragma mark - Life
- (void)dealloc{
    //DDLog(@"%s dealloc",__func__);
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
