//
//  YHDocumentVC.m
//  YHChat
//
//  Created by samuelandkevin on 17/3/28.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "YHDocumentVC.h"
#import "UIBarButtonItem+Extension.h"
#import "YHFileTool.h"
#import "YHRefreshTableView.h"
#import "CellDocument.h"
#import "YHWebViewController.h"
#import "YHFileModel.h"
#import "YHFileTool.h"
#import "NSString+Extension.h"
#import "SqliteManager.h"

@interface YHDocumentVC ()<UITableViewDelegate,UITableViewDataSource,CellDocumentDelegate>

@property (nonatomic,strong) YHRefreshTableView *tableView;
@property (nonatomic,strong) UIBarButtonItem    *rBarItem;
@property (nonatomic,strong) UIButton       *btnRight;
@property (nonatomic,strong) NSMutableArray *dataArray;
@property (nonatomic,strong) NSMutableArray <NSString *>*selFileArray;

@property (nonatomic,copy) void(^selFiles)(NSArray <NSString *>*files);
@end

@implementation YHDocumentVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupNav];
    [self initUI];
    [self loadData];
}

- (void)initUI{

    //tableview
    self.tableView = [[YHRefreshTableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    self.tableView.backgroundColor = RGBCOLOR(239, 236, 236);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.tableView registerClass:[CellDocument class] forCellReuseIdentifier:NSStringFromClass([CellDocument class])];
}


- (void)setupNav{
    self.navigationController.navigationBar.translucent = NO;
    self.view.backgroundColor = RGBCOLOR(239, 236, 236);
    self.title = @"本机文件";
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem backItemWithTarget:self selector:@selector(onBack:)];
    
    
    //右BarItem
    UIButton *btnRight = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
    btnRight.layer.cornerRadius  = 3;
    btnRight.layer.masksToBounds = YES;
    btnRight.backgroundColor = [RGBCOLOR(244, 244, 244) colorWithAlphaComponent:0.8];
    [btnRight setTitle:@"添加" forState:UIControlStateNormal];
    btnRight.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [btnRight setTitleColor:kBlueColor forState:UIControlStateNormal];
    [btnRight addTarget:self action:@selector(onRight:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rBarItem = [[UIBarButtonItem alloc] initWithCustomView:btnRight];
    rBarItem.enabled = NO;
    self.navigationItem.rightBarButtonItem = rBarItem;
    _btnRight = btnRight;
    _rBarItem = rBarItem;
}

- (void)loadData
{
    WeakSelf
    [[SqliteManager sharedInstance] queryOfficeFilesUserInfo:nil fuzzyUserInfo:nil complete:^(BOOL success, id obj) {
        if (success) {
            NSArray *ret = obj;
            for (YHFileModel *model in ret) {
                NSString *saveFileName = [model.filePathInServer lastPathComponent];
                model.filePathInLocal = [NSString stringWithFormat:@"%@/%@",OfficeDir,saveFileName];
            }
            [weakSelf.dataArray addObjectsFromArray:ret];
        }else{
            
        }
        [weakSelf.tableView reloadData];
    }];
    
    if (!self.dataArray.count) {
        [self.tableView setNoData:YES withText:@"暂无文件"];
    }
    
}

#pragma mark - Getter
- (NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [NSMutableArray new];
    }
    return _dataArray;
}

- (NSMutableArray<NSString *> *)selFileArray{
    if (!_selFileArray) {
        _selFileArray = [NSMutableArray new];
    }
    return _selFileArray;
}


#pragma mark -  Action
- (void)onBack:(id)sender{
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}

- (void)onRight:(UIButton *)sender{
    DDLog(@"要发送的文件：\n%@",_selFileArray);
    WeakSelf
    if (self.selFiles) {
        weakSelf.selFiles(weakSelf.selFileArray);
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Private

#pragma mark - Public
- (void)didSelectFilesComplete:(void(^)(NSArray <NSString *> *files))complete{
    self.selFiles = complete;
}

#pragma mark - @protocol CellDocumentDelegate

- (void)onCheckBoxSelected:(BOOL)selected fileModel:(YHFileModel *)fileModel{
    
    if (selected) {
        if (![self.selFileArray containsObject:fileModel.filePathInLocal] && fileModel) {
            [self.selFileArray addObject:fileModel.filePathInLocal];
        }
    }else{
        if (fileModel) {
            [self.selFileArray removeObjectIdenticalTo:fileModel.filePathInLocal];
        }
    }
    //设置导航栏右按钮
    if (self.selFileArray.count) {
        self.btnRight.backgroundColor = RGBCOLOR(244, 244, 244);
        [self.btnRight setTitle:[NSString stringWithFormat:@"确定(%ld)",self.selFileArray.count] forState:UIControlStateNormal];
        _rBarItem.enabled = YES;
    }else{
        self.btnRight.backgroundColor = [RGBCOLOR(244, 244, 244) colorWithAlphaComponent:0.8];
        [self.btnRight setTitle:[NSString stringWithFormat:@"添加"] forState:UIControlStateNormal];
        _rBarItem.enabled = NO;
    }
}

#pragma mark - @protocol UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CellDocument *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellDocument class])];
    cell.delegate = self;
    if (indexPath.row < self.dataArray.count) {
        cell.model = self.dataArray[indexPath.row];
    }
    return cell;
}

#pragma mark - @protocol UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.dataArray.count) {
        //显示本地文件
        YHFileModel *model = self.dataArray[indexPath.row];
        NSString *urlStr = model.filePathInLocal;
        if (!urlStr) {
            return;
        }
        YHWebViewController *vc = [[YHWebViewController alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64) url:[NSURL fileURLWithPath:urlStr]];
        vc.title = model.fileName;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
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
