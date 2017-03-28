//
//  YHSuperTableView.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 16/5/31.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//

#import "YHRefreshTableView.h"
#import <MJRefresh/MJRefresh.h>
#import <Masonry/Masonry.h>

@interface YHRefreshTableView()
{
    UIView      *_viewLoadFailed;
    UIView      *_viewLoadingState;
    UIView      *_viewNoData;
}

@end

@implementation YHRefreshTableView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    return self;
}


/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

#pragma mark - Private

- (void)createHeaderView{
    
    if (!self.mj_header) {
         self.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNew)];
    }
   
}

- (void)removeHeaderView{
    self.mj_header = nil;
}

- (void)creatFooterView{
    
    if (!self.mj_footer) {
         self.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMore)];
    }
    
}

- (void)removeFooterView {
    self.mj_footer = nil;
}

- (void)didFinishLoadData {

}

#pragma mark - Life

- (void)dealloc {
    
}

#pragma mark - Public

- (void)loadBegin:(YHRefreshType)type{
    [self showLoadingView:YES];
    switch (type)
    {
        case YHRefreshType_LoadNew:
        {
            [self createHeaderView];
        }
            break;
        case YHRefreshType_LoadMore:
        {
            [self creatFooterView];
        }
            break;
        default:
            break;
    }
}

- (void)loadFinish:(YHRefreshType)type{
    
    [self showLoadingView:NO];
    switch (type)
    {
        case YHRefreshType_LoadNew:
        {
            [self.mj_header endRefreshing];
        }
            break;
        case YHRefreshType_LoadMore:
        {
            [self.mj_footer endRefreshing];
        }
            break;
        default:
            break;
    }
}

- (void)endRefreshingWithNoMoreData{
    
}

#pragma mark - Setter

- (void)setEnableLoadNew:(BOOL)enableLoadNew
{
    _enableLoadNew = enableLoadNew;
    if (_enableLoadNew) {
        [self createHeaderView];
    }
    else {
        [self removeHeaderView];
    }
}

- (void)setEnableLoadMore:(BOOL)enableLoadMore
{
    _enableLoadMore = enableLoadMore;
    if (_enableLoadMore) {
        [self creatFooterView];
    }
    else {
        [self removeFooterView];
    }
}


- (void)setNoData:(BOOL)noData{
    _noData = noData;
    [self setNoData:noData withText:@"暂无数据"];
}

- (void)setNoData:(BOOL)noData withText:(NSString *)tips{
    
    [self setNoDataInAllSections:NO noData:noData withText:tips];
    
}

- (void)setNoDataInAllSections:(BOOL)showNoDataInAllSections noData:(BOOL)noData withText:(NSString *)tips{
    
    if (noData)
    {
        if (!_viewNoData) {
            _viewNoData =  [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 50)];
            
            UILabel *labelTips = [[UILabel alloc] initWithFrame:_viewNoData.frame];
//            labelTips.frame.origin.y = 0;
            labelTips.textAlignment = NSTextAlignmentCenter;
            labelTips.tag = 111;
            labelTips.font = [UIFont systemFontOfSize:14.0f];
            labelTips.text = tips;
            [_viewNoData addSubview:labelTips];
            
        }
        
        if (showNoDataInAllSections)
        {
            UILabel *labelTips = [_viewNoData viewWithTag:111];
            labelTips.text = tips;
            [self addSubview:_viewNoData];
        }
        else
        {
            if (self.numberOfSections > 0 && [self numberOfRowsInSection:0]) {
                //有内容不显示
            }
            else{
                UILabel *labelTips = [_viewNoData viewWithTag:111];
                labelTips.text = tips;
                [self addSubview:_viewNoData];
            }
        }
        
    }
    else
    {
        if (_viewNoData.superview) {
            [_viewNoData removeFromSuperview];
        }
    }

}


- (void)setNoMoreData:(BOOL)noMoreData{
    _noMoreData = noMoreData;
    if (_noMoreData) {
         [self.mj_footer endRefreshingWithNoMoreData];
    }
    else{
        [self.mj_footer resetNoMoreData];
    }
}

