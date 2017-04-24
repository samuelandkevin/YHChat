//
//  YHShootBtn.m
//  YHChat
//
//  Created by YHIOS002 on 2017/4/18.
//  Copyright © 2017年 samuelandkevin. All rights reserved.
//

#import "YHShootBtn.h"
#import "YHVideoManager.h"
#import "YHAVPlayer.h"

@interface YHShootBtn(){
    CGSize  _sizeBtnShoot; //拍照按钮的size
    CGSize  _sizeContainer;//容器的size
    CGFloat _normalInnerRadius;
    CGFloat _scaleInnerRadius;
    CGFloat _normalOutsideRadius;
    CGFloat _scaleOutsideRadius;
    CGFloat _progressRadius;
    CGFloat _lineWidthProgress;
    NSTimeInterval _maxTimeLength;
    float  _costTime;//耗时
    NSDate *_startDate;
    NSDate *_endDate;
    
}

@property (nonatomic,strong) UIButton *btnShoot; //拍照
@property (nonatomic,strong) UIButton *btnCancel;//取消
@property (nonatomic,strong) UIButton *btnChoose;//选择
@property (nonatomic,strong) CAShapeLayer *innerLayer;   //内层
@property (nonatomic,strong) CAShapeLayer *outsideLayer; //外层
@property (nonatomic,strong) CAShapeLayer *progressLayer;//进度

@property (nonatomic,strong) UIBezierPath *normalInnerPath;//默认状态下内圆path
@property (nonatomic,strong) UIBezierPath *scaleInnerPath;//缩放状态下内圆path
@property (nonatomic,strong) UIBezierPath *normalOutsidePath;//默认状态下外圆path
@property (nonatomic,strong) UIBezierPath *scaleOutsidePath;//缩放状态下外圆path
@property (nonatomic,strong) UIBezierPath *progressPath;//进度条Path
@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic,copy)   NSString *videoName;
@property (nonatomic,strong) YHAVPlayer *player;
@property (nonatomic,copy)   void(^chooseBlock)(NSString *);
@property (nonatomic,copy)   void(^stopBlock)(NSString *);
@end

@implementation YHShootBtn

#pragma mark - init

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        //一些常量的设置
        {
            //容器
            _sizeContainer = CGSizeMake(SCREEN_WIDTH, 150);
            self.frame     = CGRectMake(0, SCREEN_HEIGHT-_sizeContainer.height, _sizeContainer.width, _sizeContainer.height);
            
            //拍照按钮
            _sizeBtnShoot = CGSizeMake(50, 50);
            
            _lineWidthProgress   = 4;
            _normalInnerRadius   = _sizeBtnShoot.width/2;
            _scaleInnerRadius    = _sizeBtnShoot.width/4;;
            _normalOutsideRadius = _normalInnerRadius + 10;;
            _scaleOutsideRadius  = _sizeBtnShoot.width/2+10+_sizeBtnShoot.width/4;;
            _progressRadius      = _scaleOutsideRadius - _lineWidthProgress+1;
            
            _costTime            = 0;
            _maxTimeLength       = 10;
        }
        
        [self setup];
    }
    return self;
}

