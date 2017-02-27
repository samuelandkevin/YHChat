//
//  CellChatRight.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 17/2/17.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "CellChatTextRight.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <Masonry/Masonry.h>
#import <HYBMasonryAutoCellHeight/UITableViewCell+HYBMasonryAutoCellHeight.h>
#import "YHChatModel.h"

@interface CellChatTextRight()

@property (nonatomic,strong) UIImageView *imgvBubble;
@property (nonatomic,strong) UILabel *lbContent;

@end


@implementation CellChatTextRight

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
    UIImage *imgBubble = [UIImage imageNamed:@"chat_bubbleRight"];
    imgBubble = [imgBubble resizableImageWithCapInsets:UIEdgeInsetsMake(30, 15, 30, 30) resizingMode:UIImageResizingModeStretch];
    
    _imgvBubble.image = imgBubble;
    [self.contentView addSubview:_imgvBubble];
    
    _lbContent = [UILabel new];
    _lbContent.numberOfLines = 0;
    
    //-5-AvatarWidth-10-15-5-10-AvatarWidth
    _lbContent.preferredMaxLayoutWidth = SCREEN_WIDTH - 133;
    _lbContent.textColor = [UIColor blackColor];
    _lbContent.textAlignment = NSTextAlignmentLeft;
    _lbContent.font = [UIFont systemFontOfSize:14.0];
    [self.contentView addSubview:_lbContent];
    
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
        make.right.equalTo(weakSelf.contentView).offset(-5);
    }];
    
    [_imgvBubble mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.lbContent.mas_left).offset(-5);
        make.top.equalTo(weakSelf.imgvAvatar.mas_top);
        make.right.equalTo(weakSelf.imgvAvatar.mas_left).offset(-10);
    }];
    

    [_lbContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.imgvBubble.mas_top).offset(5);
        make.right.equalTo(weakSelf.imgvBubble.mas_right).offset(-15);
        make.bottom.equalTo(weakSelf.imgvBubble.mas_bottom).offset(-5);
        make.width.mas_lessThanOrEqualTo(SCREEN_WIDTH - 133);
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
    
    self.hyb_lastViewInCell = _imgvBubble;
    self.hyb_bottomOffsetToCell = 5;
}


#pragma mark - Super

- (void)onAvatarGesture:(UIGestureRecognizer *)aRec{
    [super onAvatarGesture:aRec];
    if (aRec.state == UIGestureRecognizerStateEnded) {
        if (_delegate && [_delegate respondsToSelector:@selector(tapRightAvatar:)]) {
            [_delegate tapRightAvatar:nil];
        }
    }
}

- (void)onImgSendMsgFailGesture:(UIGestureRecognizer *)aRec{
    [super onImgSendMsgFailGesture:aRec];
    if (aRec.state == UIGestureRecognizerStateEnded) {
        if(_delegate && [_delegate respondsToSelector:@selector(tapSendMsgFailImg)]){
            [_delegate tapSendMsgFailImg];
        }
    }
}

- (void)setupModel:(YHChatModel *)model{
    [super setupModel:model];
    _lbContent.text = self.model.msgContent;
    self.lbTime.text    = self.model.createTime;
    [self.imgvAvatar sd_setImageWithURL:self.model.speakerAvatar placeholderImage:[UIImage imageNamed:@"common_avatar_80px"]];
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
