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

@interface YHChatDetailVC ()<UITableViewDelegate,UITableViewDataSource,YHExpressionKeyboardDelegate,CellChatTextLeftDelegate,CellChatTextRightDelegate>{
    
}
@property (nonatomic,strong) YHRefreshTableView *tableView;
@property (nonatomic,strong) NSMutableArray *dataArray;
@property (nonatomic,strong) YHExpressionKeyboard *keyboard;

@end

@implementation YHChatDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.translucent = NO;
    [self initUI];
    
    
    //模拟数据源
    [self.dataArray addObjectsFromArray:[TestData randomGenerateChatModel:10]];

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


#pragma mark - @protocol UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [_keyboard endEditing];
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
                cell.model = model;
                return cell;
                
            }else{
                
                CellChatImageLeft *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellChatImageLeft class])];
                cell.model = model;
                return cell;
            }
            
        }else{
            if (model.direction == 0) {
                CellChatTextRight *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellChatTextRight class])];
                cell.delegate = self;
                cell.model = model;
                return cell;
            }else{
                CellChatTextLeft *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellChatTextLeft class])];
                cell.delegate = self;
                cell.model = model;
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
                    cell.model = model;
                }];
                
            }else{
                
                return [CellChatImageLeft hyb_heightForTableView:tableView config:^(UITableViewCell *sourceCell) {
                    CellChatImageLeft *cell = (CellChatImageLeft *)sourceCell;
                    cell.model = model;
                }];
            }
            
        }else{
            if (model.direction == 0) {
                return [CellChatTextRight hyb_heightForTableView:tableView config:^(UITableViewCell *sourceCell) {
                    CellChatTextRight *cell = (CellChatTextRight *)sourceCell;
                    cell.model = model;
                }];
            }else{
                return [CellChatTextLeft hyb_heightForTableView:tableView config:^(UITableViewCell *sourceCell) {
                    CellChatTextLeft *cell = (CellChatTextLeft *)sourceCell;
                    cell.model = model;
                }];
            }
        }
        
    }
    
    return 44.0f;
   

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
 
}

#pragma mark - YHExpressionKeyboardDelegate
- (void)sendBtnDidTap:(NSString *)text{
    
    if (text.length) {
        YHChatModel *model = [YHChatHelper creatMessage:text msgType:YHMessageType_Text toID:nil];
        [self.dataArray addObject:model];
        
        [self.tableView reloadData];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        
    }
    
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
