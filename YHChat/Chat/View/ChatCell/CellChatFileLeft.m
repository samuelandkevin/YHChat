//
//  CellChatFileLeft.m
//  YHChat
//
//  Created by YHIOS002 on 17/3/29.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "CellChatFileLeft.h"
#import <Masonry/Masonry.h>
#import <HYBMasonryAutoCellHeight/UITableViewCell+HYBMasonryAutoCellHeight.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "YHChatHelper.h"
#import "YHDownLoadManager.h"
#import "NetManager.h"
#import "HHUtils.h"

@interface CellChatFileLeft()
@property (nonatomic,strong) UIImageView *imgvBubble;
@property (nonatomic,strong) UIButton *btnTapScope;
@property (nonatomic,strong) UIImageView *imgvIcon;
@property (nonatomic,strong) UILabel *lbFileName;
@property (nonatomic,strong) UILabel *lbFileSize;
@property (nonatomic,strong) UILabel *lbStatus;
@property (nonatomic,strong) UIProgressView *progressView;
@end

@implementation CellChatFileLeft

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    
    _imgvBubble = [UIImageView new];
    UIImage *imgBubble = [UIImage imageNamed:@"chat_bubbleLeft"];
    imgBubble = [imgBubble resizableImageWithCapInsets:UIEdgeInsetsMake(30, 30, 30, 15) resizingMode:UIImageResizingModeStretch];
    _imgvBubble.image = imgBubble;
    [self.contentView addSubview:_imgvBubble];
    
    _btnTapScope = [UIButton new];
    [_btnTapScope addTarget:self action:@selector(onBtnTapScope:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_btnTapScope];
    
    _imgvIcon = [UIImageView new];
    [self.contentView addSubview:_imgvIcon];
    
    _lbFileName = [UILabel new];
    _lbFileName.font = [UIFont systemFontOfSize:15.0];
    _lbFileName.numberOfLines = 2;
    _lbFileName.lineBreakMode = NSLineBreakByTruncatingMiddle;
    _lbFileName.textColor = [UIColor blackColor];
    [self.contentView addSubview:_lbFileName];
    
    _lbFileSize = [UILabel new];
    _lbFileSize.font = [UIFont systemFontOfSize:11.0];
    _lbFileSize.textColor = RGB16(0x7e7e7e);
    [self.contentView addSubview:_lbFileSize];
    
    _lbStatus = [UILabel new];
    _lbStatus.font = [UIFont systemFontOfSize:11.0];
    _lbStatus.textColor = RGB16(0x707070);
    _lbStatus.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:_lbStatus];
    
    _progressView = [UIProgressView new];
    _progressView.progressTintColor = kBlueColor;
    [self.contentView addSubview:_progressView];
    
    [self layoutUI];
}

- (void)layoutUI{
    WeakSelf
    [self layoutCommonUI];
    
    [self.lbName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.imgvAvatar.mas_right).offset(10);
    }];
    
    [self.imgvAvatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.btnCheckBox.mas_right).offset(5);
    }];
    
    [_imgvBubble mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.imgvAvatar.mas_right).offset(5);
        make.top.equalTo(weakSelf.lbName.mas_bottom).offset(5);
        make.width.mas_equalTo(SCREEN_WIDTH - 133);
        make.height.mas_equalTo(85);
    }];
    
    [_btnTapScope mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(weakSelf.imgvBubble);
        make.size.equalTo(weakSelf.imgvBubble);
    }];
    
    [_imgvIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(68);
        make.centerY.equalTo(weakSelf.imgvBubble.mas_centerY);
        make.left.equalTo(weakSelf.imgvBubble).offset(15);
    }];
    
    
    [_lbFileName setContentHuggingPriority:249 forAxis:UILayoutConstraintAxisVertical];
    [_lbFileName setContentCompressionResistancePriority:749 forAxis:UILayoutConstraintAxisVertical];
    [_lbFileName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.imgvIcon.mas_right).offset(5);
        make.top.equalTo(weakSelf.imgvIcon.mas_top);
        make.right.equalTo(weakSelf.imgvBubble.mas_right).offset(-5);
        make.bottom.mas_greaterThanOrEqualTo(weakSelf.lbFileSize.mas_top).priorityLow();
    }];
    
    
    [_lbFileSize setContentHuggingPriority:249 forAxis:UILayoutConstraintAxisHorizontal];
    [_lbFileSize setContentCompressionResistancePriority:749 forAxis:UILayoutConstraintAxisHorizontal];
    [_lbFileSize mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.imgvIcon.mas_right).offset(5);
        make.bottom.equalTo(weakSelf.imgvIcon.mas_bottom);
        make.right.mas_lessThanOrEqualTo(weakSelf.lbStatus.mas_left);
    }];
    
    [_lbStatus mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf.imgvBubble.mas_right).offset(-5);
        make.bottom.equalTo(weakSelf.imgvIcon.mas_bottom);
    }];
    
    [_progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakSelf.imgvBubble.mas_bottom).offset(-3);
        make.left.equalTo(weakSelf.imgvBubble).offset(15);
        make.right.equalTo(weakSelf.imgvBubble).offset(-5);
    }];
    
    self.hyb_lastViewInCell = _imgvBubble;
    self.hyb_bottomOffsetToCell = 10;
}

