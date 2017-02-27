//
//  CellChatImageLeft.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 17/2/22.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "CellChatImageLeft.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <Masonry/Masonry.h>
#import <HYBMasonryAutoCellHeight/UITableViewCell+HYBMasonryAutoCellHeight.h>
#import "YHChatModel.h"
#import "UIImage+Extension.h"

@interface CellChatImageLeft()
@property (nonatomic,strong) UIImageView *imgvContent;
@end



@implementation CellChatImageLeft

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
    
    _imgvContent = [UIImageView new];
    UIImage *oriImg = [UIImage imageNamed:@"chat_img_defaultPhoto"];
    _imgvContent.image = [UIImage imageArrowWithSize:oriImg.size image:oriImg isSender:NO];
    [self.contentView addSubview:_imgvContent];
    
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
    
    [_imgvContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.imgvAvatar.mas_top);
        make.left.equalTo(weakSelf.imgvAvatar.mas_right).offset(10);
        make.size.mas_equalTo(CGSizeMake(113, 113));
    }];
    
    self.hyb_lastViewInCell = _imgvContent;
    self.hyb_bottomOffsetToCell = 10;
}

#pragma mark - Super

- (void)onAvatarGesture:(UIGestureRecognizer *)aRec{
    //    if (aRec.state == UIGestureRecognizerStateEnded) {
    //        if (_delegate && [_delegate respondsToSelector:@selector(tapLeftAvatar:)]) {
    //            [_delegate tapLeftAvatar:nil];
    //        }
    //    }
}

- (void)setupModel:(YHChatModel *)model{
    [super setupModel:model];
    self.lbTime.text    = self.model.createTime;
    [self.imgvAvatar sd_setImageWithURL:self.model.speakerAvatar placeholderImage:[UIImage imageNamed:@"common_avatar_80px"]];
    
    //消息图片下载
    if (self.model.msgContent && self.model.msgType == 1) {
        NSString *picUrlStr = [self.model.msgContent stringByReplacingOccurrencesOfString:@"img[" withString:@""];
        picUrlStr = [picUrlStr stringByReplacingOccurrencesOfString:@"]" withString:@""];
        NSURL *url = [NSURL URLWithString:picUrlStr];
        [_imgvContent sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"chat_img_defaultPhoto"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            
            [self updateImageCellHeightWith:image maxSize:CGSizeMake(200, 200)];
        }];
    }

}

- (void)updateImageCellHeightWith:(UIImage *)image maxSize:(CGSize)maxSize{
    WeakSelf
    CGSize size = [UIImage handleImgSize:image.size maxSize:maxSize];
    image = [UIImage imageArrowWithSize:size image:image isSender:NO];
    weakSelf.imgvContent.image = image;
    
    
    [_imgvContent mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.imgvAvatar.mas_top);
        make.left.equalTo(weakSelf.imgvAvatar.mas_right).offset(10);
        make.size.mas_equalTo(image.size);
    }];
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
