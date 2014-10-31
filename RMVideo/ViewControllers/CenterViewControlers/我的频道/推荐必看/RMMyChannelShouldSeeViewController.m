//
//  RMMyChannelShouldSeeViewController.m
//  RMVideo
//
//  Created by runmobile on 14-10-20.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMMyChannelShouldSeeViewController.h"
#import "RMAFNRequestManager.h"
#import "SUNSlideSwitchView.h"
#import "RMShouldSeeMovieViewController.h"
#import "RMShouldSeeTVViewController.h"
#import "RMShouldSeeVarietViewController.h"

@interface RMMyChannelShouldSeeViewController ()<SUNSlideSwitchViewDelegate>
@property (nonatomic, strong) NSString *tag_id;
@property RMShouldSeeTVViewController * starTeleplayListCtl;
@property RMShouldSeeMovieViewController * starFilmListCtl;
@property RMShouldSeeVarietViewController * starVarietyListCtl;
@property (nonatomic, copy) SUNSlideSwitchView *slideSwitchView;
@end

@implementation RMMyChannelShouldSeeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setTitle:@"tag必看"];
    
    [leftBarButton setBackgroundImage:LOADIMAGE(@"backup_img", kImageTypePNG) forState:UIControlStateNormal];
    rightBarButton.hidden = YES;
    
    _slideSwitchView = [[SUNSlideSwitchView alloc] initWithFrame:CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleHeight)];
    _slideSwitchView.slideSwitchViewDelegate = self;
    [self.view addSubview:_slideSwitchView];
    
    _slideSwitchView.BGImgArr = [NSMutableArray arrayWithObjects:@"movie_unSelected",@"teleplay_unSelected",@"variety_unSelected",nil];
    _slideSwitchView.SelectBtnImageArray = [NSMutableArray arrayWithObjects:@"movie_selected",@"teleplay_selected",@"variety_selected", nil];
    
    _starFilmListCtl = [[RMShouldSeeMovieViewController alloc] init];
    _starFilmListCtl.myChannelShouldDelegate = self;
    _starTeleplayListCtl = [[RMShouldSeeTVViewController alloc] init];
    _starTeleplayListCtl.myChannelShouldDelegate = self;
    _starVarietyListCtl = [[RMShouldSeeVarietViewController alloc] init];
    _starVarietyListCtl.myChannelShouldDelegate = self;
    
    if (IS_IPHONE_4_SCREEN | IS_IPHONE_5_SCREEN){
        _slideSwitchView.btnHeight = 30;
        _slideSwitchView.btnWidth = 93;
    }else if (IS_IPHONE_6_SCREEN){
        //TODO:todo...
        _slideSwitchView.btnHeight = 40;
        _slideSwitchView.btnWidth = 105;
    }else if (IS_IPHONE_6p_SCREEN){
        _slideSwitchView.btnHeight = 40;
        _slideSwitchView.btnWidth = 120;
    }
    [_slideSwitchView buildUI];
    
}

- (void)setTagId:(NSString *)tag_id {
    self.tag_id = tag_id;
}

#pragma mark - 滑动tab视图代理方法
- (NSUInteger)numberOfTab:(SUNSlideSwitchView *)view {
    return 3;
}

- (UIViewController *)slideSwitchView:(SUNSlideSwitchView *)view viewOfTab:(NSUInteger)number {
    if (number == 0) {
        return _starFilmListCtl;
    } else if (number == 1) {
        return _starTeleplayListCtl;
    } else if (number == 2) {
        return _starVarietyListCtl;
    } else {
        return nil;
    }
}

- (void)slideSwitchView:(SUNSlideSwitchView *)view panLeftEdge:(UIPanGestureRecognizer *)panParam {
    NSLog(@"left");
}

- (void)slideSwitchView:(SUNSlideSwitchView *)view didselectTab:(NSUInteger)number {
    if (number == 0) {
        NSLog(@"slie to 第一个");
    } else if (number == 1) {
        NSLog(@"slie to 第二个");
    } else if (number == 2) {
        NSLog(@"slie to 第三个");
    }
}

#pragma mark - base Method

- (void)navgationBarButtonClick:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:kAppearTabbar object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
 
}


@end
