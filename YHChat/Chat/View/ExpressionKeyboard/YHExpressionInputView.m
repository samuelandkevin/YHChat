//
//  YHExpressionInputView.m
//
//
//  Created by samuelandkevin on 17/2/8.
//  Copyright (C) 2017 samuelandkevin. All rights reserved.
//

#import "YHExpressionInputView.h"
#import "YHExpressionHelper.h"
#import "YHModel.h"

#define kViewHeight 216
#define kToolbarHeight 37
#define kOneEmoticonHeight 50
#define kOnePageCount 20


@interface YHEmoticonCell : UICollectionViewCell
@property (nonatomic, strong) YHEmoticon *emoticon;
@property (nonatomic, assign) BOOL isDelete;
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation YHEmoticonCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    _imageView = [UIImageView new];
    _imageView.size = CGSizeMake(32, 32);
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:_imageView];
    return self;
}

- (void)setEmoticon:(YHEmoticon *)emoticon {
    if (_emoticon == emoticon) return;
    _emoticon = emoticon;
    [self updateContent];
}

- (void)setIsDelete:(BOOL)isDelete {
    if (_isDelete == isDelete) return;
    _isDelete = isDelete;
    [self updateContent];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateLayout];
}

- (void)updateContent {
    [_imageView cancelCurrentImageRequest];
    _imageView.image = nil;
    
    if (_isDelete) {
        _imageView.image = [YHExpressionHelper imageNamed:@"compose_emotion_delete"];
    } else if (_emoticon) {
        if (_emoticon.type == YHEmoticonTypeEmoji) {
            NSNumber *num = [NSNumber numberWithString:_emoticon.code];
            NSString *str = [NSString stringWithUTF32Char:num.unsignedIntValue];
            if (str) {
                UIImage *img = [UIImage imageWithEmoji:str size:_imageView.width];
                _imageView.image = img;
            }
        } else if (_emoticon.group.groupID && _emoticon.png){
            NSString *pngPath = [[YHExpressionHelper emoticonBundle] pathForScaledResource:_emoticon.png ofType:nil inDirectory:_emoticon.group.groupID];
            if (!pngPath) {
                NSString *addBundlePath = [[YHExpressionHelper emoticonBundle].bundlePath stringByAppendingPathComponent:@"additional"];
                NSBundle *addBundle = [NSBundle bundleWithPath:addBundlePath];
                pngPath = [addBundle pathForScaledResource:_emoticon.png ofType:nil inDirectory:_emoticon.group.groupID];
            }
            if (pngPath) {
                [_imageView setImageWithURL:[NSURL fileURLWithPath:pngPath] options:YYWebImageOptionIgnoreDiskCache];
            }
        }
    }
}

- (void)updateLayout {
    _imageView.center = CGPointMake(self.width / 2, self.height / 2);
}

@end



@protocol YHEmoticonScrollViewDelegate <UICollectionViewDelegate>
- (void)emoticonScrollViewDidTapCell:(YHEmoticonCell *)cell;
@end

@interface YHEmoticonScrollView : UICollectionView
@end

@implementation YHEmoticonScrollView {
    NSTimeInterval *_touchBeganTime;
    BOOL _touchMoved;
    UIImageView *_magnifier;
    UIImageView *_magnifierContent;
    __weak YHEmoticonCell *_currentMagnifierCell;
    NSTimer *_backspaceTimer;
}

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    self = [super initWithFrame:frame collectionViewLayout:layout];
    self.backgroundColor = [UIColor clearColor];
    self.backgroundView = [UIView new];
    self.pagingEnabled = YES;
    self.showsHorizontalScrollIndicator = NO;
    self.clipsToBounds = NO;
    self.canCancelContentTouches = NO;
    self.multipleTouchEnabled = NO;
    _magnifier = [[UIImageView alloc] initWithImage:[YHExpressionHelper imageNamed:@"emoticon_keyboard_magnifier"]];
    _magnifierContent = [UIImageView new];
    _magnifierContent.size = CGSizeMake(40, 40);
    _magnifierContent.centerX = _magnifier.width / 2;
    [_magnifier addSubview:_magnifierContent];
    _magnifier.hidden = YES;
    [self addSubview:_magnifier];
    return self;
}

