//
//  RMAboutAppViewController.m
//  RMVideo
//
//  Created by 润华联动 on 14-10-22.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMAboutAppViewController.h"

@interface RMAboutAppViewController ()<UIWebViewDelegate,RMAFNRequestManagerDelegate>
@property (nonatomic, strong) UIWebView * webView;
@end

@implementation RMAboutAppViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [Flurry logEvent:@"VIEW_Setup_About" timed:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [Flurry endTimedEvent:@"VIEW_Setup_About" withParameters:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"关于";
    rightBarButton.hidden = YES;
    [leftBarButton setImage:[UIImage imageNamed:@"backup_img"] forState:UIControlStateNormal];

    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleAllHeight - 64)];
    [self.webView setUserInteractionEnabled:YES];
    self.webView.scrollView.bounces = NO;
    self.webView.opaque = NO;
    self.webView.delegate = self;
    self.webView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.webView];
    
    RMAFNRequestManager * request = [[RMAFNRequestManager alloc] init];
    [request getAboutAppWithOS:@"iPhone" withVersionNumber:AppVersionNumber];
    request.delegate = self;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
   [SVProgressHUD showWithStatus:@"正在加载中..." maskType:SVProgressHUDMaskTypeBlack];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [SVProgressHUD showSuccessWithStatus:@"加载完成"];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [SVProgressHUD showErrorWithStatus:@"加载失败"];
}

#pragma mark - Base Method

- (void) navgationBarButtonClick:(UIBarButtonItem *)sender {
    switch (sender.tag) {
        case 1:{
            [self.navigationController popViewControllerAnimated:YES];
            break;
        }
        case 2:{
            
            break;
        }

        default:
            break;
    }
}

#pragma mark - request 

- (void)requestFinishiDownLoadWith:(NSMutableArray *)data {
    RMPublicModel * model = [data objectAtIndex:0];
    if (model.AppVersionUrl.length == 0){
        
    }else{
        NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:model.AppVersionUrl] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
        [self.webView loadRequest:request];
    }
}

- (void)requestError:(NSError *)error {
    NSLog(@"error:%@",error);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
