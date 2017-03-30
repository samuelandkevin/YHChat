//
//  CellDocument.m
//  YHChat
//
//  Created by samuelandkevin on 17/3/28.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "CellDocument.h"
#import <Masonry/Masonry.h>
#import "YHChatHelper.h"
#import "NSString+Extension.h"

@interface CellDocument()

@property (nonatomic,strong) UIButton *btnCheckBox;//勾选框
@property (nonatomic,strong) UIImageView *imgvIcon;
@property (nonatomic,strong) UILabel *lbFileName;
@property (nonatomic,strong) UILabel *lbFileSize;
@property (nonatomic,strong) UIView  *viewBotLine; //底部分隔线

@end

@implementation CellDocument

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    _btnCheckBox = [UIButton new];
    [_btnCheckBox setImage:[UIImage imageNamed:@"chat_checkBox_nor"] forState:UIControlStateNormal];
    [_btnCheckBox setImage:[UIImage imageNamed:@"chat_checkBox_sel"] forState:UIControlStateSelected];
    [_btnCheckBox addTarget:self action:@selector(onBtnCheckBox:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_btnCheckBox];
    
    _imgvIcon = [UIImageView new];
    [self.contentView addSubview:_imgvIcon];
    
    _lbFileName = [UILabel new];
    _lbFileName.font = [UIFont systemFontOfSize:15.0];
    _lbFileName.numberOfLines = 2;
    _lbFileName.lineBreakMode = NSLineBreakByTruncatingMiddle;
    _lbFileName.textColor = RGB16(0x000000);
    [self.contentView addSubview:_lbFileName];
    
    _lbFileSize = [UILabel new];
    _lbFileSize.font = [UIFont systemFontOfSize:11.0];
    _lbFileSize.textColor = RGB16(0x7e7e7e);
    [self.contentView addSubview:_lbFileSize];
    
    _viewBotLine = [UIView new];
    _viewBotLine.backgroundColor = RGBCOLOR(222, 222, 222);
    [self.contentView addSubview:_viewBotLine];
    
    [self layoutUI];
}

- (void)layoutUI{
    WeakSelf
    [_btnCheckBox mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.contentView).offset(5);
        make.width.height.mas_equalTo(44);
        make.centerY.equalTo(weakSelf.contentView.mas_centerY);
    }];
    
    [_imgvIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.btnCheckBox.mas_right).offset(5);
        make.width.height.mas_equalTo(68);
        make.centerY.equalTo(weakSelf.contentView.mas_centerY);
    }];
    
    [_lbFileName setContentHuggingPriority:249 forAxis:UILayoutConstraintAxisVertical];
    [_lbFileName setContentCompressionResistancePriority:749 forAxis:UILayoutConstraintAxisVertical];
    [_lbFileName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.imgvIcon.mas_right).offset(5);
        make.right.equalTo(weakSelf.contentView).offset(-10);
        make.top.equalTo(weakSelf.imgvIcon.mas_top);
        make.bottom.mas_greaterThanOrEqualTo(weakSelf.lbFileSize.mas_top).priorityLow();
    }];
    
    [_lbFileSize mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.imgvIcon.mas_right).offset(5);
        make.bottom.equalTo(weakSelf.imgvIcon.mas_bottom);
        make.right.mas_lessThanOrEqualTo(weakSelf.contentView).offset(-10);
    }];
    
    [_viewBotLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakSelf.contentView);
        make.right.equalTo(weakSelf.contentView);
        make.left.equalTo(weakSelf.imgvIcon.mas_right).offset(5);
        make.height.mas_equalTo(1);
    }];
    
}

#pragma mark - Setter
- (void)setModel:(YHFileModel *)model{
    _model = model;
    self.lbFileName.text = _model.fileName;
    self.lbFileSize.text = _model.fileSizeStr;
    self.btnCheckBox.selected = _model.isSelected;
    NSNumber *num = _model.fileType;
    if (num == nil) {
        self.imgvIcon.image = [UIImage imageNamed:@"iconfont-wenjian"];
    } else {
        self.imgvIcon.image = [YHChatHelper imageWithFileType:[num intValue]];
    }
}


#pragma mark - Action
- (void)onBtnCheckBox:(UIButton *)sender{
    sender.selected = !sender.selected;
    _model.isSelected = sender.selected;
    if (_delegate && [_delegate respondsToSelector:@selector(onCheckBoxSelected:fileModel:)]) {
        [_delegate onCheckBoxSelected:sender.selected fileModel:self.model];
    }
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
