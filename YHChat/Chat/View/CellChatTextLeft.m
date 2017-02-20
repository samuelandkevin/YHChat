//
//  CellChatLeft.m
//  YHChat
//
//  Created by YHIOS002 on 17/2/17.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "CellChatTextLeft.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <Masonry/Masonry.h>
#import <HYBMasonryAutoCellHeight/UITableViewCell+HYBMasonryAutoCellHeight.h>
#import "YHChatModel.h"
@interface CellChatTextLeft()

@property (nonatomic,strong) UILabel *lbTime;
@property (nonatomic,strong) UIImageView *imgvAvatar;
@property (nonatomic,strong) UIImageView *imgvBubble;
@property (nonatomic,strong) UILabel *lbContent;

@end

#define AvatarWidth 44 //头像宽/高

@implementation CellChatTextLeft

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
    
    _imgvBubble = [UIImageView new];
    UIImage *imgBubble = [UIImage imageNamed:@"liaotianbeijing1"];
    imgBubble = [imgBubble resizableImageWithCapInsets:UIEdgeInsetsMake(30, 30, 30, 15) resizingMode:UIImageResizingModeStretch];

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
    
    [_lbTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf.contentView);
        make.top.equalTo(weakSelf.contentView.mas_top).offset(5);
    }];
    
    [_imgvAvatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(AvatarWidth);
        make.top.equalTo(weakSelf.lbTime.mas_bottom).offset(5);
        make.left.equalTo(weakSelf.contentView).offset(5);
    }];
    
    [_imgvBubble mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.imgvAvatar.mas_right).offset(10);
        make.top.equalTo(weakSelf.imgvAvatar.mas_top);
        make.right.equalTo(weakSelf.lbContent.mas_right).offset(5);
    }];
    
    [_lbContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.imgvBubble.mas_left).offset(15);
        make.top.equalTo(weakSelf.imgvBubble.mas_top).offset(5);
        make.bottom.equalTo(weakSelf.imgvBubble.mas_bottom).offset(-5);
        make.width.mas_lessThanOrEqualTo(SCREEN_WIDTH - 133);
    }];
    
    self.hyb_lastViewInCell = _imgvBubble;
    self.hyb_bottomOffsetToCell = 10;
}

#pragma mark - Gesture
- (void)onAvatarGesture:(UIGestureRecognizer *)aRec{
    if (aRec.state == UIGestureRecognizerStateEnded) {
        if (_delegate && [_delegate respondsToSelector:@selector(tapLeftAvatar:)]) {
            [_delegate tapLeftAvatar:nil];
        }
    }
}

#pragma mark - Public
- (void)setModel:(YHChatModel *)model{
    _model = model;
    _lbContent.text = _model.msgContent;
    _lbTime.text    = _model.createTime;
    [_imgvAvatar sd_setImageWithURL:_model.speakerAvatar placeholderImage:[UIImage imageNamed:@"common_avatar_80px"]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