- (void)dealloc {
    [self endBackspaceTimer];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    _touchMoved = NO;
    YHEmoticonCell *cell = [self cellForTouches:touches];
    _currentMagnifierCell = cell;
    [self showMagnifierForCell:_currentMagnifierCell];
    
    if (cell.imageView.image && !cell.isDelete) {
        [[UIDevice currentDevice] playInputClick];
    }
    
    if (cell.isDelete) {
        [self endBackspaceTimer];
        [self performSelector:@selector(startBackspaceTimer) afterDelay:0.5];
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    _touchMoved = YES;
    if (_currentMagnifierCell && _currentMagnifierCell.isDelete) return;
    
    YHEmoticonCell *cell = [self cellForTouches:touches];
    if (cell != _currentMagnifierCell) {
        if (!_currentMagnifierCell.isDelete && !cell.isDelete) {
            _currentMagnifierCell = cell;
        }
        [self showMagnifierForCell:cell];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    YHEmoticonCell *cell = [self cellForTouches:touches];
    if ((!_currentMagnifierCell.isDelete && cell.emoticon) || (!_touchMoved && cell.isDelete)) {
        if ([self.delegate respondsToSelector:@selector(emoticonScrollViewDidTapCell:)]) {
            [((id<YHEmoticonScrollViewDelegate>) self.delegate) emoticonScrollViewDidTapCell:cell];
        }
    }
    [self hideMagnifier];
    [self endBackspaceTimer];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self hideMagnifier];
    [self endBackspaceTimer];
}

- (YHEmoticonCell *)cellForTouches:(NSSet<UITouch *> *)touches {
    UITouch *touch = touches.anyObject;
    CGPoint point = [touch locationInView:self];
    NSIndexPath *indexPath = [self indexPathForItemAtPoint:point];
    if (indexPath) {
        YHEmoticonCell *cell = (id)[self cellForItemAtIndexPath:indexPath];
        return cell;
    }
    return nil;
}

- (void)showMagnifierForCell:(YHEmoticonCell *)cell {
    if (cell.isDelete || !cell.imageView.image) {
        [self hideMagnifier];
        return;
    }
    CGRect rect = [cell convertRect:cell.bounds toView:self];
    _magnifier.centerX = CGRectGetMidX(rect);
    _magnifier.bottom = CGRectGetMaxY(rect) - 9;
    _magnifier.hidden = NO;
    
    _magnifierContent.image = cell.imageView.image;
    _magnifierContent.top = 20;
    
    [_magnifierContent.layer removeAllAnimations];
    NSTimeInterval dur = 0.1;
    [UIView animateWithDuration:dur delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        _magnifierContent.top = 3;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:dur delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            _magnifierContent.top = 6;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:dur delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                _magnifierContent.top = 5;
            } completion:^(BOOL finished) {
            }];
        }];
    }];
}

- (void)hideMagnifier {
    _magnifier.hidden = YES;
}

- (void)startBackspaceTimer {
    [self endBackspaceTimer];
    @weakify(self);
    _backspaceTimer = [NSTimer timerWithTimeInterval:0.1 block:^(NSTimer *timer) {
        @strongify(self);
        if (!self) return;
        YHEmoticonCell *cell = self->_currentMagnifierCell;
        if (cell.isDelete) {
            if ([self.delegate respondsToSelector:@selector(emoticonScrollViewDidTapCell:)]) {
                [[UIDevice currentDevice] playInputClick];
                [((id<YHEmoticonScrollViewDelegate>) self.delegate) emoticonScrollViewDidTapCell:cell];
            }
        }
    } repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_backspaceTimer forMode:NSRunLoopCommonModes];
}

- (void)endBackspaceTimer {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startBackspaceTimer) object:nil];
    [_backspaceTimer invalidate];
    _backspaceTimer = nil;
}
@end



@interface YHExpressionInputView () <UICollectionViewDelegate, UICollectionViewDataSource, UIInputViewAudioFeedback,YHEmoticonScrollViewDelegate>


