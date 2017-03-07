//
//  CustomerNavigationController.h
//  testCustomerNavigationBar
//
//  Created by YHIOS003 on 16/4/20.
//  Copyright © 2016年 GDYHSoft. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface YHNavigationController : UINavigationController
@property(nonatomic,strong) UIView * naviBar;

-(void)CreateNaviBar;

@end
