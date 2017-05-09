//
//  YHChatDetailVC.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 17/2/17.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "YHChatDetailVC.h"
#import "YHRefreshTableView.h"
#import "YHChatHeader.h"
#import "UITableViewCell+HYBMasonryAutoCellHeight.h"
#import "YHChatModel.h"
#import "YHExpressionKeyboard.h"
#import "YHUserInfo.h"
#import "HHUtils.h"
#import "YHChatHeader.h"
#import "TestData.h"
#import "YHAudioPlayer.h"
#import "YHAudioRecorder.h"
#import "YHVoiceHUD.h"
#import "YHUploadManager.h"
#import "YHChatManager.h"
#import "UIBarButtonItem+Extension.h"
#import "YHChatTextLayout.h"
#import "YHDocumentVC.h"
#import "YHNavigationController.h"
#import "YHWebViewController.h"
#import "YHShootVC.h"

@interface YHChatDetailVC ()<UITableViewDelegate,UITableViewDataSource,YHExpressionKeyboardDelegate,CellChatTextLeftDelegate,CellChatTextRightDelegate,CellChatVoiceLeftDelegate,CellChatVoiceRightDelegate,CellChatImageLeftDelegate,CellChatImageRightDelegate,CellChatBaseDelegate,
CellChatFileLeftDelegate,CellChatFileRightDelegate>{
    
}
@property (nonatomic,strong) YHRefreshTableView *tableView;
@property (nonatomic,strong) NSMutableArray *dataArray;
@property (nonatomic,strong) NSMutableArray *layouts;
@property (nonatomic,strong) YHExpressionKeyboard *keyboard;
@property (nonatomic,strong) YHVoiceHUD *imgvVoiceTips;

@property (nonatomic,strong) YHChatHelper *chatHelper;

@property (nonatomic,assign) BOOL showCheckBox;

@end

@implementation YHChatDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
   
    self.navigationController.navigationBar.translucent = NO;
    
    //设置导航栏
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem backItemWithTarget:self selector:@selector(onBack:)];
    
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem rightItemWithTitle:@"更多" target:self selector:@selector(onMore:) block:^(UIButton *btn) {
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        [btn setTitle:@"取消" forState:UIControlStateSelected];
        [btn setTitle:@"更多" forState:UIControlStateNormal];
    }];
    
    
    self.title = self.model.isGroupChat?[NSString stringWithFormat:@"%@(%lu)",self.model.sessionUserName,(unsigned long)self.model.sessionUserHead.count]: self.model.sessionUserName;
    
    [self initUI];
   
    
    //模拟数据源
    [self.dataArray addObjectsFromArray:[TestData randomGenerateChatModel:40 aChatListModel:self.model]];
    CGFloat addFontSize = [[[NSUserDefaults standardUserDefaults] valueForKey:kSetSystemFontSize] floatValue];
    for (YHChatModel *model in self.dataArray) {
        UIColor *textColor = [UIColor blackColor];
        UIColor *matchTextColor = UIColorHex(527ead);
        UIColor *matchTextHighlightBGColor = UIColorHex(bfdffe);
        if (model.direction == 0) {
            textColor = [UIColor whiteColor];
            matchTextColor = [UIColor greenColor];
            matchTextHighlightBGColor = [UIColor grayColor];
        }
        YHChatTextLayout *layout = [[YHChatTextLayout alloc] init];
        [layout layoutWithText:model.msgContent fontSize:(14+addFontSize) textColor:textColor matchTextColor:matchTextColor matchTextHighlightBGColor:matchTextHighlightBGColor];
        model.layout = layout;
        [self.layouts addObject:layout];
    }
    
    if (self.dataArray.count) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.tableView scrollToBottomAnimated:NO];
        });

    }
    
    //设置WebScoket
    [[YHChatManager sharedInstance] connectToUserID:@"99f16547-637c-4d84-8a55-ef24031977dd" isGroupChat:NO];
    
}


- (NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [NSMutableArray new];
    }
    return _dataArray;
}

- (NSMutableArray *)layouts{
    if (!_layouts) {
        _layouts = [NSMutableArray new];
    }
    return _layouts;
}