#pragma mark - Public
- (void)showLoadingView:(BOOL)isShow {
    if (isShow) {
        if (!_viewLoadingState)
        {
            _viewLoadingState = [[UIView alloc] initWithFrame:self.bounds];
            _viewLoadingState.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

           
            UIActivityIndicatorView *indicator = [UIActivityIndicatorView new];
            indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
            [indicator startAnimating];
            
            
            
            UILabel *label = [UILabel new];
            label.text = @"加载中...";
            label.font = [UIFont systemFontOfSize:13.0];
            label.textColor = [UIColor blackColor];
            label.backgroundColor   = [UIColor clearColor];
            label.textAlignment     = NSTextAlignmentLeft;
            
          
            label.center = CGPointMake(self.bounds.size.width/2.0+50, indicator.center.y+40);
            
            [_viewLoadingState addSubview:indicator];
            [_viewLoadingState addSubview:label];
            indicator.tag   = 11;
            label.tag       = 12;
            
           
            [indicator mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.height.mas_equalTo(30);
                make.centerX.equalTo(_viewLoadingState.mas_centerX).offset(-30);
                make.centerY.equalTo(_viewLoadingState.mas_centerY).offset(-30);
            }];
            
            [label mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(100);
                make.height.mas_equalTo(20);
                make.left.equalTo(indicator.mas_right).offset(10);
                make.centerY.equalTo(indicator.mas_centerY);

            }];

        }
        if (self.numberOfSections > 0 && [self numberOfRowsInSection:0]) {
            // 有内容时不显示loading
        }
        else
        {
            [self addSubview:_viewLoadingState];
            [(UIActivityIndicatorView *)[_viewLoadingState viewWithTag:11] startAnimating];
        }
        
        
        // 不同时出现加载失败
        [self setLoadFailed:NO];
    }
    else {
        if (_viewLoadingState.superview) {
            [(UIActivityIndicatorView *)[_viewLoadingState viewWithTag:11] stopAnimating];
            [_viewLoadingState removeFromSuperview];
        }
        
    }
    
}

- (void)setLoadFailed:(BOOL)isFailed {
    
    if (isFailed) {
        if (!_viewLoadFailed) {
            UIView *faildView = [[UIView alloc] initWithFrame:self.bounds];
            faildView.backgroundColor = [UIColor colorWithRed:17/255.0 green:17/255.0 blue:17/255.0 alpha:1.0];
            faildView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
            
            UILabel *faildTitle     = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 22)];
            faildTitle.textColor    = [UIColor colorWithRed:129/255.0 green:129/255.0 blue:129/255.0 alpha:1.0];
            faildTitle.backgroundColor = [UIColor clearColor];
            faildTitle.font         = [UIFont systemFontOfSize:14];
            faildTitle.textAlignment = NSTextAlignmentCenter;
            faildTitle.text         = @"网络未连接";
            
            UILabel *faildMsg       = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 20)];
            faildMsg.textColor      = faildTitle.textColor;
            faildMsg.backgroundColor = [UIColor clearColor];
            faildMsg.font           = [UIFont systemFontOfSize:12];
            faildMsg.textAlignment  = NSTextAlignmentCenter;
            faildMsg.text           = @"请检查网络后重新加载页面";
            
            faildTitle.center       = CGPointMake(self.bounds.size.width/2.0, self.bounds.size.height * 0.3);
            faildMsg.center         = CGPointMake(faildTitle.center.x, faildTitle.center.y + 30);
            
            // 重新加载 按钮
            UIButton *retryBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [retryBtn setBackgroundImage:[[UIImage imageNamed:@"btn_pub_rect_green"] resizableImageWithCapInsets:UIEdgeInsetsMake(7, 7, 7, 7)]
                                forState:UIControlStateNormal];
            retryBtn.frame = CGRectMake(0, 0, 100, 25);
            [retryBtn setTitle:@"重新加载" forState:UIControlStateNormal];
            retryBtn.titleLabel.font = [UIFont systemFontOfSize:12];
            retryBtn.center         = CGPointMake(faildTitle.center.x, faildMsg.center.y + 50);
            [retryBtn addTarget:self action:@selector(onReload:) forControlEvents:UIControlEventTouchUpInside];
            
            [faildView addSubview:faildTitle];
            [faildView addSubview:faildMsg];
            [faildView addSubview:retryBtn];
            
            _viewLoadFailed = faildView;
            
        }
        [self addSubview:_viewLoadFailed];
        
        // 不同时出现 loading
        [self showLoadingView:NO];
    }
    else {
        if (_viewLoadFailed.superview) {
            [_viewLoadFailed removeFromSuperview];
        }
    }
    
}


#pragma mark - override

- (void)reloadData {
    [super reloadData];
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(tableView:numberOfRowsInSection:)]) {
        if ([self.dataSource respondsToSelector:@selector(numberOfSectionsInTableView:)]) {
            if ([self.dataSource numberOfSectionsInTableView:self] > 0 && [self.dataSource tableView:self numberOfRowsInSection:0] > 0) {
                [self setLoadFailed:NO];
                [self showLoadingView:NO];
                [self setNoData:NO];
            }
        }
        else {
            if ( [self.dataSource tableView:self numberOfRowsInSection:0] > 0 ) {
                [self setLoadFailed:NO];
                [self showLoadingView:NO];
                [self setNoData:NO];
            }
        }
        
    }
}


#pragma mark - Private

- (void)onReload:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(refreshTableViewLoadNew:)]) {
        [self.delegate performSelector:@selector(refreshTableViewLoadNew:) withObject:self];
    }
    [_viewLoadFailed removeFromSuperview];
}

#pragma mark - MJRefresh

- (void)loadNew
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(refreshTableViewLoadNew:)]) {
        [self.delegate performSelector:@selector(refreshTableViewLoadNew:) withObject:self];
    }
}

- (void)loadMore
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(refreshTableViewLoadmore:)]) {
        [self.delegate performSelector:@selector(refreshTableViewLoadmore:) withObject:self];
    }
}

@end
