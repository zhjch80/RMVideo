//
//  RMMyChannelShouldSeeViewController.m
//  RMVideo
//
//  Created by runmobile on 14-10-20.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMMyChannelShouldSeeViewController.h"
#import "SUNSlideSwitchView.h"
#import "RMShouldSeeMovieViewController.h"
#import "RMShouldSeeTVViewController.h"
#import "RMShouldSeeVarietViewController.h"

@interface RMMyChannelShouldSeeViewController ()<SUNSlideSwitchViewDelegate>
@property (nonatomic, strong) NSString * navTitle;
@property (nonatomic, strong) NSString *tag_id;
@property (nonatomic, strong) NSMutableArray *titelArray;
@property RMShouldSeeTVViewController * starTeleplayListCtl;
@property RMShouldSeeMovieViewController * starFilmListCtl;
@property RMShouldSeeVarietViewController * starVarietyListCtl;
@property (nonatomic, copy) SUNSlideSwitchView *slideSwitchView;
@end

@implementation RMMyChannelShouldSeeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setTitle:self.titleString];
    
    [leftBarButton setBackgroundImage:LOADIMAGE(@"backup_img", kImageTypePNG) forState:UIControlStateNormal];
    rightBarButton.hidden = YES;
    self.titelArray = [[NSMutableArray alloc] init];
    RMAFNRequestManager *manager = [[RMAFNRequestManager alloc] init];
    manager.delegate = self;
    [manager getCheckStarPropertyWithStar_id:self.downLoadID];
}

- (void)setTagId:(NSString *)tag_id {
    self.tag_id = tag_id;
}

#pragma mark - 滑动tab视图代理方法
- (NSUInteger)numberOfTab:(SUNSlideSwitchView *)view {
    return self.titelArray.count;
}

- (UIViewController *)slideSwitchView:(SUNSlideSwitchView *)view viewOfTab:(NSUInteger)number {
    NSString *title = [self.titelArray objectAtIndex:number];
    if ([title isEqualToString:@"电影"]) {
        return _starFilmListCtl;
    } else if ([title isEqualToString:@"电视剧"]) {
        return _starTeleplayListCtl;
    } else {
        return _starVarietyListCtl;
    }
}

- (void)slideSwitchView:(SUNSlideSwitchView *)view panLeftEdge:(UIPanGestureRecognizer *)panParam {
    NSLog(@"left");
}

- (void)slideSwitchView:(SUNSlideSwitchView *)view didselectTab:(NSUInteger)number {
    NSString *title = [self.titelArray objectAtIndex:number];
    if ([title isEqualToString:@"电影"]) {
        [self.starFilmListCtl requestData];
    } else if ([title isEqualToString:@"电视剧"]) {
        [self.starTeleplayListCtl requestData];
    } else {
        [self.starVarietyListCtl requestData];
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

#pragma mark downLoad finish
- (void)requestFinishiDownLoadWith:(NSMutableArray *)data{
    NSDictionary *dataDic = [data objectAtIndex:0];
    if([[dataDic objectForKey:@"vod_num"] intValue]>0){
        [self.titelArray addObject:@"电影"];
    }
    if([[dataDic objectForKey:@"tv_num"] intValue]>0){
        [self.titelArray addObject:@"电视剧"];
    }
    if([[dataDic objectForKey:@"variety_num"] intValue]>0){
        [self.titelArray addObject:@"综艺"];
    }
    _slideSwitchView = [[SUNSlideSwitchView alloc] initWithFrame:CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleHeight)];
    _slideSwitchView.slideSwitchViewDelegate = self;
    _slideSwitchView.btnTitleArray = self.titelArray;
    [self.view addSubview:_slideSwitchView];
    
    _starFilmListCtl = [[RMShouldSeeMovieViewController alloc] init];
    _starFilmListCtl.myChannelShouldDelegate = self;
    _starFilmListCtl.downLoadID = self.downLoadID;
    
    _starTeleplayListCtl = [[RMShouldSeeTVViewController alloc] init];
    _starTeleplayListCtl.myChannelShouldDelegate = self;
    _starTeleplayListCtl.downLoadID = self.downLoadID;
    
    _starVarietyListCtl = [[RMShouldSeeVarietViewController alloc] init];
    _starVarietyListCtl.myChannelShouldDelegate = self;
    _starVarietyListCtl.downLoadID = self.downLoadID;
    
    if (IS_IPHONE_4_SCREEN | IS_IPHONE_5_SCREEN){
        _slideSwitchView.btnHeight = 30;
        _slideSwitchView.btnWidth = 93;
    }else if (IS_IPHONE_6_SCREEN){
        _slideSwitchView.btnHeight = 30;
        _slideSwitchView.btnWidth = 93;
    }else if (IS_IPHONE_6p_SCREEN){
        _slideSwitchView.btnHeight = 37 ;
        _slideSwitchView.btnWidth = 120;
    }
    [_slideSwitchView buildUI];
}

@end
