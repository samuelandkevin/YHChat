//
//  YHGroupIconView.m
//  samuelandkevin github:https://github.com/samuelandkevin/YHChat
//
//  Created by kun on 2017/1/18.
//  Copyright © 2017年 YHSoft. All rights reserved.
//

#import "YHGroupIconView.h"
#import "UIImageView+WebCache.h"


#define kMaxMembersInIcon 9
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
    
    CGFloat itemW = [self itemWidthForPicArray:_picUrlArray];
    CGFloat itemH = itemW;
    
    long perRowItemCount = [self perRowItemCountForPicArray:_picUrlArray];
    
    //群图标最多显示9个成员
    NSUInteger membersInGroupIcon = _picUrlArray.count;
    if(_picUrlArray.count > kMaxMembersInIcon){
        membersInGroupIcon = kMaxMembersInIcon;
    }else{
        membersInGroupIcon = _picUrlArray.count;
    }
    
    
    for (int i = 0; i< membersInGroupIcon; i++) {
        NSURL *obj     =  _picUrlArray[i];
        long columnIndex = i % perRowItemCount;
        long rowIndex    = i / perRowItemCount;
        
        UIImageView *imageView = self.imageViewsArray[i];
        imageView.layer.cornerRadius  = itemW/2;
        imageView.layer.masksToBounds = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.clipsToBounds = YES;
        imageView.hidden = NO;
        [imageView sd_setImageWithURL:obj placeholderImage:[UIImage imageNamed:@"common_avatar_120px"]  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {}
         ];
        
        imageView.frame = CGRectMake(columnIndex * (itemW + self.margin), rowIndex * (itemH + self.margin), itemW, itemH);
        
    }

}


- (CGFloat)itemWidthForPicArray:(NSArray *)array
{
    NSUInteger count = array.count;
    if (count == 1) {
        return self.containerW - self.margin*2;
    }else if(count == 2 || count == 3){
        return (self.containerW - self.margin*3)/2;
    }else if (count == 4){
        return (self.containerW - self.margin*3)/2;
    }else{
        return (self.containerW - self.margin*4)/3;
    }
}

- (NSInteger)perRowItemCountForPicArray:(NSArray *)array
{
    if (array.count < 3) {
        return array.count;
    } else if (array.count < 5) {
        return 2;
    } else {
        return 3;
    }
}

@end