@property (nonatomic, strong) UIView *viewTopline;
@property (nonatomic, strong) UIView *viewBotToolBar;
@property (nonatomic, strong) NSArray<UIButton *> *toolbarButtons;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIView *pageControl;
@property (nonatomic, strong) NSArray<YHEmoticonGroup *> *emoticonGroups;
@property (nonatomic, strong) NSArray<NSNumber *> *emoticonGroupPageIndexs;
@property (nonatomic, strong) NSArray<NSNumber *> *emoticonGroupPageCounts;
@property (nonatomic, assign) NSInteger emoticonGroupTotalPageCount;
@property (nonatomic, assign) NSInteger currentPageIndex;


@end


@implementation YHExpressionInputView

+ (instancetype)sharedView {
    static YHExpressionInputView *v;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        v = [self new];
    });
    return v;
}

- (instancetype)init {
    self = [super init];
   
    self.frame = CGRectMake(0, 0, SCREEN_WIDTH, kViewHeight);
    self.backgroundColor = UIColorHex(f9f9f9);
    [self _initGroups];
    
    [self _initUI];
    
    
    _currentPageIndex = NSNotFound;
    [self _toolbarBtnDidTapped:_toolbarButtons.firstObject];
    
    return self;
}

- (void)_initUI{
    [self _initTopLine];
    [self _initCollectionView];
    [self _initBottomToolbar];
}


- (void)_initGroups {
    _emoticonGroups = [YHExpressionHelper emoticonGroups];
    
    //获取各表情组起始页下标数组
    NSMutableArray *indexs = [NSMutableArray new];
    NSUInteger index = 0;
    for (YHEmoticonGroup *group in _emoticonGroups) {
        [indexs addObject:@(index)];
        NSUInteger count = ceil(group.emoticons.count / (float)kOnePageCount);
        if (count == 0) count = 1;
        index += count;
    }
    _emoticonGroupPageIndexs = indexs;
    
    //表情组总页数
    NSMutableArray *pageCounts = [NSMutableArray new];
    _emoticonGroupTotalPageCount = 0;
    for (YHEmoticonGroup *group in _emoticonGroups) {
        NSUInteger pageCount = ceil(group.emoticons.count / (float)kOnePageCount);
        if (pageCount == 0) pageCount = 1;
        [pageCounts addObject:@(pageCount)];
        _emoticonGroupTotalPageCount += pageCount;
    }
    _emoticonGroupPageCounts = pageCounts;
}

- (void)_initTopLine {
    _viewTopline = [UIView new];
    _viewTopline.width = self.width;
    _viewTopline.height = 1/[UIScreen mainScreen].scale;
    _viewTopline.backgroundColor = UIColorHex(bfbfbf);
    _viewTopline.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self addSubview:_viewTopline];
    
}

- (void)_initCollectionView {
    CGFloat itemWidth = (SCREEN_WIDTH - 10 * 2) / 7.0;
    itemWidth = CGFloatPixelRound(itemWidth);
    CGFloat padding = (SCREEN_WIDTH - 7 * itemWidth) / 2.0;
    CGFloat paddingLeft  = CGFloatPixelRound(padding);
    CGFloat paddingRight = SCREEN_WIDTH - paddingLeft - itemWidth * 7;
    
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(itemWidth, kOneEmoticonHeight);
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    layout.sectionInset = UIEdgeInsetsMake(0, paddingLeft, 0, paddingRight);
    
    _collectionView = [[YHEmoticonScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, kOneEmoticonHeight * 3) collectionViewLayout:layout];
   
    [_collectionView registerClass:[YHEmoticonCell class] forCellWithReuseIdentifier:@"cell"];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.top = 5;
    [self addSubview:_collectionView];
    
    _pageControl = [UIView new];
    _pageControl.size = CGSizeMake(SCREEN_WIDTH, 20);
    _pageControl.top = _collectionView.bottom - 5;
    _pageControl.userInteractionEnabled = NO;
    [self addSubview:_pageControl];
}


