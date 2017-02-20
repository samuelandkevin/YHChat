//
//  YHChatDetailVC.m
//  YHChat
//
//  Created by YHIOS002 on 17/2/17.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "YHChatDetailVC.h"
#import "YHRefreshTableView.h"
#import "CellChatTextLeft.h"
#import "CellChatTextRight.h"
#import "UITableViewCell+HYBMasonryAutoCellHeight.h"
#import "YHChatModel.h"
#import "YHExpressionKeyboard.h"
#import "YHUserInfo.h"


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
    for (int i=0; i<10; i++) {
        YHChatModel *model = [YHChatModel new];
        [self randomModel:model totalCount:2];
        [self.dataArray addObject:model];
    }

    if (self.dataArray.count) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:NO];
        });

    }
    
}


#pragma mark - 模拟产生数据源
- (void)randomModel:(YHChatModel *)model totalCount:(int)totalCount{
    
    [self creatChatModel:model totalCount:totalCount];
    
}

- (void)creatChatModel:(YHChatModel *)model totalCount:(int)totalCount{
   
    //用户ID
    NSArray *uidArr = @[@"1",@"2",@"3",@"4"];
    int nUidLength  = arc4random() % uidArr.count;
    model.speakerId = uidArr[nUidLength];
    if ([model.speakerId isEqualToString:MYUID]) {
        model.direction = 0;
    }else{
        model.direction = 1;
    }

    //发言者头像
    NSArray *avtarArray = @[
                            @"http://testapp.gtax.cn/images/2016/11/09/64a62eaaff7b466bb8fab12a89fe5f2f.png!m90x90.png",
                            @"https://testapp.gtax.cn/images/2016/09/30/ad0d18a937b248f88d29c2f259c14b5e.jpg!m90x90.jpg",
                            @"https://testapp.gtax.cn/images/2016/09/14/c6ab40b1bc0e4bf19e54107ee2299523.jpg!m90x90.jpg",
                            @"http://testapp.gtax.cn/images/2016/11/14/8d4ee23d9f5243f98c79b9ce0c699bd9.png!m90x90.png",
                            @"https://testapp.gtax.cn/images/2016/09/14/8cfa9bd12e6844eea0a2e940257e1186.jpg!m90x90.jpg"];
    int avtarIndex = arc4random() % avtarArray.count;
    if (avtarIndex < avtarArray.count) {
        
        if ([model.speakerId isEqualToString:MYUID]) {
            model.speakerAvatar = [NSURL URLWithString:@"http://testapp.gtax.cn/images/2016/11/05/812eb442b6a645a99be476d139174d3c.png!m90x90.png"];
        }else{
            model.speakerAvatar = [NSURL URLWithString:avtarArray[avtarIndex]];
        }

    }
    
    //聊天记录ID
    CGFloat myIdLength = arc4random() % totalCount;
    int result = (int)myIdLength % 2;
    model.chatId = [NSString stringWithFormat:@"%d",result];;
    
    //名字
    CGFloat nLength = arc4random() % 3 + 1;
    NSMutableString *nStr = [NSMutableString new];
    for (int i = 0; i < nLength; i++) {
        [nStr appendString: @"测试名字"];
    }
    if ([model.speakerId isEqualToString:MYUID]) {
        model.speakerName = @"我";
    }else{
         model.audienceName = nStr;
    }
 
    
    //消息内容
    CGFloat qlength = arc4random() % totalCount+1;
    NSMutableString *qStr = [[NSMutableString alloc] init];
    for (NSUInteger i = 0; i < qlength; ++i) {
        [qStr appendString:@"消息内容很长，消息内容很长."];
    }
    model.msgContent = qStr;
    
    
    //发布时间
    model.createTime = @"2013-04-17";
    
    
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
    [self.tableView registerClass:[CellChatTextLeft class] forCellReuseIdentifier:NSStringFromClass([CellChatTextLeft class])];
    [self.tableView registerClass:[CellChatTextRight class] forCellReuseIdentifier:NSStringFromClass([CellChatTextRight class])];

    
    //表情键盘
    YHExpressionKeyboard *keyboard = [[YHExpressionKeyboard alloc] initWithViewController:self aboveView:self.tableView];
    _keyboard = keyboard;

}


#pragma mark - @protocol CellChatLeftDelegate

- (void)tapLeftAvatar:(YHUserInfo *)userInfo{
    NSLog(@"点击左边头像");
}

#pragma mark - @protocol CellChatRightDelegate
- (void)tapRightAvatar:(YHUserInfo *)userInfo{
    NSLog(@"点击右边头像");
}


#pragma mark - @protocol UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
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
    return [[UITableViewCell alloc] init];
}

#pragma mark - @protocol UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.dataArray.count) {
        YHChatModel *model = self.dataArray[indexPath.row];
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
    
    return 44.0f;
   

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
 
}

#pragma mark - YHExpressionKeyboardDelegate
- (void)sendBtnDidTap:(NSString *)text{
    
    if (text.length) {
        YHChatModel *model = [YHChatModel new];
        model.speakerId = MYUID;
        model.speakerAvatar = [NSURL URLWithString:@"http://testapp.gtax.cn/images/2016/11/05/812eb442b6a645a99be476d139174d3c.png!m90x90.png"];
        model.msgContent = text;
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
