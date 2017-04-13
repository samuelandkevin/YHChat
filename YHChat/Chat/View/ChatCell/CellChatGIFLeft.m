//
//  CellChatGIFLeft.m
//  YHChat
//
//  Created by YHIOS002 on 17/4/11.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "CellChatGIFLeft.h"
#import "YHChatImageView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <Masonry/Masonry.h>
#import <HYBMasonryAutoCellHeight/UITableViewCell+HYBMasonryAutoCellHeight.h>
#import "YHChatModel.h"
#import "YHDownLoadManager.h"

@interface CellChatGIFLeft()
@property (nonatomic,strong) YYAnimatedImageView *imgvContent;
@property (nonatomic,strong) NSLayoutConstraint *cstWidthConetent;
@property (nonatomic,strong) NSLayoutConstraint *cstHeightConetent;
@end

@implementation CellChatGIFLeft

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
    
    _imgvContent = [YYAnimatedImageView new];
//    _imgvContent.isReceiver = NO;
    UIImage *oriImg = [UIImage imageNamed:@"chat_img_defaultPhoto"];
    _imgvContent.image = oriImg;
    _imgvContent.userInteractionEnabled = YES;
    [_imgvContent addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureOnContent:)]];
    [self.contentView addSubview:_imgvContent];
    _imgvContent.autoPlayAnimatedImage = NO;
    
//    WeakSelf
//    _imgvContent.retweetImageBlock = ^(UIImage *image){
//        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(retweetImage:inLeftCell:)]) {
//            [weakSelf.delegate retweetImage:image inLeftCell:weakSelf];
//        }
//    };
    
    [self layoutUI];
}

- (void)layoutUI{
    __weak typeof(self) weakSelf = self;
    [self layoutCommonUI];
    
    
    [self.lbName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.imgvAvatar.mas_right).offset(10);
    }];
    
    [self.imgvAvatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.btnCheckBox.mas_right).offset(5);
    }];
    
    
    _cstWidthConetent = [NSLayoutConstraint constraintWithItem:_imgvContent attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0];
    [self.contentView addConstraint:_cstWidthConetent];
    _cstHeightConetent = [NSLayoutConstraint constraintWithItem:_imgvContent attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0];
    [self.contentView addConstraint:_cstHeightConetent];
    [_imgvContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.lbName.mas_bottom).offset(5);
        make.left.equalTo(weakSelf.imgvAvatar.mas_right).offset(10);
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
    self.lbName.text    = self.model.speakerName;
    self.lbTime.text    = self.model.createTime;
    [self.imgvAvatar sd_setImageWithURL:self.model.speakerAvatar placeholderImage:[UIImage imageNamed:@"common_avatar_80px"]];
    
    //gif图片下载
    WeakSelf
    if (self.model.msgContent && self.model.msgType == 4) {
        
        YHGIFModel *gifModel = self.model.gifModel;
        _cstWidthConetent.constant  = gifModel.width;
        _cstHeightConetent.constant = gifModel.height;
        if (gifModel.status == FileStatus_HasDownLoaded) {
            weakSelf.imgvContent.image = [YYImage imageWithData:gifModel.animatedImageData];
        }else{
            NSURL *url = [NSURL URLWithString:self.model.gifModel.filePathInServer];
            [[YHDownLoadManager sharedInstance] downLoadAnimatedImageWithURL:url completion:^(NSData *animatedImageData) {
                weakSelf.imgvContent.image = [YYImage imageWithData:animatedImageData];
                weakSelf.model.gifModel.animatedImageData = animatedImageData;
            }];
        }
        
    }
    
}

#pragma mark - Public
- (void)startAnimating{
    [self.imgvContent startAnimating];
}

- (void)stopAnimating{
    [self.imgvContent stopAnimating];
}

#pragma mark - Private


#pragma mark - Gesture
- (void)gestureOnContent:(UIGestureRecognizer *)aGes{
    if (aGes.state == UIGestureRecognizerStateEnded) {
        
    }
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
