//
//  YHPhotoBrowserView.m
//  photobrowser
//
//  Created by samuelandkevin on 16-12-14.
//  Copyright (c) 2016年 samuelandkevin. All rights reserved.
//

#import "YHPhotoBrowserView.h"
#import "UIImageView+WebCache.h"
#import "YHBrowserImageView.h"
#import "YHActionSheet.h"
 
//  ============在这里方便配置样式相关设置===========

//                      ||
//                      ||
//                      ||
//                     \\//
//                      \/

#import "YHPhotoBrowserConfig.h"

//  =============================================

@implementation YHPhotoBrowserView 
{
    UIScrollView *_scrollView;
    BOOL _hasShowedFistView;
//    UILabel *_indexLabel;//暂时pageControl代替
    UIPageControl *_pageControl;
//    UIButton *_saveButton;
    UIActivityIndicatorView *_indicatorView;
    BOOL _willDisappear;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = YHPhotoBrowserBackgrounColor;
    }
    return self;
}


#pragma mark - Life
- (void)didMoveToSuperview
{
    [self setupScrollView];
    
    [self setupToolbars];
}

- (void)setupScrollView
{
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.delegate = self;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.pagingEnabled = YES;
    [self addSubview:_scrollView];
    
    for (int i = 0; i < self.imageCount; i++) {
        YHBrowserImageView *imageView = [[YHBrowserImageView alloc] init];
        imageView.tag = i;
        
        // 单击图片
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoClick:)];
        
        // 双击放大图片
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewDoubleTaped:)];
        doubleTap.numberOfTapsRequired = 2;
        
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewLongPressed:)];
        
        [singleTap requireGestureRecognizerToFail:doubleTap];
        
        [imageView addGestureRecognizer:singleTap];
        [imageView addGestureRecognizer:doubleTap];
        [imageView addGestureRecognizer:longPress];
        [_scrollView addSubview:imageView];
    }
    
    [self setupImageOfImageViewForIndex:self.currentImageIndex];
    
}

- (void)dealloc
{
    [[UIApplication sharedApplication].keyWindow removeObserver:self forKeyPath:@"frame"];
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect rect = self.bounds;
    rect.size.width += YHPhotoBrowserImageViewMargin * 2;
    
    _scrollView.bounds = rect;
    _scrollView.center = self.center;
    
    CGFloat y = 0;
    CGFloat w = _scrollView.frame.size.width - YHPhotoBrowserImageViewMargin * 2;
    CGFloat h = _scrollView.frame.size.height;
    
    
    
    [_scrollView.subviews enumerateObjectsUsingBlock:^(YHBrowserImageView *obj, NSUInteger idx, BOOL *stop) {
        CGFloat x = YHPhotoBrowserImageViewMargin + idx * (YHPhotoBrowserImageViewMargin * 2 + w);
        obj.frame = CGRectMake(x, y, w, h);
    }];
    
    _scrollView.contentSize = CGSizeMake(_scrollView.subviews.count * _scrollView.frame.size.width, 0);
    _scrollView.contentOffset = CGPointMake(self.currentImageIndex * _scrollView.frame.size.width, 0);
    
    
    if (!_hasShowedFistView) {
        [self showFirstImage];
    }
    
//    _indexLabel.center = CGPointMake(self.bounds.size.width * 0.5, 35);
//    _saveButton.frame = CGRectMake(10, self.bounds.size.height - 50, 50, 25);
}

//是否已缓存原图
- (BOOL)hasHighQImage{
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    __block BOOL hasHighQImage = NO;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(10);
    [manager diskImageExistsForURL:[self highQualityImageURLForIndex:self.currentImageIndex] completion:^(BOOL isInCache) {
        hasHighQImage = isInCache;
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return hasHighQImage;
}

//显示原图
- (void)showOriImage{
    
    UIView *sourceView = nil;
    if (_currentImageView) {
        sourceView = _currentImageView;
    }else{
        sourceView = self.sourceImagesContainerView.subviews[self.currentImageIndex];
    }

    CGRect rect = [self.sourceImagesContainerView convertRect:sourceView.frame toView:self];
    UIImageView *tempView = [[UIImageView alloc] init];
    tempView.image = [[[SDWebImageManager sharedManager] imageCache] imageFromDiskCacheForKey:[self highQualityImageURLForIndex:self.currentImageIndex].absoluteString];
    [self addSubview:tempView];
    CGRect targetTemp = _scrollView.subviews[self.currentImageIndex].bounds;
    
    tempView.frame = rect;
    tempView.contentMode = [_scrollView.subviews[self.currentImageIndex] contentMode];
    _scrollView.hidden = YES;
    
    [UIView animateWithDuration:YHPhotoBrowserShowImageAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        tempView.center = self.center;
        tempView.bounds = (CGRect){CGPointZero, targetTemp.size};
    } completion:^(BOOL finished) {
        _hasShowedFistView = YES;
        [tempView removeFromSuperview];
        _scrollView.hidden = NO;
        
    }];

}

//显示缩略图
- (void)showThumbImage{
    
    UIView *sourceView = nil;
    if (_currentImageView) {
        sourceView = _currentImageView;
    }else{
        sourceView = self.sourceImagesContainerView.subviews[self.currentImageIndex];
    }

    CGRect rect = [self.sourceImagesContainerView convertRect:sourceView.frame toView:self];
    
    UIImageView *tempView = [[UIImageView alloc] init];
    tempView.image = [self placeholderImageForIndex:self.currentImageIndex];
    
    [self addSubview:tempView];
    CGRect targetTemp = _scrollView.subviews[self.currentImageIndex].bounds;
    
    tempView.frame = rect;
    tempView.contentMode = [_scrollView.subviews[self.currentImageIndex] contentMode];
    _scrollView.hidden = YES;
    
    [UIView animateWithDuration:YHPhotoBrowserShowImageAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        tempView.center = self.center;
        tempView.bounds = (CGRect){CGPointZero, targetTemp.size};
    } completion:^(BOOL finished) {
        _hasShowedFistView = YES;
        [tempView removeFromSuperview];
        _scrollView.hidden = NO;
        
    }];

}

