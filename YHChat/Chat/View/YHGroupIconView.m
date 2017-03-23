//
//  YHGroupIconView.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by samuelandkevin on 2017/1/18.
//  Copyright © 2017年 YHSoft. All rights reserved.
//

#import "YHGroupIconView.h"
#import "UIImageView+WebCache.h"
#import "UIView+Extension.h"

#define kMaxMembersInIcon 9

@interface YHGroupIconFrame : NSObject

- (UIImageView *)iconWithMembersCount:(int)membersCount;

- (BOOL)hasCacheFrameAtIndex:(int)index membersCount:(int)membersCount;
- (CGRect)getCacheFrameAtIndexAtIndex:(int)index membersCount:(int)membersCount;
- (void)cacheFrame:(CGRect)frame atIndex:(int)index membersCount:(int)membersCount;
@end

@interface YHGroupIconFrame()
@property (nonatomic,strong)NSMutableDictionary *dictSuper;
@end

@implementation YHGroupIconFrame

+ (instancetype)shareInstanced{
    static YHGroupIconFrame *g_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_instance = [YHGroupIconFrame new];
    });
    return g_instance;
}

- (UIImageView *)iconWithMembersCount:(int)membersCount{
    if (membersCount == 1) {
        
    }
    return nil;
}


#pragma mark - Lazy Load

- (NSMutableDictionary *)dictSuper{
    if (!_dictSuper) {
        _dictSuper = [NSMutableDictionary new];
    }
    return _dictSuper;
}

#pragma mark - 缓存Frame相关
- (BOOL)hasCacheFrameAtIndex:(int)index membersCount:(int)membersCount{
    NSString *keySuper = [NSString stringWithFormat:@"%d",membersCount];
    NSMutableArray *arrayFrame = self.dictSuper[keySuper];
    if (!arrayFrame) {
        arrayFrame = [NSMutableArray new];
        [self.dictSuper setObject:arrayFrame forKey:keySuper];
    }
    NSString *frameAtIndex = nil;
    if (index < arrayFrame.count) {
        frameAtIndex = arrayFrame[index];
    }
    if (!frameAtIndex) {
        return NO;
    }
    return YES;
    
}

- (CGRect)getCacheFrameAtIndexAtIndex:(int)index membersCount:(int)membersCount{
    NSString *keySuper = [NSString stringWithFormat:@"%d",membersCount];
    NSMutableArray *arrayFrame = self.dictSuper[keySuper];
    NSString *frameAtIndex = nil;
    if (index < arrayFrame.count) {
        frameAtIndex = arrayFrame[index];
    }
    return CGRectFromString(frameAtIndex);
}

- (void)cacheFrame:(CGRect)frame atIndex:(int)index membersCount:(int)membersCount{
    NSString *keySuper = [NSString stringWithFormat:@"%d",membersCount];
    NSMutableArray *arrayFrame = self.dictSuper[keySuper];
    [arrayFrame addObject:NSStringFromCGRect(frame)];
    [self.dictSuper setObject:arrayFrame forKey:keySuper];
}


@end

@interface YHGroupIconView()

@property (nonatomic,strong)NSMutableArray *imageViewsArray;
@property (nonatomic,assign)CGFloat margin;
@property (nonatomic,assign)CGFloat containerW;

@end

@implementation YHGroupIconView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]){
        [self setup];
         self.margin = 1.5;
         self.containerW = 45;
    }
    return self;
}

- (void)setup
{
    NSMutableArray *temp = [NSMutableArray new];
    
    for (int i = 0; i < kMaxMembersInIcon; i++) {
        UIImageView *imageView = [UIImageView new];
        [self addSubview:imageView];
        imageView.tag = i;
        [temp addObject:imageView];
    }
    
    self.imageViewsArray = [temp copy];
}


#pragma mark - Life
- (void)layoutSubviews{
    [super layoutSubviews];
     self.containerW = self.bounds.size.width;
}

#pragma mark - Public
- (void)setPicUrlArray:(NSArray *)picUrlArray{
    _picUrlArray = picUrlArray;
    
    for (long i = _picUrlArray.count; i < self.imageViewsArray.count; i++) {
        UIImageView *imageView = [self.imageViewsArray objectAtIndex:i];
        imageView.hidden = YES;
    }
    
    if (_picUrlArray.count == 0) {
        return ;
    }
    
    //群图标最多显示9个成员
    NSUInteger membersInGroupIcon = _picUrlArray.count;
    if(_picUrlArray.count > kMaxMembersInIcon){
        membersInGroupIcon = kMaxMembersInIcon;
    }else{
        membersInGroupIcon = _picUrlArray.count;
    }
    

    for (int i = 0; i< membersInGroupIcon; i++) {
        NSURL *obj     =  _picUrlArray[i];

        UIImageView *imageView = self.imageViewsArray[i];
        CGFloat itemW = [self itemWidthAtIndex:i membersCount:(int)membersInGroupIcon imageView:imageView];
        imageView.layer.cornerRadius  = itemW/2;
        imageView.layer.masksToBounds = YES;
        imageView.hidden = NO;
        [imageView sd_setImageWithURL:obj placeholderImage:[UIImage imageNamed:@"common_avatar_120px"]  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {}
         ];
        

    }

}


