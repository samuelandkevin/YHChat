//
//  YHShootVC.m
//  YHChat
//
//  Created by YHIOS002 on 17/4/13.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//  拍摄

#import "YHShootVC.h"
#import "YHShootView.h"

@interface YHShootVC ()

@property (nonatomic,strong)YHShootView *shootView;

@end

@implementation YHShootVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //导航栏
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.hidden = YES;
    self.view.backgroundColor = [UIColor blackColor];
    
    //拍摄View
    WeakSelf
    _shootView = [[YHShootView alloc] initWithFrame:self.view.bounds];
    [_shootView onBackHandler:^{
        [weakSelf dismissViewControllerAnimated:YES completion:NULL];
    }];
    [_shootView chooseHandler:^(ShootType type, id obj) {
        DDLog(@"选择的类型是%d,回调对象:%@",type,obj);
    }];
    [self.view addSubview:_shootView];

}

#pragma mark - Life
- (void)dealloc{
    DDLog(@"%s is dealloc",__func__);
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarHidden = YES;
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [UIApplication sharedApplication].statusBarHidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -  Action
- (void)onBack:(id)sender{
    [self dismissViewControllerAnimated:YES completion:NULL];
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