- (void)_initBottomToolbar {
    _viewBotToolBar = [UIView new];
    _viewBotToolBar.size = CGSizeMake(SCREEN_WIDTH, kToolbarHeight);
    
    UIImageView *bg = [[UIImageView alloc] initWithImage:[YHExpressionHelper imageNamed:@"compose_emotion_table_right_normal"]];
    bg.size = _viewBotToolBar.size;
    [_viewBotToolBar addSubview:bg];
    
    
    CGFloat btnSendWidth = 50;
    
    UIScrollView *scroll = [UIScrollView new];
    scroll.showsHorizontalScrollIndicator = NO;
    scroll.alwaysBounceHorizontal = YES;
    CGSize size = CGSizeMake(SCREEN_WIDTH-btnSendWidth, _viewBotToolBar.size.height);
    scroll.size = size;
    scroll.contentSize = size;
    [_viewBotToolBar addSubview:scroll];
    
    
    UIButton *btnSend = [UIButton new];
    btnSend.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [btnSend setTitle:@"发送" forState:UIControlStateNormal];
    [btnSend addTarget:self action:@selector(onBtnSend:) forControlEvents:UIControlEventTouchUpInside];
    btnSend.left = SCREEN_WIDTH - btnSendWidth;
    btnSend.size  = CGSizeMake(btnSendWidth, _viewBotToolBar.height);
    btnSend.backgroundColor = kGreenColor;
    [_viewBotToolBar addSubview:btnSend];
    
    NSMutableArray *btns = [NSMutableArray new];
    UIButton *btn;
    for (NSUInteger i = 0; i < _emoticonGroups.count; i++) {
        YHEmoticonGroup *group = _emoticonGroups[i];
        btn = [self _createToolbarButton];
        [btn setTitle:group.nameCN forState:UIControlStateNormal];
        btn.left = (SCREEN_WIDTH-btnSendWidth) / (float)_emoticonGroups.count * i;
        btn.tag = i;
        [scroll addSubview:btn];
        [btns addObject:btn];
    }
 
    _viewBotToolBar.bottom = self.height;
    [self addSubview:_viewBotToolBar];
    _toolbarButtons = btns;
}