- (void)setup{
    //拍照
    _btnShoot = [[UIButton alloc] init];
    _btnShoot.frame  = CGRectMake(0,0,_sizeBtnShoot.width,_sizeBtnShoot.height);
    _btnShoot.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    [_btnShoot addTarget:self action:@selector(onBtnShoot:) forControlEvents:UIControlEventTouchUpInside];
    UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(gestureOnBtnShoot:)];
    [_btnShoot addGestureRecognizer:gesture];
    [self addSubview:_btnShoot];
    
    //取消
    _btnCancel = [[UIButton alloc] init];
    _btnCancel.hidden = YES;
    [_btnCancel setTitle:@"取消" forState:UIControlStateNormal];
    [_btnCancel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _btnCancel.backgroundColor = [UIColor yellowColor];
    _btnCancel.frame  = CGRectMake(0, 0, _sizeBtnShoot.width, _sizeBtnShoot.height);
    [_btnCancel addTarget:self action:@selector(onCancel:) forControlEvents:UIControlEventTouchUpInside];
    _btnCancel.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    [self addSubview:_btnCancel];
    
    //选择
    _btnChoose = [[UIButton alloc] init];
    _btnChoose.hidden = YES;
    _btnChoose.backgroundColor = [UIColor greenColor];
    _btnChoose.frame  = CGRectMake(0, 0, _sizeBtnShoot.width, _sizeBtnShoot.height);
    [_btnChoose setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
     [_btnChoose setTitle:@"选择" forState:UIControlStateNormal];
    _btnChoose.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    [_btnChoose addTarget:self action:@selector(onChoose:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_btnChoose];
    
    //外层圆
    [self outsideLayer];
    //内层圆
    [self innerLayer];
    //进度层
    [self progressLayer];
   
}

#pragma mark - Getter
- (CAShapeLayer *)innerLayer{
    if (!_innerLayer) {
        _innerLayer = [CAShapeLayer layer];
        _innerLayer.fillColor   = [UIColor whiteColor].CGColor;
        _innerLayer.path        = [self normalInnerPath].CGPath;
        [self.layer addSublayer:_innerLayer];
    }
    return _innerLayer;
}

- (CAShapeLayer *)outsideLayer{
    if (!_outsideLayer) {
        _outsideLayer = [CAShapeLayer layer];
        _outsideLayer.fillColor   = [UIColor colorWithRed:170.0/255 green:170.0/255 blue:170.0/255 alpha:1.0].CGColor;
        _outsideLayer.path        = [self normalOutsidePath].CGPath;
        [self.layer addSublayer:_outsideLayer];
    }
    return _outsideLayer;
}

- (CAShapeLayer *)progressLayer{
    if (!_progressLayer) {
        _progressLayer = [CAShapeLayer layer];
        _progressLayer.lineWidth = _lineWidthProgress;
        _progressLayer.strokeColor = kBlueColor.CGColor;
        _progressLayer.fillColor   = [UIColor clearColor].CGColor;
        _progressLayer.strokeStart = 0;
        _progressLayer.strokeEnd   = 0;
        _progressLayer.path        = [self progressPath].CGPath;
        [self.layer addSublayer:_progressLayer];
    }
    return _progressLayer;
}

- (UIBezierPath *)normalInnerPath{
    if(!_normalInnerPath){
        
        UIBezierPath *bezierPath = [UIBezierPath bezierPath];
        [bezierPath addArcWithCenter:CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2) radius:_normalInnerRadius startAngle:0 endAngle:2*M_PI clockwise:YES];
        _normalInnerPath = bezierPath;
    }
    return _normalInnerPath;
}

- (UIBezierPath *)scaleInnerPath{
    if (!_scaleInnerPath) {
        UIBezierPath *bezierPath = [UIBezierPath bezierPath];
        [bezierPath addArcWithCenter:CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2) radius:_scaleInnerRadius startAngle:0 endAngle:2*M_PI clockwise:YES];
        _scaleInnerPath = bezierPath;
    }
    return _scaleInnerPath;
    
}

- (UIBezierPath *)normalOutsidePath{
    if (!_normalOutsidePath) {
        
        UIBezierPath *bezierPath = [UIBezierPath bezierPath];
        [bezierPath addArcWithCenter:CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2) radius:_normalOutsideRadius startAngle:0 endAngle:2*M_PI clockwise:YES];
        _normalOutsidePath = bezierPath;
    }
    return _normalOutsidePath;
}

- (UIBezierPath *)scaleOutsidePath{
    if (!_scaleOutsidePath) {
        
        UIBezierPath *bezierPath = [UIBezierPath bezierPath];
        [bezierPath addArcWithCenter:CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2) radius:_scaleOutsideRadius startAngle:0 endAngle:2*M_PI clockwise:YES];
        _scaleOutsidePath = bezierPath;
    }
    return _scaleOutsidePath;
}

- (UIBezierPath *)progressPath{
    if (!_progressPath) {
        
        UIBezierPath *bezierPath = [UIBezierPath bezierPath];
        [bezierPath addArcWithCenter:CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2) radius:_progressRadius startAngle:-M_PI/2 endAngle:M_PI/2*3 clockwise:YES];
        _progressPath = bezierPath;
    }
    return _progressPath;
}

#pragma mark - Public
//选择视频
- (void)chooseVideoHandler:(void(^)(NSString *path))complete{
    _chooseBlock = complete;
}

//停止拍摄
- (void)stopShootingHandler:(void(^)(NSString *path))complete{
    _stopBlock = complete;
}

//取消拍摄
- (void)cancelShooting{
    [self _cancelShooting];
}

#pragma mark - Life
- (void)dealloc{
    [_timer invalidate];
    _timer = nil;
    DDLog(@"%s is dealloc",__func__);
}

#pragma mark - Action
- (void)onBtnShoot:(id)sender{
    DDLog(@"单击拍照");
}

- (void)gestureOnBtnShoot:(UILongPressGestureRecognizer *)aGesture{
    DDLog(@"长按录像");
    
    
    if (aGesture.state == UIGestureRecognizerStateBegan) {
        [self setScaleAnimation];
        [self startShooting];
    }
    else if (aGesture.state == UIGestureRecognizerStateEnded){
        [self setNormalAnimation];
        [self stopShooting];
    }

}

//开始拍摄
- (void)startShooting{
     _startDate = [NSDate date];
    DDLog(@"%@",_startDate);
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"YYYYMMddHHMMss";
    _videoName = [formatter stringFromDate:_startDate];
    [[YHVideoManager shareInstanced] startRecordingVideoWithFileName:_videoName];
    
}

