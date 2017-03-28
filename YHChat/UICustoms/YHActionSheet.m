//
//  YHActionSheet.m
//  samuelandkevin
//
//  Created by samuelandkevin on 16/4/28.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//

#import "YHActionSheet.h"


const CGFloat YH_Edges = 15.; //左右边距
const CGFloat rowHeight = 44.0f;
const CGFloat footerHeight = 10.0f;
const CGFloat cornerRadius = 10.0f;//圆角大小
/************YHSheetItem************/
@interface YHSheetItem : UITableViewCell

@property (nonatomic,assign) NSInteger otherTitlesCount;

@end

@implementation YHSheetItem

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
     
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(YH_Edges, 0, SCREEN_WIDTH-YH_Edges*2, rowHeight)];
        labelTitle.tag = 101;
        labelTitle.backgroundColor = [UIColor whiteColor];
        labelTitle.textColor = RGBCOLOR(0, 106, 251);
        labelTitle.textAlignment = NSTextAlignmentCenter;

        [self.contentView addSubview:labelTitle];
        
    }
    return self;
}


/**
 *  为Label设置圆角，奇数行：左上角.右上角为圆角;偶数行:左下角.右下角为圆角
 *
 *  @param labelTitle 标题Label
 *  @param row        行号
 *  @param allCorner  是否四个角都为圆角
 */
- (void)setRectCornerWithLabelTitle:(UILabel *)labelTitle row:(NSInteger)row allCorner:(BOOL)allCorner{
    
    UIBezierPath * bezierPath =  nil;
    if(allCorner){
        bezierPath = [UIBezierPath bezierPathWithRoundedRect:labelTitle.bounds byRoundingCorners:UIRectCornerBottomLeft|UIRectCornerBottomRight|UIRectCornerTopLeft|UIRectCornerTopRight cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
    }else{
       
        if(_otherTitlesCount == 1){
            bezierPath = [UIBezierPath bezierPathWithRoundedRect:labelTitle.bounds byRoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight|UIRectCornerBottomLeft|UIRectCornerBottomRight cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
        }
        else{
            if (row == 0) {
                 bezierPath = [UIBezierPath bezierPathWithRoundedRect:labelTitle.bounds byRoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
            }
            else if(row == _otherTitlesCount-1){
                bezierPath = [UIBezierPath bezierPathWithRoundedRect:labelTitle.bounds byRoundingCorners:UIRectCornerBottomLeft|UIRectCornerBottomRight cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
            }
            else{
                bezierPath = [UIBezierPath bezierPathWithRect:labelTitle.bounds ];
            
            }
       }
            
      
    
    }
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame       = labelTitle.bounds;
    maskLayer.path        = bezierPath.CGPath;
    labelTitle.layer.mask = maskLayer;
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    UIView *view = [self valueForKey:@"_separatorView"];
    if (view) {
        CGRect frame = view.frame;
        frame.origin.x = YH_Edges;
        frame.size.width = CGRectGetWidth(self.bounds)- 2*YH_Edges;
        view.frame = frame;
    }
}

@end


/************YHActionSheet************/
@interface YHActionSheet ()<UITableViewDataSource,UITableViewDelegate>

@property (strong,nonatomic) UIView *backgroundView;//背景图
@property (strong,nonatomic) UITableView *tableview;

@property (nullable, nonatomic, copy) YHSheetCompletionHanlde completionHanlde;

@end

@implementation YHActionSheet

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (instancetype )initWithCancelTitle:(NSString *)cancelTitle otherTitles:(NSArray *)otherTitles{
    if (self = [super init]) {
        self.cancelTitle = cancelTitle;
        self.otherTitles = otherTitles;
        [self initSubViews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        
         self.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    }
    return self;
}

#pragma mark - Touch
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    UITouch *touch = (UITouch *)touches.anyObject;
    if (touch.view == self.backgroundView) {
        if (_completionHanlde) {
            self.completionHanlde(NSNotFound, YES);
        }
        [self dismissViewAnimation];
    }
}

#pragma mark - initUI


- (void)initSubViews{
    //1.tableview
    //tableview高度 = （其他标题+取消标题）*行高 + footer高度*2
    CGFloat tableviewH = rowHeight*([self.otherTitles count]+1) + footerHeight*2;
    
    self.tableview = [[UITableView alloc] initWithFrame:CGRectMake(0,SCREEN_HEIGHT + tableviewH, SCREEN_WIDTH, tableviewH) style:UITableViewStylePlain];
    self.tableview.backgroundColor = [UIColor clearColor];
    
    self.tableview.scrollEnabled = NO;
    self.tableview.showsVerticalScrollIndicator = NO;
    self.tableview.dataSource = self;
    self.tableview.delegate = self;

    //2.背景view
    self.backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT)];
    self.backgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];

}


#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger index = indexPath.row;
    
    [self dismissViewAnimation];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_completionHanlde) {
        self.completionHanlde(index, indexPath.section == 1 ? YES : NO);
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *footerView =[[UIView alloc] init];
    footerView.backgroundColor = [UIColor clearColor];
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
   
    return footerHeight;

}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return [self.otherTitles count];
    }else{
        return 1;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    YHSheetItem *cell =[tableView dequeueReusableCellWithIdentifier:@"cellId"];
    if (!cell) {
        cell = [[YHSheetItem alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellId"];
    }
     cell.otherTitlesCount = [self.otherTitles count];
    
     UILabel *label = [cell.contentView viewWithTag:101];
    if (indexPath.section == 0) {
        label.text = self.otherTitles[indexPath.row];
         [cell setRectCornerWithLabelTitle:label row:indexPath.row allCorner:NO];
    }
    else{
        label.text = self.cancelTitle;
        [cell setRectCornerWithLabelTitle:label row:indexPath.row allCorner:YES];
    }
   
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return rowHeight;
}

#pragma mark - Private
- (UIWindow *)statusBarWindow {
    return [[UIApplication sharedApplication] valueForKey:@"_statusBarWindow"];
}
- (UIInterfaceOrientation)appInterface {
    return [UIApplication sharedApplication].statusBarOrientation;
}

- (void)showViewAnimation {
    __weak typeof(self) wSelf = self;
    
    self.backgroundView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);

    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = _tableview.frame;
        frame.origin.y = CGRectGetHeight(wSelf.bounds) - frame.size.height;
        wSelf.tableview.frame = frame;
    }];
}

- (void)dismissViewAnimation {
    
    __weak typeof(self) wSelf = self;
    
    self.backgroundView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT);

    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = _tableview.frame;
        frame.origin.y = CGRectGetHeight(wSelf.bounds);
        wSelf.tableview.frame = frame;
        
    } completion:^(BOOL finished) {
        if (finished) {
            [wSelf removeFromSuperview];
        }
    }];
}


#pragma mark - Public
- (void)show{
    UIWindow *statusBarWindow = [self statusBarWindow];
    [statusBarWindow addSubview:self];
    [self addSubview:self.backgroundView];
    [self addSubview:self.tableview];
    [self showViewAnimation];
}

- (void)dismissForCompletionHandle:(nullable YHSheetCompletionHanlde)handle{
    self.completionHanlde = handle;
}




@end