- (void)showFirstImage
{
    if ([self hasHighQImage]) {
        [self showOriImage];
    }
    else{
        [self showThumbImage];
    }
}



- (void)setupToolbars
{
    
    // 1. 序标
//    UILabel *indexLabel = [[UILabel alloc] init];
//    indexLabel.bounds = CGRectMake(0, 0, 80, 30);
//    indexLabel.textAlignment = NSTextAlignmentCenter;
//    indexLabel.textColor = [UIColor whiteColor];
//    indexLabel.font = [UIFont boldSystemFontOfSize:16];
//    indexLabel.clipsToBounds = YES;
//    if (self.imageCount > 1) {
//        indexLabel.text = [NSString stringWithFormat:@"1/%ld", (long)self.imageCount];
//    }
//    _indexLabel = indexLabel;
//    [self addSubview:indexLabel];
    
    if (self.imageCount > 1 )
    {
        UIPageControl *pCtrl = [[UIPageControl alloc] init];
        pCtrl.frame =  CGRectMake((self.bounds.size.width-60)/2, self.bounds.size.height-30, 80, 30);
        pCtrl.numberOfPages = self.imageCount;
        [self addSubview:pCtrl];
        _pageControl = pCtrl;
    }
   
    
    
//    // 2.保存按钮
//    UIButton *saveButton = [[UIButton alloc] init];
//    [saveButton setTitle:@"保存" forState:UIControlStateNormal];
//    [saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    saveButton.clipsToBounds = YES;
//    [saveButton addTarget:self action:@selector(saveImage) forControlEvents:UIControlEventTouchUpInside];
//    saveButton.backgroundColor     = kBlueColor;
//    saveButton.layer.cornerRadius  = 3;
//    saveButton.layer.masksToBounds = YES;
//    _saveButton = saveButton;
//    [self addSubview:saveButton];
}

- (void)saveImage
{
    int index = _scrollView.contentOffset.x / _scrollView.bounds.size.width;
    UIImageView *currentImageView = _scrollView.subviews[index];
    
    UIImageWriteToSavedPhotosAlbum(currentImageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] init];
    indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    indicator.center = self.center;
    _indicatorView = indicator;
    [[UIApplication sharedApplication].keyWindow addSubview:indicator];
    [indicator startAnimating];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
{
    [_indicatorView removeFromSuperview];
    
    UILabel *label = [[UILabel alloc] init];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:0.90f];
    label.layer.cornerRadius = 5;
    label.clipsToBounds = YES;
    label.bounds = CGRectMake(0, 0, 150, 30);
    label.center = self.center;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont boldSystemFontOfSize:14];
    [[UIApplication sharedApplication].keyWindow addSubview:label];
    [[UIApplication sharedApplication].keyWindow bringSubviewToFront:label];
    if (error) {
        label.text = YHPhotoBrowserSaveImageFailText;
    }   else {
        label.text = YHPhotoBrowserSaveImageSuccessText;
    }
    [label performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:1.0];
}

#pragma mark - Lazy Load

- (void)setCurrentImageView:(UIView *)currentImageView{
    _currentImageView = currentImageView;
    _currentImageIndex = 0;
    _sourceImagesContainerView = _currentImageView.superview;
    _imageCount = 1;

}