//取消拍摄
- (void)_cancelShooting{
    [[YHVideoManager shareInstanced] cancelRecordingVideoWithFileName:_videoName];
    [self.player removeFromSuperview];
    self.player = nil;
}

//停止拍摄
- (void)stopShooting{
    WeakSelf
    [[YHVideoManager shareInstanced] stopRecordingVideo:^(NSString *path) {
        if (weakSelf.stopBlock) {
            weakSelf.stopBlock(path);
        }
        
        weakSelf.player = [[YHAVPlayer alloc] initWithPlayerURL:[NSURL fileURLWithPath:path]];
        weakSelf.player.playerLayer.frame = weakSelf.superView.frame;
        [weakSelf.superView insertSubview:weakSelf.player atIndex:1];

    }];
   
}

//设置还原动画
- (void)setNormalAnimation{
    //内圆半径复原
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];
    animation.duration = 0.25;
    animation.fromValue = (__bridge id _Nullable)[self scaleInnerPath].CGPath;
    animation.toValue   = (__bridge id _Nullable)[self normalInnerPath].CGPath;
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    [_innerLayer addAnimation:animation forKey:@"innerScale"];
    
    //外圆半径复原
    CABasicAnimation *animation2 = [CABasicAnimation animationWithKeyPath:@"path"];
    animation2.duration  = 0.25;
    animation2.fromValue = (__bridge id _Nullable)([self scaleOutsidePath].CGPath);
    animation2.toValue   = (__bridge id _Nullable)([self  normalOutsidePath].CGPath);
    animation2.fillMode  = kCAFillModeForwards;
    animation2.removedOnCompletion = NO;
    [_outsideLayer addAnimation:animation2 forKey:@"outsideScale"];
    
    
    //进度条复原
    [_timer invalidate];
    _timer = nil;
    _costTime = 0;
    [_progressLayer removeFromSuperlayer];
    _progressLayer = nil;
    
    //取消和选择按钮弹出,拍摄按钮隐藏
    self.btnCancel.hidden = NO;
    self.btnChoose.hidden = NO;
    WeakSelf
    [UIView animateWithDuration:0.25 animations:^{
        weakSelf.btnCancel.center = CGPointMake(_sizeBtnShoot.width+10, weakSelf.bounds.size.height/2);
        weakSelf.btnChoose.center = CGPointMake(weakSelf.frame.size.width-(_sizeBtnShoot.width+10), weakSelf.bounds.size.height/2);
       
    } completion:^(BOOL finished) {
        weakSelf.innerLayer.hidden   = YES;
        weakSelf.outsideLayer.hidden = YES;
        weakSelf.btnShoot.hidden     = YES;
    }];
    
}

//设置缩放动画
- (void)setScaleAnimation{
    //内圆半径变小
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];
    animation.duration  = 0.25;
    animation.fromValue = (__bridge id _Nullable)([self normalInnerPath].CGPath);
    animation.toValue   = (__bridge id _Nullable)([self scaleInnerPath].CGPath);
    animation.fillMode  = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    [_innerLayer addAnimation:animation forKey:@"innerScale"];
    
    //外圆半径变大
    CABasicAnimation *animation2 = [CABasicAnimation animationWithKeyPath:@"path"];
    animation2.duration  = 0.25;
    animation2.fromValue = (__bridge id _Nullable)([self normalOutsidePath].CGPath);
    animation2.toValue   = (__bridge id _Nullable)([self scaleOutsidePath].CGPath);
    animation2.fillMode  = kCAFillModeForwards;
    animation2.removedOnCompletion = NO;
    [_outsideLayer addAnimation:animation2 forKey:@"outsideScale"];
    
    //更新进度条
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(countDown) userInfo:nil repeats:YES];
    

}

//取消
- (void)onCancel:(UIButton *)sender{
    //取消和选择按钮隐藏，显示拍照按钮
    WeakSelf
    [UIView animateWithDuration:0.25 animations:^{
        weakSelf.btnCancel.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        weakSelf.btnChoose.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    }completion:^(BOOL finished) {
        weakSelf.btnCancel.hidden = YES;
        weakSelf.btnChoose.hidden = YES;
        
        weakSelf.innerLayer.hidden   = NO;
        weakSelf.outsideLayer.hidden = NO;
        weakSelf.btnShoot.hidden     = NO;
        
    }];
    
    [self _cancelShooting];
}

//选择
- (void)onChoose:(UIButton *)sender{
    
}

#pragma mark - NSTimer
- (void)countDown{
    if(_costTime >= _maxTimeLength){
        //倒计时结束
        [_timer invalidate];
         _timer = nil;
    }
    
    _costTime += 0.2;
    float end  = _costTime/_maxTimeLength;
    if (end >=1) {
        end = 1;
    }
    self.progressLayer.strokeEnd = end;
    DDLog(@"ratio= %f",end)
}



@end