- (YHVoiceHUD *)imgvVoiceTips{
    if (!_imgvVoiceTips) {
        _imgvVoiceTips = [[YHVoiceHUD alloc] initWithFrame:CGRectMake(0, 0, 155, 155)];
        _imgvVoiceTips.center = CGPointMake(self.view.center.x, self.view.center.y-64);
        [self.view addSubview:_imgvVoiceTips];
    }
    return _imgvVoiceTips;
}


- (void)initUI{
    
    
    self.navigationController.navigationBar.translucent = NO;
    self.view.backgroundColor = RGBCOLOR(239, 236, 236);
    
    //tableview
    self.tableView = [[YHRefreshTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    self.tableView.backgroundColor = RGBCOLOR(239, 236, 236);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
   
    //注册Cell
    _chatHelper = [[YHChatHelper alloc ] init];
    [_chatHelper registerCellClassWithTableView:self.tableView];
    
    //表情键盘
    YHExpressionKeyboard *keyboard = [[YHExpressionKeyboard alloc] initWithViewController:self aboveView:self.tableView];
    _keyboard = keyboard;

}


#pragma mark - @protocol CellChatTextLeftDelegate

- (void)tapLeftAvatar:(YHUserInfo *)userInfo{
    DDLog(@"点击左边头像");
}

- (void)retweetMsg:(NSString *)msg inLeftCell:(CellChatTextLeft *)leftCell{
    DDLog(@"转发左边消息:%@",msg);
    DDLog(@"所在的行是:%ld",leftCell.indexPath.row);
}

- (void)onLinkInChatTextLeftCell:(CellChatTextLeft *)cell linkType:(int)linkType linkText:(NSString *)linkText{
    if (linkType == 1) {
        //点击URL
        YHWebViewController *vc = [[YHWebViewController alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64) url:[NSURL URLWithString:linkText]];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - @protocol CellChatTextRightDelegate
- (void)tapRightAvatar:(YHUserInfo *)userInfo{
    DDLog(@"点击右边头像");
}

- (void)retweetMsg:(NSString *)msg inRightCell:(CellChatTextRight *)rightCell{
    DDLog(@"转发右边消息:%@",msg);
    DDLog(@"所在的行是:%ld",(long)rightCell.indexPath.row);
}

- (void)tapSendMsgFailImg{
    DDLog(@"重发该消息?");
    [HHUtils showAlertWithTitle:@"重发该消息?" message:nil okTitle:@"重发" cancelTitle:@"取消" inViewController:self dismiss:^(BOOL resultYes) {
        if (resultYes) {
            DDLog(@"点击重发");
        }
    }];
}

- (void)withDrawMsg:(NSString *)msg inRightCell:(CellChatTextRight *)rightCell{
    DDLog(@"撤回消息:\n%@",msg);
    if (rightCell.indexPath.row < self.dataArray.count) {
        [self.dataArray removeObjectAtIndex:rightCell.indexPath.row];
        [self.tableView deleteRowAtIndexPath:rightCell.indexPath withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)onLinkInChatTextRightCell:(CellChatTextRight *)cell linkType:(int)linkType linkText:(NSString *)linkText{
    if (linkType == 1) {
        //点击URL
        YHWebViewController *vc = [[YHWebViewController alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64) url:[NSURL URLWithString:linkText]];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - @protocol CellChatImageLeftDelegate

- (void)retweetImage:(UIImage *)image inLeftCell:(CellChatImageLeft *)leftCell{
    DDLog(@"转发图片：%@",image);
}

#pragma mark - @protocol CellChatImageRightDelegate

- (void)retweetImage:(UIImage *)image inRightCell:(CellChatImageRight *)rightCell{
    DDLog(@"转发图片：%@",image);
}

- (void)withDrawImage:(UIImage *)image inRightCell:(CellChatImageRight *)rightCell{
    DDLog(@"撤回图片：%@",image);
    if (rightCell.indexPath.row < self.dataArray.count) {
        [self.dataArray removeObjectAtIndex:rightCell.indexPath.row];
        [self.tableView deleteRowAtIndexPath:rightCell.indexPath withRowAnimation:UITableViewRowAnimationFade];
    }
    
}


#pragma mark - @protocol CellChatVoiceLeftDelegate
- (void)playInLeftCellWithVoicePath:(NSString *)voicePath{
    DDLog(@"播放:%@",voicePath);

}

- (void)retweetVoice:(NSString *)voicePath inLeftCell:(CellChatVoiceLeft *)leftCell{
    DDLog(@"转发语音:%@",voicePath);
}

#pragma mark - @protocol CellChatVoiceRightDelegate
- (void)playInRightCellWithVoicePath:(NSString *)voicePath{
    DDLog(@"播放:%@",voicePath);

}

//转发语音
- (void)retweetVoice:(NSString *)voicePath inRightCell:(CellChatVoiceRight *)rightCell{
    DDLog(@"转发语音:%@",voicePath);
}

//撤回语音
- (void)withDrawVoice:(NSString *)voicePath inRightCell:(CellChatVoiceRight *)rightCell{
    DDLog(@"撤回语音:%@",voicePath);
    if (rightCell.indexPath.row < self.dataArray.count) {
        [self.dataArray removeObjectAtIndex:rightCell.indexPath.row];
        [self.tableView deleteRowAtIndexPath:rightCell.indexPath withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - @protocol CellChatFileLeftDelegate
//点击文件
- (void)onChatFile:(YHFileModel *)chatFile inLeftCell:(CellChatFileLeft *)leftCell{
    if (chatFile.filePathInLocal) {
        YHWebViewController *vc = [[YHWebViewController alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64) url:[NSURL fileURLWithPath:chatFile.filePathInLocal]];
        vc.title = chatFile.fileName;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

//转发文件
- (void)retweetFile:(YHFileModel *)chatFile inLeftCell:(CellChatFileLeft *)leftCell{

}

#pragma mark - @protocol CellChatFileRightDelegate
//点击文件
- (void)onChatFile:(YHFileModel *)chatFile inRightCell:(CellChatFileRight *)rightCell{
    if (chatFile.filePathInLocal) {
        YHWebViewController *vc = [[YHWebViewController alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64) url:[NSURL fileURLWithPath:chatFile.filePathInLocal]];
        vc.title = chatFile.fileName;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

//转发文件
- (void)retweetFile:(YHFileModel *)chatFile inRightCell:(CellChatFileRight *)rightCell{

}

//撤回文件
- (void)withDrawFile:(YHFileModel *)chatFile inRightCell:(CellChatFileRight *)rightCell{
    if (rightCell.indexPath.row < self.dataArray.count) {
        [self.dataArray removeObjectAtIndex:rightCell.indexPath.row];
        [self.tableView deleteRowAtIndexPath:rightCell.indexPath withRowAnimation:UITableViewRowAnimationFade];
    }

}

#pragma mark - @protocol CellChatBaseDelegate
- (void)onCheckBoxAtIndexPath:(NSIndexPath *)indexPath model:(YHChatModel *)model{
    DDLog(@"选择第%ld行的聊天记录",(long)indexPath.row);
}


#pragma mark - @protocol UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [_keyboard endEditing];
    [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
}


#pragma mark - @protocol UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row < self.dataArray.count) {
        YHChatModel *model = self.dataArray[indexPath.row];
        if(model.status == 1){
            //消息撤回
            CellChatTips *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellChatTips class])];
            cell.model = model;
            return cell;
        }else{
            if (model.msgType == YHMessageType_Image){
                if (model.direction == 0) {
                    
                    CellChatImageRight *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellChatImageRight class])];
                    cell.delegate = self;
                    cell.baseDelegate = self;
                    cell.indexPath = indexPath;
                    cell.showCheckBox = _showCheckBox;
                    [cell setupModel:model];
                    return cell;
                    
                }else{
                    
                    CellChatImageLeft *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellChatImageLeft class])];
                    cell.delegate = self;
                    cell.baseDelegate = self;
                    cell.indexPath = indexPath;
                    cell.showCheckBox = _showCheckBox;
                    [cell setupModel:model];
                    
                    return cell;
                }
                
            }else if (model.msgType == YHMessageType_Voice){
                
                if (model.direction == 0) {
                    CellChatVoiceRight *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellChatVoiceRight class])];
                    cell.delegate = self;
                    cell.baseDelegate = self;
                    cell.indexPath = indexPath;
                    cell.showCheckBox = _showCheckBox;
                    [cell setupModel:model];
                    return cell;
                }else{
                    CellChatVoiceLeft *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellChatVoiceLeft class])];
                    cell.delegate = self;
                    cell.baseDelegate = self;
                    cell.indexPath = indexPath;
                    cell.showCheckBox = _showCheckBox;
                    [cell setupModel:model];
                    return cell;
                }
                
            }else if(model.msgType == YHMessageType_Doc){
                if (model.direction == 0) {
                    CellChatFileRight *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellChatFileRight class])];
                    cell.delegate = self;
                    cell.baseDelegate = self;
                    cell.indexPath = indexPath;
                    cell.showCheckBox = _showCheckBox;
                    [cell setupModel:model];
                    return cell;
                }else{
                    CellChatFileLeft *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellChatFileLeft class])];
                    cell.delegate = self;
                    cell.baseDelegate = self;
                    cell.indexPath = indexPath;
                    cell.showCheckBox = _showCheckBox;
                    [cell setupModel:model];
                    return cell;
                }
                
            }else if (model.msgType == YHMessageType_GIF){
                
                if (model.direction == 0) {
                    CellChatGIFRight *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellChatGIFRight class])];
                    cell.baseDelegate = self;
                    cell.showCheckBox = _showCheckBox;
                    [cell setupModel:model];
                    return cell;
                }else{
                    CellChatGIFLeft *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellChatGIFLeft class])];
                    cell.baseDelegate = self;
                    cell.showCheckBox = _showCheckBox;
                    [cell setupModel:model];
                    return cell;
                }
                
            }else{
                if (model.direction == 0) {
                    CellChatTextRight *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellChatTextRight class])];
                    cell.delegate = self;
                    cell.baseDelegate = self;
                    cell.indexPath = indexPath;
                    cell.showCheckBox = _showCheckBox;
                    [cell setupModel:model];
                    return cell;
                }else{
                    CellChatTextLeft *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellChatTextLeft class])];
                    cell.delegate = self;
                    cell.baseDelegate = self;
                    cell.indexPath = indexPath;
                    cell.showCheckBox = _showCheckBox;
                    [cell setupModel:model];
                    return cell;
                }
            }

        }
        
        
        
    }
    return [[UITableViewCell alloc] init];
}

