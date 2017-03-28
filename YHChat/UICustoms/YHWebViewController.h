//
//  YHWebViewController.h
//  samuelandkevin
//
//  Created by samuelandkevin on 16/6/24.
//  Copyright © 2016年 samuelandkevin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>


@interface YHWebViewController : UIViewController

@property (nonatomic,strong) UIWebView *webView;
@property (nonatomic,strong) JSContext *jsContext;
@property (nonatomic,assign) BOOL enableIQKeyBoard;
@property (nonatomic,assign) BOOL presentedVC;
@property (nonatomic,assign) BOOL navigationBarHidden;
@property (nonatomic,strong) NSURL *url;
@property (nonatomic,strong) NSURLRequest *loadRequst; //webView加载的请求
@property (nonatomic,assign) UIWebViewNavigationType navigationType;//导航类型

- (instancetype)initWithFrame:(CGRect)frame url:(NSURL *)url;


//Mark:提供父类的方法,子类可以根据需求重定义
- (void)setUpNavigationBar;
- (void)setUpWebView; //子类可以在此方法重设webview的frame和url
- (void)setUpUserAgent;
- (void)webViewDidFinishLoad:(UIWebView *)webView;
- (void)onBack:(id)sender;
- (void)scrollViewDidScroll;
- (void)loadCache;

#pragma mark - KeyboardNotification
- (void)registerForKeyboardNotifications;
- (void)unregisterKeyboardNotifications;
- (void)adjustScrollView:(CGRect)kbRect;
- (void)keyboardWillShow:(NSNotification *)aNotification;
//- (void)keyboardWillBeHidden:(NSNotification*)aNotification;
@end
