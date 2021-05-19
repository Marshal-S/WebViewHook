//
//  ViewController.m
//  URLProtocolDemo
//
//  Created by Marshal on 2021/5/10.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
#import "LSURLProtocol.h"

@interface ViewController ()<WKURLSchemeHandler>

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) WKWebView *wkWebView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self initWebView];
    
    [self initWKWebView];
}

- (void)initWebView {
    //注册NSURLProtocol监听网络
    [NSURLProtocol registerClass:[LSURLProtocol class]];
    
    //走的URLHTTP可以使用NSURLProtocol拦截
    _webView = [[UIWebView alloc] initWithFrame:self.view.frame];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.baidu.com/"] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15];
    [_webView loadRequest:request];
    
    [self.view addSubview:_webView];
}

- (void)initWKWebView {
    //网络走的webkit内核,无法使用NSURLProtocol
    //不加上webView显示大小有问题
    NSString *jScript = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";
    WKUserScript *wkUScript = [[WKUserScript alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    WKUserContentController *wkUController = [[WKUserContentController alloc] init];
    [wkUController addUserScript:wkUScript];
    
    WKWebViewConfiguration *wkWebConfig = [[WKWebViewConfiguration alloc] init];
    wkWebConfig.userContentController = wkUController;
    
    //可以点进去查看，通过webView的类方法handlesURLScheme来检查url可用性,无效的URLScheme会导致崩溃(例如:http)
    //处理崩溃，由于调用类方法继承不可以，可以通过分类+hook来处理(或者主动方法的hook和交换)，避免自定义拦截标准出现出现崩溃
    //标准的urlscheme是没有问题的,可以点方法进入查看参考标准，例如：www.baidu.com
    //这里可以自行创建专门处理拦截业务的代理类，将self替换之，并实现WKURLSchemeHandler协议即可
    [wkWebConfig setURLSchemeHandler:self forURLScheme:@"www.baidu.com"];
    [wkWebConfig setURLSchemeHandler:self forURLScheme:@"https"];
    [wkWebConfig setURLSchemeHandler:self forURLScheme:@"http"];
    
    _wkWebView = [[WKWebView alloc]initWithFrame:self.view.frame configuration:wkWebConfig];
    //手势触摸滑动
    _wkWebView.allowsBackForwardNavigationGestures = YES;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.baidu.com/"] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15];
    [_wkWebView loadRequest:request];
    
    [self.view addSubview:_wkWebView];
}

//通知开始准备加载相应的网络任务
- (void)webView:(WKWebView *)webView startURLSchemeTask:(id <WKURLSchemeTask>)urlSchemeTask {
    NSURLRequest *request = urlSchemeTask.request;
    //可以通过url拦截响应的方法
    if ([request.URL.absoluteString.pathExtension isEqualToString:@"png"] || [request.URL.absoluteString.pathExtension isEqualToString:@"gif"]) {
        //一个任务完成需要返回didReceiveResponse和didReceiveData两个方法，最后在执行didFinish，不可重复调用，可能会导致崩溃
        [urlSchemeTask didReceiveResponse:[NSURLResponse new]];
        [urlSchemeTask didReceiveData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"test1" ofType:@"jpeg"]]];
        [urlSchemeTask didFinish];
        return;
    }
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        //也可以通过解析data等数据，通过data等数据来确定是否拦截
        //一个任务完成需要返回didReceiveResponse和didReceiveData两个方法，最后在执行didFinish，不可重复调用，可能会导致崩溃
        if (!data) {
            [urlSchemeTask didReceiveResponse:[NSURLResponse new]];
            [urlSchemeTask didReceiveData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"test1" ofType:@"jpeg"]]];
        } else {
            [urlSchemeTask didReceiveResponse:response];
            [urlSchemeTask didReceiveData:data];

        }
        [urlSchemeTask didFinish];
    }];
    [task resume];
}

//通知停止加载该url，这里不做处理，否则可能会引起异常，暂时未发现走这里
- (void)webView:(WKWebView *)webView stopURLSchemeTask:(id <WKURLSchemeTask>)urlSchemeTask {
    NSLog(@"%@", urlSchemeTask.request.URL.absoluteString);
}

- (void)dealloc {
    //取消url拦截监听
    [NSURLProtocol unregisterClass:[LSURLProtocol class]];
}


@end