#pragma mark - @protocol UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.dataArray.count) {
        YHChatModel *model = self.dataArray[indexPath.row];
        return [_chatHelper heightWithModel:model tableView:tableView];
    }
    return 44.0f;
   
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{

}


// 松手时已经静止,只会调用scrollViewDidEndDragging
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (decelerate == NO) { // scrollView已经完全静止
        [self _handleAnimatedImageView];
    }
}

// 松手时还在运动, 先调用scrollViewDidEndDragging,在调用scrollViewDidEndDecelerating
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    // scrollView已经完全静止
    [self _handleAnimatedImageView];
}

- (void)_handleAnimatedImageView{
    for (UITableViewCell *visiableCell in self.tableView.visibleCells) {
        if ([visiableCell isKindOfClass:[CellChatGIFLeft class]]) {
             [(CellChatGIFLeft *)visiableCell startAnimating];
        }else if ([visiableCell isKindOfClass:[CellChatGIFRight class]]){
             [(CellChatGIFRight *)visiableCell startAnimating];
        }
    }
}

#pragma mark - Private
- (NSString *)currentRecordFileName
{
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    NSString *fileName = [NSString stringWithFormat:@"%ld",(long)timeInterval];
    return fileName;
}

//显示录音时间太短Tips
- (void)showShortRecordTips{
    WeakSelf
    self.imgvVoiceTips.hidden = NO;
    self.imgvVoiceTips.image  =  [UIImage imageNamed:@"voiceShort"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        weakSelf.imgvVoiceTips.hidden = YES;
    });
}