#pragma mark - Gesture
- (void)photoClick:(UITapGestureRecognizer *)recognizer
{
    _scrollView.hidden = YES;
    _willDisappear = YES;
    
    YHBrowserImageView *currentImageView = (YHBrowserImageView *)recognizer.view;
    NSInteger currentIndex = currentImageView.tag;
    
    UIView *sourceView = nil;
    if (_currentImageView) {
        sourceView = _currentImageView;
    }else{
        sourceView = self.sourceImagesContainerView.subviews[currentIndex];
    }
    
    
    CGRect targetTemp = [self.sourceImagesContainerView convertRect:sourceView.frame toView:self];
    
    UIImageView *tempView = [[UIImageView alloc] init];
    tempView.contentMode = sourceView.contentMode;
    tempView.clipsToBounds = YES;
    tempView.image = currentImageView.image;
    CGFloat h = (self.bounds.size.width / currentImageView.image.size.width) * currentImageView.image.size.height;
    
    if (!currentImageView.image) { // 防止 因imageview的image加载失败 导致 崩溃
        h = self.bounds.size.height;
    }
    
    tempView.bounds = CGRectMake(0, 0, self.bounds.size.width, h);
    tempView.center = self.center;
    
    [self addSubview:tempView];

//    _saveButton.hidden = YES;
    
    
    [UIView animateWithDuration:YHPhotoBrowserHideImageAnimationDuration delay:0 options:UIViewAnimationOptionTransitionCurlUp animations:^{
        tempView.frame = targetTemp;
        self.backgroundColor = [UIColor clearColor];
//        _indexLabel.alpha = 0.1;
    } completion:^(BOOL finished) {
         [self removeFromSuperview];
       
    }];
}

- (void)imageViewDoubleTaped:(UITapGestureRecognizer *)recognizer
{
    YHBrowserImageView *imageView = (YHBrowserImageView *)recognizer.view;
    CGFloat scale;
    if (imageView.isScaled) {
        scale = 1.0;
    } else {
        scale = 2.0;
    }
    
    YHBrowserImageView *view = (YHBrowserImageView *)recognizer.view;

    [view doubleTapToZommWithScale:scale];
}

- (void)imageViewLongPressed:(UILongPressGestureRecognizer *)gesture{
    if(gesture.state == UIGestureRecognizerStateBegan){
        __weak typeof(self)weakSelf = self;
        YHActionSheet *aSheet = [[YHActionSheet alloc] initWithCancelTitle:@"取消" otherTitles:@[@"保存图片"]];
        [aSheet dismissForCompletionHandle:^(NSInteger clickedIndex, BOOL isCancel) {
            if (!isCancel) {
                switch (clickedIndex) {
                    case 0:
                        DDLog(@"保存图片");
                        [weakSelf saveImage];
                        break;
                        
                    default:
                        break;
                }
            }
        }];
        [aSheet show];
    }
  
}


#pragma mark - Public
- (void)show
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    self.frame = window.bounds;
    [window addObserver:self forKeyPath:@"frame" options:0 context:nil];
    [window addSubview:self];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(UIView *)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"frame"]) {
        self.frame = object.bounds;
        YHBrowserImageView *currentImageView = _scrollView.subviews[_currentImageIndex];
        if ([currentImageView isKindOfClass:[YHBrowserImageView class]]) {
            [currentImageView clear];
        }
    }
}


#pragma mark - Private
- (UIImage *)placeholderImageForIndex:(NSInteger)index
{
    if ([self.delegate respondsToSelector:@selector(photoBrowser:placeholderImageForIndex:)]) {
        return [self.delegate photoBrowser:self placeholderImageForIndex:index];
    }
    return nil;
}

- (NSURL *)highQualityImageURLForIndex:(NSInteger)index
{
    if ([self.delegate respondsToSelector:@selector(photoBrowser:highQualityImageURLForIndex:)]) {
        return [self.delegate photoBrowser:self highQualityImageURLForIndex:index];
    }
    return nil;
}

// 加载图片
- (void)setupImageOfImageViewForIndex:(NSInteger)index
{
    YHBrowserImageView *imageView = _scrollView.subviews[index];
    self.currentImageIndex = index;
    if (imageView.hasLoadedImage) return;
    
    if ([self hasHighQImage]) {
        imageView.image = [[[SDWebImageManager sharedManager] imageCache] imageFromDiskCacheForKey:[self highQualityImageURLForIndex:self.currentImageIndex].absoluteString];
    }
    else{
        if ([self highQualityImageURLForIndex:index]) {
            [imageView setImageWithURL:[self highQualityImageURLForIndex:index] placeholderImage:[self placeholderImageForIndex:index]];
        } else {
            imageView.image = [self placeholderImageForIndex:index];
        }

    }
    
    imageView.hasLoadedImage = YES;
}

#pragma mark - scrollview代理方法

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int index = (scrollView.contentOffset.x + _scrollView.bounds.size.width * 0.5) / _scrollView.bounds.size.width;
    
    // 有过缩放的图片在拖动一定距离后清除缩放
    CGFloat margin = 150;
    CGFloat x = scrollView.contentOffset.x;
    CGFloat distance = x - index * _scrollView.bounds.size.width;
    if (distance > margin || distance < - margin) {
        YHBrowserImageView *imageView = _scrollView.subviews[index];
        if (imageView.isScaled) {
            [UIView animateWithDuration:0.5 animations:^{
                imageView.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                [imageView eliminateScale];
            }];
        }
    }
    
    
    if (!_willDisappear) {
//        _indexLabel.text = [NSString stringWithFormat:@"%d/%ld", index + 1, (long)self.imageCount];
        _pageControl.currentPage = index;
    }
    [self setupImageOfImageViewForIndex:index];
}



@end