- (void)setupModel:(YHChatModel *)model{
    [super setupModel:model];
    
    self.lbName.text    = self.model.speakerName;
    self.lbTime.text    = self.model.createTime;
    [self.imgvAvatar sd_setImageWithURL:self.model.speakerAvatar placeholderImage:[UIImage imageNamed:@"common_avatar_80px"]];
    
    NSString *msgContent = self.model.msgContent;
    if (self.model.msgType == 3 && msgContent) {

        _lbFileName.text = self.model.fileModel.name;
        NSNumber *num = self.model.fileModel.fileType;
        if (num == nil) {
            self.imgvIcon.image = [UIImage imageNamed:@"iconfont-wenjian"];
        } else {
            self.imgvIcon.image = [YHChatHelper imageWithFileType:[num intValue]];
        }
    }
    
    if (self.model.fileModel.status == FileStatus_UnDownLoaded) {
        _progressView.hidden = YES;
    }
    
    //wifi状态下自动下载
    if ([NetManager sharedInstance].currentNetWorkStatus == YHNetworkStatus_ReachableViaWiFi) {
         [self _downLoadFile];
    }
    
   
    _progressView.hidden = self.model.fileModel.status == FileStatus_HasDownLoaded ? YES:NO;
    if(self.model.fileModel.status == FileStatus_UnDownLoaded){
        self.lbStatus.text = @"未完成";
    }else if(self.model.fileModel.status == FileStatus_isDownLoading){
        self.lbStatus.text = @"下载中";
    }else if(self.model.fileModel.status == FileStatus_HasDownLoaded){
        self.lbStatus.text = @"已下载";
    }
    
    
}

#pragma mark - Private
- (void)_downLoadFile{
    //进度条显示与否
    _progressView.hidden = self.model.fileModel.status == FileStatus_HasDownLoaded ? YES:NO;
    if (self.model.fileModel.status == FileStatus_HasDownLoaded) {
        return;
    }
    self.model.fileModel.status = FileStatus_isDownLoading;
    
    WeakSelf
    [[YHDownLoadManager sharedInstance] downOfficeDocWithRequestUrl:self.model.fileModel.filePath rename:self.model.fileModel.name sessionID:self.model.chatId complete:^(BOOL success, id obj) {
        weakSelf.progressView.hidden = YES;
        if (success) {
            DDLog(@"下载文件成功:%@",obj);
            weakSelf.model.fileModel.status = FileStatus_HasDownLoaded;
            weakSelf.model.fileModel.filePath = obj;
            weakSelf.lbStatus.text = @"已下载";
        }else{
            DDLog(@"下载文件失败:%@",obj);
            weakSelf.model.fileModel.status = FileStatus_UnDownLoaded;
            weakSelf.lbStatus.text = @"未完成";
            
        }
    } progress:^(int64_t bytesWritten, int64_t totalBytesWritten) {
        float progress = bytesWritten/(float)totalBytesWritten;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.progressView setProgress:progress animated:YES];
        });
    }];
  
    
}

#pragma mark - Action
- (void)onBtnTapScope:(UIButton *)sender{
    if (self.model.fileModel.status != FileStatus_HasDownLoaded) {
        [self _downLoadFile];
        return;
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(onChatFile:inLeftCell:)]) {
        [_delegate onChatFile:self.model.fileModel inLeftCell:self];
    }
    
}




@end