#pragma mark - @protocol YHExpressionKeyboardDelegate
//发送
- (void)didTapSendBtn:(NSString *)text{
    
    if (text.length) {
        YHChatModel *model = [YHChatHelper creatMessage:text msgType:YHMessageType_Text toID:nil];
        [self.dataArray addObject:model];
        
        [self.tableView reloadData];
        [self.tableView scrollToBottomAnimated:NO];
    }
    
}

- (void)didStartRecordingVoice{
    WeakSelf
    self.imgvVoiceTips.hidden = NO;
    [[YHAudioRecorder shareInstanced] startRecordingWithFileName:[self currentRecordFileName] completion:^(NSError *error) {
        if (error) {
            if (error.code != 122) {
                [HHUtils showAlertWithTitle:@"" message:error.localizedDescription okTitle:@"确定" cancelTitle:nil inViewController:self dismiss:^(BOOL resultYes) {
                    
                }];
            }
        }
    }power:^(float progress) {
        weakSelf.imgvVoiceTips.progress = progress;
    }];
}

- (void)didStopRecordingVoice{
    self.imgvVoiceTips.hidden = YES;
    WeakSelf
    [[YHAudioRecorder shareInstanced] stopRecordingWithCompletion:^(NSString *recordPath) {
        if ([recordPath isEqualToString:shortRecord]) {
            [weakSelf showShortRecordTips];
        }else{
            DDLog(@"record finish , file path is :\n%@",recordPath);
            NSString *voiceMsg = [NSString stringWithFormat:@"voice[local://%@]",recordPath];
            [weakSelf.dataArray addObject:[YHChatHelper creatMessage:voiceMsg msgType:YHMessageType_Voice toID:@"1"]];
            [weakSelf.tableView reloadData];
            [weakSelf.tableView scrollToBottomAnimated:NO];
        }
    }];
}

