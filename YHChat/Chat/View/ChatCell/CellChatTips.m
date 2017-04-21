//
//  CellChatTips.m
//  YHChat
//
//  Created by samuelandkevin on 17/3/16.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "CellChatTips.h"
#import <Masonry/Masonry.h>
#import <HYBMasonryAutoCellHeight/UITableViewCell+HYBMasonryAutoCellHeight.h>

@interface CellChatTips()
@property (nonatomic,strong) UILabel *lbTime;    //发言时间
@property (nonatomic,strong) UIView  *viewTimeBG;//发言时间背景
@property (nonatomic,strong) UILabel *lbContent; //提示信息
@property (nonatomic,strong) UIView  *viewContentBG;//内容背景
@end

@implementation CellChatTips

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
    
    _viewTimeBG = [UIView new];
    _viewTimeBG.backgroundColor = [UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1.0];
    [self.contentView addSubview:_viewTimeBG];
    
    _lbTime = [UILabel new];
    _lbTime.textColor = [UIColor whiteColor];
    _lbTime.textAlignment = NSTextAlignmentCenter;
    _lbTime.font = [UIFont systemFontOfSize:14.0];
    [_viewTimeBG addSubview:_lbTime];
    
    
    _viewContentBG = [UIView new];
    _viewContentBG.backgroundColor = [UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1.0];
    [self.contentView addSubview:_viewContentBG];
    
    _lbContent = [UILabel new];
    _lbContent.textColor = [UIColor whiteColor];
    _lbContent.textAlignment = NSTextAlignmentCenter;
    _lbContent.font = [UIFont systemFontOfSize:14.0];
    [_viewContentBG addSubview:_lbContent];
    
    [self layoutUI];
}

- (void)layoutUI{
    WeakSelf
    [_lbTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(weakSelf.viewTimeBG);
    }];
    
    [_viewTimeBG mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.lbTime.mas_left).offset(-5);
        make.top.equalTo(weakSelf.lbTime.mas_top).offset(-5);
        make.right.equalTo(weakSelf.lbTime.mas_right).offset(5);
        make.bottom.equalTo(weakSelf.lbTime.mas_bottom).offset(5);
        make.centerX.equalTo(weakSelf.contentView.mas_centerX);
        make.top.equalTo(weakSelf.contentView.mas_top).offset(5);
    }];
    
    
    [_lbContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(weakSelf.viewContentBG);
    }];
    
    [_viewContentBG mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.lbContent.mas_left).offset(-10);
        make.top.equalTo(weakSelf.lbContent.mas_top).offset(-10);
        make.right.equalTo(weakSelf.lbContent.mas_right).offset(10);
        make.bottom.equalTo(weakSelf.lbContent.mas_bottom).offset(10);
        make.centerX.equalTo(weakSelf.contentView.mas_centerX);
        make.top.equalTo(weakSelf.viewTimeBG.mas_bottom).offset(5);
    }];
    
    self.hyb_lastViewInCell = _viewContentBG;
    self.hyb_bottomOffsetToCell = 5;
}

#pragma mark - Setter
- (void)setModel:(YHChatModel *)model{
    _model = model;
    NSString *name = model.speakerName;
    if ([model.speakerId isEqualToString:MYUID]) {
        name = @"你";
    }
    _lbContent.text = [NSString stringWithFormat:@"%@撤回了一条消息",name];
    _lbTime.text    = self.model.createTime;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
