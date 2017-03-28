//
//  YHWebViewController.m
//  samuelandkevin
//
//  Created by samuelandkevin on 16/6/24.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//

#import "YHWebViewController.h"
#import "HHUtils.h"
#import <objc/runtime.h>
#import "UIBarButtonItem+Extension.h"

@interface YHWebViewController ()<UIWebViewDelegate,UIScrollViewDelegate>

#define HTML_TokenInvalid @"{\"status\":\"error\",\"code\":\"401\""
#define HTML_BodyInnerText @"document.body.innerText"
#define HTML_IsEmpty @"<head></head><body></body>"
#define HTML_Inner @"document.documentElement.innerHTML"

@property (nonatomic,assign) CGRect rect;

//控件
@property (nonatomic,strong) UIButton   *btnScrollToTop;

//标志变量
@property (nonatomic,assign)  BOOL hasRegisterKeyboardNotification;
@property (nonatomic,assign)  BOOL        keyboardIsShown;

@end

@implementation YHWebViewController


- (instancetype)initWithFrame:(CGRect)frame url:(NSURL *)url{
    if (self  = [super init]) {
        _url  = url;
        _rect = frame;
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (instancetype)initWithURL:(NSURL *)url{
    if(self = [super init]){
        _url = url;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initUI];
    [self loadCache];
}


- (void)initUI{
    

    [self setUpNavigationBar];
    self.navigationController.navigationBar.translucent = NO;
    
    //1.webview
    _webView = [[UIWebView alloc] init];
    _webView.delegate = self;
    _webView.opaque   = NO;
    _webView.scrollView.bounces = NO;
    _webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
    [_webView setScalesPageToFit:YES];
    _webView.scrollView.delegate = self;

    
    
    _webView.scrollView.delegate = self;
    [self.view addSubview:_webView];
    [self setUpWebView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.webView.backgroundColor = [UIColor colorWithWhite:0.957 alpha:1.000];
    
}

#pragma mark - Lazy Load
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return nil;
}

#pragma mark - Action
- (void)onBack:(id)sender{
    if ([_webView canGoBack]) {
        [_webView goBack];
    }
    else{
        if(_presentedVC){
            [self dismissViewControllerAnimated:YES completion:NULL];
        }else
            [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Life
- (void)viewWillAppear:(BOOL)animated{
   
    [super viewWillAppear:animated];
    
    if (!_enableIQKeyBoard) {
       
    }
    self.navigationController.navigationBarHidden = self.navigationBarHidden;
    if (self.navigationBarHidden) {
        //状态栏背景添加
        if (![self.view viewWithTag:1111]) {
            UIView *statusBarBG = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20)];
            statusBarBG.tag = 1111;
            statusBarBG.backgroundColor = kBlueColor;
            [self.view addSubview:statusBarBG];
        }
    }
    
}


- (void)viewWillDisappear:(BOOL)animated{

    [super viewWillDisappear:animated];

}

- (void)dealloc{
    self.webView.delegate = nil;
    self.webView.scrollView.delegate = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Public

- (void)setUpNavigationBar{
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem backItemWithTarget:self selector:@selector(onBack:)];
}

- (void)setUpUserAgent{
    UIWebView *tempWebV = [[UIWebView alloc] init];
    NSString *sAgent = [tempWebV stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    NSString *userAgent = [NSString stringWithFormat:@"%@; ShuiDao /%@",sAgent,[HHUtils appStoreNumber]];
    [tempWebV stringByEvaluatingJavaScriptFromString:userAgent];
    NSDictionary*dictionnary = [[NSDictionary alloc] initWithObjectsAndKeys:userAgent, @"UserAgent", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionnary];
}

- (void)setUpWebView{
    _webView.frame = _rect;
    
    NSMutableURLRequest *mreq = [NSMutableURLRequest requestWithURL:_url];
    [_webView loadRequest:mreq];
}

- (void)loadCache{
   
}


#pragma mark - KeyboardNotification
- (void)registerForKeyboardNotifications {
    if (_hasRegisterKeyboardNotification) {//注册的键盘通知，直接退出
        return;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    _hasRegisterKeyboardNotification = YES;
}

- (void)unregisterKeyboardNotifications {
    if (!_hasRegisterKeyboardNotification) {
        return;
    }
    _hasRegisterKeyboardNotification = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)aNotification{
    
    NSDictionary* info = [aNotification userInfo];
    CGRect keyboardRect = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [self adjustScrollView:keyboardRect];
    
}


- (void)adjustScrollView:(CGRect)kbRect {

    WeakSelf
    [UIView animateWithDuration:0.2 animations:^{
        weakSelf.webView.scrollView.contentOffset = CGPointMake(0, kbRect.size.height);
    }];

}




#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    self.loadRequst = request;
    self.navigationType = navigationType;
    return YES;
}

//网页开始加载的时候调用
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    DDLog(@"webViewDidStartLoad");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{

    self.jsContext = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    //检查登录信息
    NSString *strBody = [webView stringByEvaluatingJavaScriptFromString:HTML_BodyInnerText];
    if ([strBody hasPrefix:HTML_TokenInvalid]) {
         DDLog(@"token失效,请重新登录");
    }
   

    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
  
    
    if (self.navigationBarHidden) {
        //状态栏背景移除
        UIView *statusBarBG = [self.view viewWithTag:1111];
        [statusBarBG removeFromSuperview];
    }
    
    
    if (error.code == 102){
        //链接无效,不做任何跳转
        
    }else{
        NSString *strInHTML = [webView stringByEvaluatingJavaScriptFromString:HTML_Inner];
        if ([strInHTML isEqualToString:HTML_IsEmpty]) {
            //网页没有内容
            if ([error.userInfo[@"cache"] boolValue] == NO) {
                DDLog(@"no HTML cache");
                //没缓存,显示失败View,点击可重新加载
               
            }
        }

        
    }
   
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
   [self scrollViewDidScroll];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
}

- (void)scrollViewDidScroll{

}





/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
