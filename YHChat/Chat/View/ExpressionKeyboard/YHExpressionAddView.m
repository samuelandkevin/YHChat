//
//  YHExpressionAddView.m
//  Expression
//
//  Created by samuelandkevin on 17/2/9.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "YHExpressionAddView.h"
#import "YYKit.h"
#import "Masonry.h"
#import "YHExpressionHelper.h"
#import "YHModel.h"




@interface YHExpressionAddCell()
@property (nonatomic,strong) UIButton    *btnIcon;
@property (nonatomic,strong) UILabel     *lbName;
@end

@implementation YHExpressionAddCell

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    _btnIcon = [UIButton new];
    _btnIcon.userInteractionEnabled = NO;
    [self.contentView addSubview:_btnIcon];
    
    _lbName = [UILabel new];
    _lbName.font = [UIFont systemFontOfSize:14.0];
    _lbName.textAlignment = NSTextAlignmentCenter;
    _lbName.textColor     = [UIColor blackColor];
    [self.contentView addSubview:_lbName];
    
    [self layoutUI];
}

- (void)setModel:(YHExtraModel *)model{
    
    _model = model;
    
    [_btnIcon setImage:[YHExpressionHelper imageNamed:_model.icon_nor] forState:UIControlStateNormal];
    [_btnIcon setImage:[YHExpressionHelper imageNamed:_model.icon_sel] forState:UIControlStateSelected];
    _lbName.text = _model.name;
}

- (void)layoutUI{
    __weak typeof(self) weakSelf = self;
    [_btnIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf.contentView);
        make.width.height.mas_equalTo(50);
        make.top.equalTo(weakSelf.contentView).offset(10);
    }];
    
    
    [_lbName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.btnIcon.mas_bottom).offset(3);
        make.left.right.equalTo(weakSelf.contentView);
    }];
}

@end




#define kOneItemHeight 90
#define kOnePageCount  8

@interface YHExpressionAddView()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIView *pageControl;
@property (nonatomic, strong) NSArray *dataArray;
@end

@implementation YHExpressionAddView


+ (instancetype)sharedView {
    static YHExpressionAddView *v;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        v = [self new];
    });
    return v;
}

- (instancetype)init {
    self = [super init];
    
    self.backgroundColor = UIColorHex(f9f9f9);
    self.dataArray = [YHExpressionHelper extraModels];
    

    [self _initCollectionView];
   

    return self;
}

- (NSArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [NSArray new];
    }
    return _dataArray;
}


- (void)_initCollectionView {
    

    CGFloat itemWidth = (kScreenWidth - 10 * 2) / 4.0;
    itemWidth = CGFloatPixelRound(itemWidth);
    CGFloat padding = (kScreenWidth - 4 * itemWidth) / 2.0;
    CGFloat paddingLeft = CGFloatPixelRound(padding);
    CGFloat paddingRight = kScreenWidth - paddingLeft - itemWidth * 4;
   
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(itemWidth, kOneItemHeight);
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    layout.sectionInset = UIEdgeInsetsMake(0, paddingLeft, 0, paddingRight);
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kOneItemHeight * 2) collectionViewLayout:layout];
    _collectionView.backgroundColor = UIColorHex(F9F9F9);
    [_collectionView registerClass:[YHExpressionAddCell class] forCellWithReuseIdentifier:@"cell1"];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [self addSubview:_collectionView];
    
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, CGFloatFromPixel(1))];
    line.backgroundColor = UIColorHex(BFBFBF);
    [_collectionView addSubview:line];
    
    _pageControl = [UIView new];
    _pageControl.size = CGSizeMake(kScreenWidth, 20);
    _pageControl.top = _collectionView.bottom - 5;
    _pageControl.userInteractionEnabled = NO;
    [self addSubview:_pageControl];
    
    //kun调试
//    _collectionView.backgroundColor = [UIColor orangeColor];
//    _pageControl.backgroundColor = [UIColor purpleColor];
    
}



#pragma mark - @protocol UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    YHExtraModel *model = [self _modelForIndexPath:indexPath];
    if (model && _delegate && [_delegate respondsToSelector:@selector(extraItemDidTap:)]) {
        DDLog(@"%@",model.name);
        [_delegate extraItemDidTap:model];
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

#pragma mark - @protocol UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return kOnePageCount;
}


- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    YHExpressionAddCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell1" forIndexPath:indexPath];
    cell.model = [self _modelForIndexPath:indexPath];
    return cell;
}

- (YHExtraModel *)_modelForIndexPath:(NSIndexPath *)indexPath {
  
    
    NSUInteger page  = 0;
    NSUInteger index = page * kOnePageCount + indexPath.row;
    
    // transpose line/row
    NSUInteger ip = index / kOnePageCount;
    NSUInteger ii = index % kOnePageCount;
    NSUInteger reIndex = (ii % 2) * 4 + (ii / 2);
    index = reIndex + ip * kOnePageCount;
    
    if (index < self.dataArray.count) {
        return self.dataArray[index];
    } else {
        return nil;
    }
    return nil;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
