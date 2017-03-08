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

@interface YHChatDetailVC ()<UITableViewDelegate,UITableViewDataSource,YHExpressionKeyboardDelegate,CellChatTextLeftDelegate,CellChatTextRightDelegate,CellChatVoiceLeftDelegate,CellChatVoiceRightDelegate>{
    
}
@property (nonatomic,strong) YHRefreshTableView *tableView;
@property (nonatomic,strong) NSMutableArray *dataArray;
@property (nonatomic,strong) YHExpressionKeyboard *keyboard;
@property (nonatomic,strong) YHVoiceHUD *imgvVoiceTips;

@end

@implementation YHChatDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.translucent = NO;
    [self initUI];
    
    
    //模拟数据源
    [self.dataArray addObjectsFromArray:[TestData randomGenerateChatModel:40]];

    if (self.dataArray.count) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:NO];
        });

    }
    
}


- (NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [NSMutableArray new];
    }
    return _dataArray;
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
    
    self.title = @"聊天详情";
    self.navigationController.navigationBar.translucent = NO;
    self.view.backgroundColor = RGBCOLOR(239, 236, 236);
    
    //tableview
    self.tableView = [[YHRefreshTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    self.tableView.backgroundColor = RGBCOLOR(239, 236, 236);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
   
    [self _registerCellClass];

    
    //表情键盘
    YHExpressionKeyboard *keyboard = [[YHExpressionKeyboard alloc] initWithViewController:self aboveView:self.tableView];
    _keyboard = keyboard;

}

- (void)_registerCellClass{
    [self.tableView registerClass:[CellChatTextLeft class] forCellReuseIdentifier:NSStringFromClass([CellChatTextLeft class])];
    [self.tableView registerClass:[CellChatTextRight class] forCellReuseIdentifier:NSStringFromClass([CellChatTextRight class])];
    [self.tableView registerClass:[CellChatImageLeft class] forCellReuseIdentifier:NSStringFromClass([CellChatImageLeft class])];
    [self.tableView registerClass:[CellChatImageRight class] forCellReuseIdentifier:NSStringFromClass([CellChatImageRight class])];
    [self.tableView registerClass:[CellChatVoiceLeft class] forCellReuseIdentifier:NSStringFromClass([CellChatVoiceLeft class])];
     [self.tableView registerClass:[CellChatVoiceRight class] forCellReuseIdentifier:NSStringFromClass([CellChatVoiceRight class])];
}


#pragma mark - @protocol CellChatLeftDelegate

- (void)tapLeftAvatar:(YHUserInfo *)userInfo{
    NSLog(@"点击左边头像");
}

#pragma mark - @protocol CellChatRightDelegate
- (void)tapRightAvatar:(YHUserInfo *)userInfo{
    NSLog(@"点击右边头像");
}

- (void)tapSendMsgFailImg{
    DDLog(@"重发该消息?");
    [HHUtils showAlertWithTitle:@"重发该消息?" message:nil okTitle:@"重发" cancelTitle:@"取消" inViewController:self dismiss:^(BOOL resultYes) {
        if (resultYes) {
            DDLog(@"点击重发");
        }
    }];
}

#pragma mark - @protocol CellChatVoiceLeft
- (void)playInLeftCellWithVoicePath:(NSString *)voicePath{
    DDLog(@"播放:%@",voicePath);

}

#pragma mark - @protocol CellChatVoiceRight
- (void)playInRightCellWithVoicePath:(NSString *)voicePath{
    DDLog(@"播放:%@",voicePath);

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
        if (model.msgType == YHMessageType_Image){
            if (model.direction == 0) {
                
                CellChatImageRight *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellChatImageRight class])];
                [cell setupModel:model];
                return cell;
                
            }else{
                
                CellChatImageLeft *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellChatImageLeft class])];
                [cell setupModel:model];
                return cell;
            }
            
        }else if (model.msgType == YHMessageType_Voice){
        
            if (model.direction == 0) {
                CellChatVoiceRight *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellChatVoiceRight class])];
                cell.delegate = self;
                [cell setupModel:model];
                return cell;
            }else{
                CellChatVoiceLeft *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellChatVoiceLeft class])];
                cell.delegate = self;
                [cell setupModel:model];
                return cell;
            }
            
        }else{
            if (model.direction == 0) {
                CellChatTextRight *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellChatTextRight class])];
                cell.delegate = self;
                [cell setupModel:model];
                return cell;
            }else{
                CellChatTextLeft *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellChatTextLeft class])];
                cell.delegate = self;
                [cell setupModel:model];
                return cell;
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
        if (model.msgType == YHMessageType_Image) {
            if (model.direction == 0) {
                
                return [CellChatImageRight hyb_heightForTableView:tableView config:^(UITableViewCell *sourceCell) {
                    CellChatImageRight *cell = (CellChatImageRight *)sourceCell;
                    [cell setupModel:model];
                }];
                
            }else{
                
                return [CellChatImageLeft hyb_heightForTableView:tableView config:^(UITableViewCell *sourceCell) {
                    CellChatImageLeft *cell = (CellChatImageLeft *)sourceCell;
                    [cell setupModel:model];
                }];
            }
            
        }else if (model.msgType == YHMessageType_Voice){
            if (model.direction == 0) {
               return [CellChatVoiceRight hyb_heightForTableView:tableView config:^(UITableViewCell *sourceCell) {
                       CellChatVoiceRight *cell = (CellChatVoiceRight *)sourceCell;
                       [cell setupModel:model];
                }];
            }else{
                return [CellChatVoiceLeft hyb_heightForTableView:tableView config:^(UITableViewCell *sourceCell) {
                    CellChatVoiceLeft *cell = (CellChatVoiceLeft *)sourceCell;
                    [cell setupModel:model];
                }];
            }
        }else{
            if (model.direction == 0) {
                return [CellChatTextRight hyb_heightForTableView:tableView config:^(UITableViewCell *sourceCell) {
                    CellChatTextRight *cell = (CellChatTextRight *)sourceCell;
                    [cell setupModel:model];
                }];
            }else{
                return [CellChatTextLeft hyb_heightForTableView:tableView config:^(UITableViewCell *sourceCell) {
                    CellChatTextLeft *cell = (CellChatTextLeft *)sourceCell;
                    [cell setupModel:model];
                }];
            }
        }
        
    }
    
    return 44.0f;
   

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
 
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


#pragma mark - YHExpressionKeyboardDelegate
//发送
- (void)didTapSendBtn:(NSString *)text{
    
    if (text.length) {
        YHChatModel *model = [YHChatHelper creatMessage:text msgType:YHMessageType_Text toID:nil];
        [self.dataArray addObject:model];
        
        [self.tableView reloadData];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        
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
            [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:weakSelf.dataArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
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

#pragma mark - Life Cycle

- (void)dealloc{
    NSLog(@"%s is dealloc",__func__);
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
