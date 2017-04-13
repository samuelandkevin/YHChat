//
//  YHShootVC.m
//  YHChat
//
//  Created by YHIOS002 on 17/4/13.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//  拍摄

#import "YHShootVC.h"
#import "YHVideoManager.h"

@interface YHShootVC ()

@end

@implementation YHShootVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.hidden = YES;
    
    self.view.backgroundColor = [UIColor blackColor];
    
    //毛玻璃效果
    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
    effectView.frame = self.view.frame;
    [self.view addSubview:effectView];
    

    [[YHVideoManager shareInstanced] setVideoPreviewLayer:self.view];
    
    //返回按钮
    UIButton *btnBack = [[UIButton alloc] initWithFrame:CGRectMake(5, 30, 40, 40)];
    [btnBack setImage:[UIImage imageNamed:@"common_leftArrow"] forState:UIControlStateNormal];
    [btnBack addTarget:self action:@selector(onBack:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnBack];
    
    
    //白底圆
    
    
    //
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -  Action
- (void)onBack:(id)sender{
    [[YHVideoManager shareInstanced] exit];
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
