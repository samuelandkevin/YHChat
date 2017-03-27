//
//  CellChatList.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 17/2/20.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "CellChatList.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <Masonry/Masonry.h>
#import "YHChatListModel.h"
#import "YHGroupIconView.h"

@interface CellChatList()

@property (nonatomic,strong) UILabel *lbTime;
@property (nonatomic,strong) UILabel *lbName;
@property (nonatomic,strong) UIImageView *imgvAvatar;
@property (nonatomic,strong) UILabel *lbContent;
@property (nonatomic,strong) UILabel *lbNewMsg;
@property (nonatomic,strong) UIView  *viewBotLine;
@property (nonatomic,strong) YHGroupIconView *imgvGroupIcon;
@end


@implementation CellChatList

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
    
    _imgvAvatar = [UIImageView new];
    _imgvAvatar.userInteractionEnabled = YES;
    [_imgvAvatar addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onAvatarGesture:)]];
    _imgvAvatar.layer.cornerRadius = 44.0/2.0;
    _imgvAvatar.layer.masksToBounds = YES;
    _imgvAvatar.image = [UIImage imageNamed:@"common_avatar_80px"];
    [self.contentView addSubview:_imgvAvatar];
    
    _imgvGroupIcon = [YHGroupIconView new];
    _imgvGroupIcon.layer.cornerRadius = 2;
    _imgvGroupIcon.layer.masksToBounds = YES;
    _imgvGroupIcon.backgroundColor = RGBCOLOR(221, 222, 224);
    [self.contentView addSubview:_imgvGroupIcon];
    
    
    _lbNewMsg = [UILabel new];
    _lbNewMsg.backgroundColor = [UIColor redColor];
    _lbNewMsg.textAlignment = NSTextAlignmentCenter;
    _lbNewMsg.textColor = [UIColor whiteColor];
    [self.contentView addSubview:_lbNewMsg];
    
    _lbTime = [UILabel new];
    _lbTime.textColor = [UIColor grayColor];
    _lbTime.textAlignment = NSTextAlignmentRight;
    _lbTime.font = [UIFont systemFontOfSize:12.0];
    [self.contentView addSubview:_lbTime];
    
    _lbName = [UILabel new];
    _lbName.textColor = [UIColor blackColor];
    _lbName.textAlignment = NSTextAlignmentLeft;
    _lbName.font = [UIFont systemFontOfSize:14.0];
    [self.contentView addSubview:_lbName];
    
    

    _lbContent = [UILabel new];
    
    //-5-AvatarWidth-10-15-5-10-AvatarWidth
    _lbContent.preferredMaxLayoutWidth = SCREEN_WIDTH - 133;
    _lbContent.textColor = [UIColor blackColor];
    _lbContent.textAlignment = NSTextAlignmentLeft;
    _lbContent.font = [UIFont systemFontOfSize:14.0];
    [self.contentView addSubview:_lbContent];
    
    
    _viewBotLine = [UIView new];
    _viewBotLine.backgroundColor = RGBCOLOR(222, 222, 222);
    [self.contentView addSubview:_viewBotLine];
    
    [self layoutUI];
}

- (void)layoutUI{
    __weak typeof(self) weakSelf = self;
    
    
    [_imgvAvatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(44);
        make.top.equalTo(weakSelf.contentView).offset(10);
        make.left.equalTo(weakSelf.contentView).offset(10);
    }];
    
    [_imgvGroupIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(44);
        make.top.equalTo(weakSelf.contentView).offset(10);
        make.left.equalTo(weakSelf.contentView).offset(10);
    }];
    
    [_lbName setContentHuggingPriority:249 forAxis:UILayoutConstraintAxisHorizontal];
    [_lbName setContentHuggingPriority:749 forAxis:UILayoutConstraintAxisHorizontal];
    
    [_lbName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.imgvAvatar.mas_right).offset(10);
        make.top.equalTo(weakSelf.imgvAvatar.mas_top);
        make.right.equalTo(weakSelf.lbTime.mas_left);
    }];
    
    [_lbTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf.contentView).offset(-5);
        make.top.equalTo(weakSelf.lbName.mas_top);
    }];
    
    
    [_lbContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.imgvAvatar.mas_right).offset(10);
        make.top.equalTo(weakSelf.lbName.mas_bottom).offset(5);
        make.right.equalTo(weakSelf.contentView.mas_right).offset(-15);
    }];
    
    [_viewBotLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(weakSelf.contentView);
        make.height.mas_equalTo(0.5);
    }];
    
}

#pragma mark - Gesture
- (void)onAvatarGesture:(UIGestureRecognizer *)aRec{
    if (aRec.state == UIGestureRecognizerStateEnded) {
      
    }
}

#pragma mark - Setter
- (void)setModel:(YHChatListModel *)model{
    _model = model;
    _lbName.text = _model.sessionUserName;
    
    _lbContent.text = _model.lastContent;
    _lbTime.text    = _model.lastCreatTime;
    if (_model.isGroupChat) {
        _imgvGroupIcon.picUrlArray = _model.sessionUserHead;
        _imgvGroupIcon.hidden = NO;
        _imgvAvatar.hidden = YES;
    }else{
        [_imgvAvatar sd_setImageWithURL:_model.sessionUserHead[0] placeholderImage:[UIImage imageNamed:@"common_avatar_80px"]];
        _imgvAvatar.hidden = NO;
        _imgvGroupIcon.hidden = YES;
    }
    
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