- (void)didDragInside:(BOOL)inside{
    if (inside) {

        [[YHAudioRecorder shareInstanced] resumeUpdateMeters];
        self.imgvVoiceTips.image = [UIImage imageNamed:@"voice_1"];
        self.imgvVoiceTips.hidden = NO;
    }else{

        [[YHAudioRecorder shareInstanced] pauseUpdateMeters];
        self.imgvVoiceTips.image = [UIImage imageNamed:@"cancelVoice"];
        self.imgvVoiceTips.hidden = NO;
    }
}

- (void)didCancelRecordingVoice{
    self.imgvVoiceTips.hidden = YES;
    [[YHAudioRecorder shareInstanced] removeCurrentRecordFile];
}

- (void)didSelectExtraItem:(NSString *)itemName{
    if ([itemName isEqualToString:@"文件"]) {
        YHDocumentVC *vc = [[YHDocumentVC alloc] init];
        YHNavigationController *nav = [[YHNavigationController alloc] initWithRootViewController:vc];
        [vc didSelectFilesComplete:^(NSArray<NSString *> *files) {
            DDLog(@"准备发送文件。");
        }];
        [self.navigationController presentViewController:nav animated:YES completion:NULL];
    }else if([itemName isEqualToString:@"拍摄"]){
         DDLog(@"拍摄");
        YHShootVC *vc = [[YHShootVC alloc] init];
        [self.navigationController presentViewController:vc animated:YES completion:NULL];
    }
}

#pragma mark - 网络请求
- (void)uploadRecordFile:(NSString *)filePath{
    //上传录音文件
    [[YHUploadManager sharedInstance] uploadChatRecordWithPath:filePath complete:^(BOOL success, id obj) {
        if (success) {
            DDLog(@"上传成功,%@",obj);
        }else{
            DDLog(@"上传失败,%@",obj);
        }
    } progress:^(int64_t bytesWritten, int64_t totalBytesWritten) {
        DDLog(@"bytesWritten:%lld -- totalBytesWritten:%lld",bytesWritten,totalBytesWritten);
    }];

}

#pragma mark - Action
- (void)onMore:(UIButton *)sender{
    sender.selected = !sender.selected;
    _showCheckBox = sender.selected? YES:NO;
    [self.tableView reloadData];
}

#pragma mark -  Action
- (void)onBack:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Life Cycle

- (void)dealloc{
    DDLog(@"%s is dealloc",__func__);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
