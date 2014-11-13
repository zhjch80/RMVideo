//
//  RMWebViewPlayViewController.m
//  RMVideo
//
//  Created by 润华联动 on 14-11-13.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMWebViewPlayViewController.h"
#import "UIButton+EnlargeEdge.h"

@interface RMWebViewPlayViewController ()<UIWebViewDelegate>

@end

@implementation RMWebViewPlayViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self startPlayWebViewMovieWithURL:self.urlString];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;

//    [self.PlayWebView setUserInteractionEnabled:YES];
//    self.PlayWebView.scrollView.bounces = YES;
//    self.PlayWebView.opaque = NO;
//    self.PlayWebView.delegate = self;
//    self.PlayWebView.backgroundColor = [UIColor clearColor];
    
    [self.navButton setEnlargeEdgeWithTop:10 right:10 bottom:10 left:10];
}

#pragma mark -

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}

- (void) startPlayWebViewMovieWithURL:(NSString *)urlString{
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:30.0];
    [self.PlayWebView loadRequest:request];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [SVProgressHUD showWithStatus:@"正在加载中..." maskType:SVProgressHUDMaskTypeBlack];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.titleLable.text = [self.PlayWebView stringByEvaluatingJavaScriptFromString:@"document.title"];
    [SVProgressHUD showSuccessWithStatus:@"加载完成"];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [SVProgressHUD showErrorWithStatus:@"加载失败"];
}



#pragma mark - base Method

- (IBAction)customNavReturn:(UIButton *)sender {
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
