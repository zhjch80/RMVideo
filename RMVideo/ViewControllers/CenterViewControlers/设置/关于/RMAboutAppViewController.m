//
//  RMAboutAppViewController.m
//  RMVideo
//
//  Created by 润华联动 on 14-10-22.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMAboutAppViewController.h"

@interface RMAboutAppViewController ()<UIWebViewDelegate>
@property (nonatomic, strong) UIWebView * webView;
@end

@implementation RMAboutAppViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"关于";
    rightBarButton.hidden = YES;
    [leftBarButton setImage:[UIImage imageNamed:@"backup_img"] forState:UIControlStateNormal];

    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleAllHeight - 64)];
    [self.webView setUserInteractionEnabled:YES];
    self.webView.scrollView.bounces = YES;
    self.webView.opaque = NO;
    self.webView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.webView];
    
    NSURL *url= [NSURL URLWithString:@"http://m.kankan.com/v/73/73509.shtml"];
    NSURLRequest *request=[[NSURLRequest alloc] initWithURL:url];
    [self.webView loadRequest:request];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return NO;
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