- (UIButton *)_createToolbarButton {
    CGFloat btnSendBtnWidth = 50;
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.exclusiveTouch = YES;
    btn.size = CGSizeMake((SCREEN_WIDTH - btnSendBtnWidth) / _emoticonGroups.count, kToolbarHeight);
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitleColor:UIColorHex(5D5C5A) forState:UIControlStateSelected];
    
    UIImage *img;
    img = [YHExpressionHelper imageNamed:@"compose_emotion_table_left_normal"];
    img = [img resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, img.size.width - 1) resizingMode:UIImageResizingModeStretch];
    [btn setBackgroundImage:img forState:UIControlStateNormal];
    
    img = [YHExpressionHelper imageNamed:@"compose_emotion_table_left_selected"];
    img = [img resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, img.size.width - 1) resizingMode:UIImageResizingModeStretch];
    [btn setBackgroundImage:img forState:UIControlStateSelected];
    
    [btn addTarget:self action:@selector(_toolbarBtnDidTapped:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}


- (void)_toolbarBtnDidTapped:(UIButton *)btn {
    NSInteger groupIndex = btn.tag;
    NSInteger page = ((NSNumber *)_emoticonGroupPageIndexs[groupIndex]).integerValue;
    CGRect rect = CGRectMake(page * _collectionView.width, 0, _collectionView.width, _collectionView.height);
    [_collectionView scrollRectToVisible:rect animated:NO];
    [self scrollViewDidScroll:_collectionView];
}


#pragma mark - Action

- (void)onBtnSend:(UIButton *)sender{
    
    if (_delegate && [_delegate respondsToSelector:@selector(didTapSendBtn)]) {
        [_delegate didTapSendBtn];
    }
    
}


#pragma mark YHEmoticonScrollViewDelegate

- (void)emoticonScrollViewDidTapCell:(YHEmoticonCell *)cell {
    if (!cell) return;
    if (cell.isDelete) {
        if ([self.delegate respondsToSelector:@selector(emoticonInputDidTapBackspace)]) {
            [[UIDevice currentDevice] playInputClick];
            [self.delegate emoticonInputDidTapBackspace];
        }
    } else if (cell.emoticon) {
        NSString *text = nil;
        switch (cell.emoticon.type) {
            case YHEmoticonTypeImage: {
                text = cell.emoticon.chs;
            } break;
            case YHEmoticonTypeEmoji: {
                NSNumber *num = [NSNumber numberWithString:cell.emoticon.code];
                text = [NSString stringWithUTF32Char:num.unsignedIntValue];
            } break;
            default:break;
        }
        if (text && [self.delegate respondsToSelector:@selector(emoticonInputDidTapText:)]) {
            [self.delegate emoticonInputDidTapText:text];
        }
    }
}

#pragma mark UICollectionViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger page = round(scrollView.contentOffset.x / scrollView.width);
    if (page < 0) page = 0;
    else if (page >= _emoticonGroupTotalPageCount) page = _emoticonGroupTotalPageCount - 1;
    if (page == _currentPageIndex) return;
    _currentPageIndex = page;
    NSInteger curGroupIndex = 0, curGroupPageIndex = 0, curGroupPageCount = 0;
    for (NSInteger i = _emoticonGroupPageIndexs.count - 1; i >= 0; i--) {
        NSNumber *pageIndex = _emoticonGroupPageIndexs[i];
        if (page >= pageIndex.unsignedIntegerValue) {
            curGroupIndex = i;
            curGroupPageIndex = ((NSNumber *)_emoticonGroupPageIndexs[i]).integerValue;
            curGroupPageCount = ((NSNumber *)_emoticonGroupPageCounts[i]).integerValue;
            break;
        }
    }
    [_pageControl.layer removeAllSublayers];
    CGFloat padding = 5, width = 6, height = 2;
    CGFloat pageControlWidth = (width + 2 * padding) * curGroupPageCount;
    for (NSInteger i = 0; i < curGroupPageCount; i++) {
        CALayer *layer = [CALayer layer];
        layer.size = CGSizeMake(width, height);
        layer.cornerRadius = 1;
        if (page - curGroupPageIndex == i) {
            layer.backgroundColor = UIColorHex(fd8225).CGColor;
        } else {
            layer.backgroundColor = UIColorHex(dedede).CGColor;
        }
        layer.centerY = _pageControl.height / 2;
        layer.left = (_pageControl.width - pageControlWidth) / 2 + i * (width + 2 * padding) + padding;
        [_pageControl.layer addSublayer:layer];
    }
    [_toolbarButtons enumerateObjectsUsingBlock:^(UIButton *btn, NSUInteger idx, BOOL *stop) {
        btn.selected = (idx == curGroupIndex);
    }];
}


- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

#pragma mark UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return _emoticonGroupTotalPageCount;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return kOnePageCount + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    YHEmoticonCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    if (indexPath.row == kOnePageCount) {
        cell.isDelete = YES;
        cell.emoticon = nil;
    } else {
        cell.isDelete = NO;
        cell.emoticon = [self _emoticonForIndexPath:indexPath];
    }
    return cell;
}

- (YHEmoticon *)_emoticonForIndexPath:(NSIndexPath *)indexPath {
    NSUInteger section = indexPath.section;
    for (NSInteger i = _emoticonGroupPageIndexs.count - 1; i >= 0; i--) {
        NSNumber *pageIndex = _emoticonGroupPageIndexs[i];
        if (section >= pageIndex.unsignedIntegerValue) {
            YHEmoticonGroup *group = _emoticonGroups[i];
            NSUInteger page = section - pageIndex.unsignedIntegerValue;
            NSUInteger index = page * kOnePageCount + indexPath.row;
            
            // transpose line/row
            NSUInteger ip = index / kOnePageCount;
            NSUInteger ii = index % kOnePageCount;
            NSUInteger reIndex = (ii % 3) * 7 + (ii / 3);
            index = reIndex + ip * kOnePageCount;
            
            if (index < group.emoticons.count) {
                return group.emoticons[index];
            } else {
                return nil;
            }
        }
    }
    return nil;
}

#pragma mark @protocol UITextViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [_textView resignFirstResponder];
}

#pragma mark - UIInputViewAudioFeedback

- (BOOL)enableInputClicksWhenVisible {
    return YES;
}

@end