- (CGFloat)itemWidthAtIndex:(int)index membersCount:(int)membersCount imageView:(UIImageView *)imageView{
    
    //取出缓存的Frame
    if ([[YHGroupIconFrame shareInstanced] hasCacheFrameAtIndex:index membersCount:membersCount]) {
        CGRect frame = [[YHGroupIconFrame shareInstanced] getCacheFrameAtIndexAtIndex:index membersCount:membersCount];
        imageView.frame = frame;
        return imageView.size.width;
    }

    
    CGFloat itemW;
    CGFloat itemLeft;
    CGFloat itemTop;
    if (membersCount == 1) {
        if (index == 0) {
            itemW = (self.containerW - 3*self.margin)/2;
            itemLeft = (self.containerW - itemW)/2;
            itemTop  = (self.containerW - itemW)/2;

        }
    }else if (membersCount == 2){
        itemW    = (self.containerW - 3*self.margin)/2;
        itemLeft = self.margin + (itemW + self.margin)*index;
        itemTop  = (self.containerW - itemW)/2;
        
        
    }else if (membersCount == 3){ // 2 r, 1 2c
        
        itemW = (self.containerW - 3*self.margin)/2;
        
        if (index == 0) {
            itemLeft = (self.containerW-itemW)/2;
            itemTop  = self.margin;
        }else{
            itemLeft = self.margin + (itemW + self.margin)*(index-1);
            itemTop  = 2*self.margin + itemW;
        }
        
    }else if (membersCount == 4){ //2 r, 2 c
        itemW = (self.containerW - 3*self.margin)/2;
        
        if (index == 0 || index == 1) {
                itemLeft = self.margin + (itemW + self.margin)*index;
                itemTop  = self.margin;
        }else{
            itemLeft = self.margin + (itemW + self.margin)*(index-2);
            itemTop  = 2*self.margin + itemW;
        }
        
    }else if (membersCount == 5){  //2 r ,3 c
        itemW = (self.containerW - 4*self.margin)/3;
        CGFloat spaceV = (self.containerW - 2*itemW)/3;
        if (index == 0 || index == 1) {
            CGFloat space = (self.containerW - 2*itemW - self.margin)/2;
            itemLeft = space + (itemW+self.margin)*index;
            itemTop  = spaceV;
        }else{
            itemLeft = self.margin + (itemW + self.margin)*(index-2);
            itemTop = 2*spaceV + itemW ;
        }
       
    }else if (membersCount == 6){
        itemW = (self.containerW - 4*self.margin)/3;
        CGFloat spaceV = (self.containerW - 2*itemW)/3;
        if (index < 3) {
            itemLeft = self.margin + (itemW + self.margin)*index;
            itemTop  = spaceV;
        }else{
            itemLeft = self.margin + (itemW + self.margin)*(index-3);
            itemTop = 2*spaceV + itemW;
        }
       
    }else if (membersCount == 7){
        itemW = (self.containerW - 4*self.margin)/3;
       
        if (index == 0) {
            itemLeft = (self.containerW - itemW)/2;
            itemTop  = self.margin;
        }else if (index < 4){
            itemLeft = self.margin + (itemW + self.margin)*(index-1);
            itemTop = 2*self.margin + itemW;
        }else{
            itemLeft = self.margin + (itemW + self.margin)*(index-4);
            itemTop = 3*self.margin + 2*itemW;
        }
        
    }else if (membersCount == 8){
        itemW = (self.containerW - 4*self.margin)/3;
        
        if (index == 0 || index == 1) {
            CGFloat spaceH = (self.containerW - self.margin - 2*itemW)/2;
            itemLeft = spaceH + (self.margin+itemW)*index;
            itemTop  = self.margin;
        }else if (index < 5){
            itemLeft = self.margin + (itemW + self.margin)*(index-2);
            itemTop = 2*self.margin + itemW;
        }else{
            itemLeft = self.margin + (itemW + self.margin)*(index-5);
            itemTop = 3*self.margin + 2*itemW;
        }
       
    }else if (membersCount == 9){
        itemW = (self.containerW - 4*self.margin)/3;
        if (index < 3) {
            itemLeft = self.margin + (itemW + self.margin)*index;
            itemTop  = self.margin;
        }else if (index < 6){
            itemLeft = self.margin + (itemW + self.margin)*(index-3);
            itemTop  = 2*self.margin + itemW;
        }else{
            itemLeft = self.margin + (itemW + self.margin)*(index-6);
            itemTop  = 3*self.margin + 2*itemW;
        }
        
    }
    
    imageView.left   = itemLeft;
    imageView.top    = itemTop;
    imageView.size   = CGSizeMake(itemW, itemW);

//    DDLog(@"itemLeft:%f",itemLeft);
//    DDLog(@"itemTop:%f",itemTop)
    //缓存Frame
    [[YHGroupIconFrame shareInstanced] cacheFrame:CGRectMake(itemLeft, itemTop, itemW, itemW) atIndex:index membersCount:membersCount];
    
   
    return itemW;
}

@end
