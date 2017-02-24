//
//  CellChatImageRight.m
//  YHChat
//
//  Created by YHIOS002 on 17/2/22.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "CellChatImageRight.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <Masonry/Masonry.h>
#import <HYBMasonryAutoCellHeight/UITableViewCell+HYBMasonryAutoCellHeight.h>
#import "YHChatModel.h"
#import "UIImage+Extension.h"

@interface CellChatImageRight()

@property (nonatomic,strong) UILabel *lbTime;
@property (nonatomic,strong) UIImageView *imgvAvatar;
@property (nonatomic,strong) UIImageView *imgvContent;
@property (nonatomic,strong) UIActivityIndicatorView *activityV;
@property (nonatomic,strong) UIImageView *imgvSendMsgFail;

@end

#define AvatarWidth 44 //头像宽/高

@implementation CellChatImageRight

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
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = RGBCOLOR(239, 236, 236);
    
    _lbTime = [UILabel new];
    _lbTime.textColor = [UIColor whiteColor];
    _lbTime.layer.cornerRadius  = 3;
    _lbTime.layer.masksToBounds = YES;
    _lbTime.backgroundColor = [UIColor grayColor];
    _lbTime.textAlignment = NSTextAlignmentCenter;
    _lbTime.font = [UIFont systemFontOfSize:12.0];
    [self.contentView addSubview:_lbTime];
    
    _imgvAvatar = [UIImageView new];
    _imgvAvatar.userInteractionEnabled = YES;
    [_imgvAvatar addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onAvatarGesture:)]];
    _imgvAvatar.layer.cornerRadius = AvatarWidth/2.0;
    _imgvAvatar.layer.masksToBounds = YES;
    _imgvAvatar.image = [UIImage imageNamed:@"common_avatar_80px"];
    [self.contentView addSubview:_imgvAvatar];
    
    _imgvContent = [UIImageView new];
    UIImage *oriImg = [UIImage imageNamed:@"chat_img_defaultPhoto"];
    _imgvContent.image = [UIImage imageArrowWithSize:oriImg.size image:oriImg isSender:YES];
    [self.contentView addSubview:_imgvContent];
    
    
    _activityV = [UIActivityIndicatorView new];
    _activityV.hidden = YES;
    [self.contentView addSubview:_activityV];
    
    _imgvSendMsgFail = [UIImageView new];
    _imgvSendMsgFail.userInteractionEnabled = YES;
    [_imgvSendMsgFail addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onImgSendMsgFailGesture:)]];
    _imgvSendMsgFail.hidden = YES;
    _imgvSendMsgFail.image = [UIImage imageNamed:@"button_retry_comment"];
    [self.contentView addSubview:_imgvSendMsgFail];
    
    [self layoutUI];
}

- (void)layoutUI{
    __weak typeof(self) weakSelf = self;
    
    [_lbTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf.contentView);
        make.top.equalTo(weakSelf.contentView.mas_top).offset(5);
    }];
    
    [_imgvAvatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(AvatarWidth);
        make.top.equalTo(weakSelf.lbTime.mas_bottom).offset(5);
        make.right.equalTo(weakSelf.contentView).offset(-5);
    }];
    
    [_imgvContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.imgvAvatar.mas_top);
        make.right.equalTo(weakSelf.imgvAvatar.mas_left).offset(-10);
        make.size.mas_equalTo(CGSizeMake(113, 113));
    }];
    
    [_activityV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakSelf.imgvContent.mas_centerY);
        make.right.equalTo(weakSelf.imgvContent.mas_left).offset(-5);
        make.width.height.mas_equalTo(20);
    }];
    
    [_imgvSendMsgFail mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakSelf.imgvContent.mas_centerY);
        make.right.equalTo(weakSelf.imgvContent.mas_left).offset(-5);
        make.width.height.mas_equalTo(20);
    }];
    
    self.hyb_lastViewInCell = _imgvContent;
    self.hyb_bottomOffsetToCell = 5;
}

#pragma mark - Gesture
- (void)onAvatarGesture:(UIGestureRecognizer *)aRec{
//    if (aRec.state == UIGestureRecognizerStateEnded) {
//        if (_delegate && [_delegate respondsToSelector:@selector(tapRightAvatar:)]) {
//            [_delegate tapRightAvatar:nil];
//        }
//    }
}

- (void)onImgSendMsgFailGesture:(UIGestureRecognizer *)aRec{
//    if (aRec.state == UIGestureRecognizerStateEnded) {
//        if(_delegate && [_delegate respondsToSelector:@selector(tapSendMsgFailImg)]){
//            [_delegate tapSendMsgFailImg];
//        }
//    }
}

#pragma mark - Public
- (void)setModel:(YHChatModel *)model{
    _model = model;

    _lbTime.text    = _model.createTime;
    [_imgvAvatar sd_setImageWithURL:_model.speakerAvatar placeholderImage:[UIImage imageNamed:@"common_avatar_80px"]];
    
    //消息图片下载
    if (_model.msgContent && _model.msgType == 1) {
        NSString *picUrlStr = [_model.msgContent stringByReplacingOccurrencesOfString:@"img[" withString:@""];
        picUrlStr = [picUrlStr stringByReplacingOccurrencesOfString:@"]" withString:@""];
        NSURL *url = [NSURL URLWithString:picUrlStr];
        [_imgvContent sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"chat_img_defaultPhoto"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        
            [self updateImageCellHeightWith:image maxSize:CGSizeMake(200, 200)];
        }];
    }
}

//更新Cell高度
- (void)updateImageCellHeightWith:(UIImage *)image maxSize:(CGSize)maxSize{
     WeakSelf
    CGSize size = [UIImage handleImgSize:image.size maxSize:maxSize];
    image = [UIImage imageArrowWithSize:size image:image isSender:YES];
    weakSelf.imgvContent.image = image;
    
    [_imgvContent mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.imgvAvatar.mas_top);
        make.right.equalTo(weakSelf.imgvAvatar.mas_left).offset(-10);
        make.size.mas_equalTo(image.size);
    }];
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


@end
