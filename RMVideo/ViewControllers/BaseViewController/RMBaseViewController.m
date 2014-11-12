//
//  RMBaseViewController.m
//  RMVideo
//
//  Created by runmobile on 14-9-29.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMBaseViewController.h"

@implementation RMBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:0.94 green:0.93 blue:0.93 alpha:1];
    
    self.navigationController.navigationBar.translucent = NO;
    
    if([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]){
//        self.edgesForExtendedLayout=UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars=NO;
        self.automaticallyAdjustsScrollViewInsets = NO;
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
        [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor, nil]];
    }
    
    leftBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBarButton.frame = CGRectMake(0, 0, 22, 22);
    [leftBarButton addTarget:self action:@selector(navgationBarButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    leftBarButton.tag = 1;
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:leftBarButton];
    self.navigationItem.leftBarButtonItem = leftBarItem;
    
    rightBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBarButton.frame = CGRectMake(0, 0, 22, 22);
    rightBarButton.tag = 2;
    [rightBarButton addTarget:self action:@selector(navgationBarButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithCustomView:rightBarButton];
    self.navigationItem.rightBarButtonItem = rightBarItem;
}

- (void)showEmptyViewWithImage:(UIImage *)image WithTitle:(NSString *)title {
    self.noDataShowImage = [[UIImageView alloc] init];
    self.noDataShowImage.image = image;//[UIImage imageNamed:@"no_cashe_video"];
    self.noDataShowImage.frame = CGRectMake(([UtilityFunc shareInstance].globleWidth-154)/2, ([UtilityFunc shareInstance].globleHeight-154)/2 - 77 , 154, 154);
    [self.view addSubview:self.noDataShowImage];
    
    self.noDataShowLable = [[UILabel alloc] init];
    self.noDataShowLable.frame = CGRectMake(([UtilityFunc shareInstance].globleWidth-200)/2, self.noDataShowImage.frame.origin.y+self.noDataShowImage.frame.size.height+10, 200, 21);

    self.noDataShowLable.textColor = [UIColor colorWithRed:0.76 green:0.76 blue:0.76 alpha:1];
    self.noDataShowLable.text = title;//@"您没有播放记录";
    self.noDataShowLable.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.noDataShowLable];
}

- (void)isShouldSetHiddenEmptyView:(BOOL)isShould{
    self.noDataShowLable.hidden = isShould;
    self.noDataShowImage.hidden = isShould;
}

- (void)navgationBarButtonClick:(UIBarButtonItem *)sender{
    
}

- (void)setTitle:(NSString *)title {
    [super setTitle:title];
    UILabel *titleView = (UILabel *)self.navigationItem.titleView;
    titleView.textAlignment = NSTextAlignmentCenter;
    if(!titleView){
        titleView = [[UILabel alloc] initWithFrame:CGRectZero];
        titleView.backgroundColor = [UIColor clearColor];
        titleView.font = [UIFont boldSystemFontOfSize:20.0];
        titleView.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.2];
        titleView.textColor = [UIColor whiteColor];
        self.navigationItem.titleView = titleView;
    }
    titleView.text = title;
    [titleView sizeToFit];
}


- (void)setExtraCellLineHidden: (UITableView *)tableView{
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
    [tableView setTableHeaderView:view];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return UIDeviceOrientationIsLandscape(toInterfaceOrientation);
}

- (BOOL)shouldAutorotate {
    return NO;
}

//- (NSUInteger)supportedInterfaceOrientations{
////    return UIInterfaceOrientationMaskPortrait;
////    return UIInterfaceOrientationIsPortrait(UIInterfaceOrientationPortrait);
//    return UIInterfaceOrientationPortrait;//只支持这一个方向(正常的方向)
//}

//#define UIInterfaceOrientationIsPortrait(orientation)  ((orientation) == UIInterfaceOrientationPortrait || (orientation) == UIInterfaceOrientationPortraitUpsideDown)


@end
