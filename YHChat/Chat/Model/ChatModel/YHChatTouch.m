//
//  YHChatTouch.m
//  PikeWay
//
//  Created by YHIOS002 on 2018/4/27.
//  Copyright © 2018年 YHSoft. All rights reserved.
//

#import "YHChatTouch.h"
#import "YHChatListModel.h"
#import "CellChatList.h"
#import "YHChatListVC.h"
#import "YHChatDetailVC.h"

@interface YHChatTouch()<UIViewControllerPreviewingDelegate>
@property (nonatomic,weak)YHChatListVC *previewVC;
@end

@implementation YHChatTouch

+ (void)registerForPreviewInVC:(YHChatListVC *)vc sourceView:(UIView *)sourceView model:(YHChatListModel *)model{
   
    YHChatTouch *aModel = [YHChatTouch new];
    aModel.previewVC    = vc;
    model.touchModel    = aModel;
    if ([[UIDevice currentDevice].systemVersion floatValue] > 9.0) {
        if (vc.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
             [vc registerForPreviewingWithDelegate:aModel sourceView:sourceView];
        }
    }
}

#pragma mark - 3DTouch
//peek(预览)
- (nullable UIViewController *)previewingContext:(id <UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location
{
    
    //调整不被虚化的范围，按压的那个cell不被虚化（轻轻按压时周边会被虚化，再少用力展示预览，再加力跳页至设定界面）
    CGRect rect = CGRectMake(0, 0, SCREEN_WIDTH,70);
    previewingContext.sourceRect = rect;
    
    CellChatList *cell = (CellChatList *)previewingContext.sourceView;
    YHChatListModel *model = cell.model;
    if (!model) {
        return nil;
    }
    
    //设定预览的界面
    YHChatDetailVC *vc = [[YHChatDetailVC alloc] init];
    vc.model = model;
  
    //返回预览界面
    return vc;
    
}

//pop（按用点力进入）
- (void)previewingContext:(id <UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
    viewControllerToCommit.hidesBottomBarWhenPushed = YES;
    [_previewVC.navigationController pushViewController:viewControllerToCommit animated:YES];
}

- (void)dealloc{
 
}

@end


