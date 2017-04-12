//
//  CellChatGIFRight.m
//  YHChat
//
//  Created by YHIOS002 on 17/4/11.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "CellChatGIFRight.h"
#import "YHChatImageView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <Masonry/Masonry.h>
#import <HYBMasonryAutoCellHeight/UITableViewCell+HYBMasonryAutoCellHeight.h>
#import "YHChatModel.h"
#import "YHDownLoadManager.h"

@interface CellChatGIFRight()
@property (nonatomic,strong) YYAnimatedImageView *imgvContent;
@property (nonatomic,strong) NSLayoutConstraint  *cstWidthConetent;
@property (nonatomic,strong) NSLayoutConstraint  *cstHeightConetent;
@end

@implementation CellChatGIFRight

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
//    _imgvContent.isReceiver = YES;
    UIImage *oriImg = [UIImage imageNamed:@"chat_img_defaultPhoto"];
    _imgvContent.userInteractionEnabled = YES;
    _imgvContent.image = oriImg;
    [_imgvContent addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureOnContent:)]];
    [self.contentView addSubview:_imgvContent];
    
//    WeakSelf
//    _imgvContent.retweetImageBlock = ^(UIImage *image){
//        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(retweetImage:inRightCell:)]) {
//            [weakSelf.delegate retweetImage:image inRightCell:weakSelf];
//        }
//    };
//    
//    _imgvContent.withDrawImageBlock = ^(UIImage *image){
//        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(withDrawImage:inRightCell:)]) {
//            [weakSelf.delegate withDrawImage:image inRightCell:weakSelf];
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
