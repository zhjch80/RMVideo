//
//  RMVideoPlaybackDetailsViewController.m
//  RMVideo
//
//  Created by runmobile on 14-10-17.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMVideoPlaybackDetailsViewController.h"
#import "HMSegmentedControl.h"

#import "RMVideoPlotIntroducedViewController.h"
#import "RMVideoBroadcastAddressViewController.h"
#import "RMVideoCreativeStaffViewController.h"

#import "RMAFNRequestManager.h"
#import "RMPublicModel.h"
#import "UIImageView+AFNetworking.h"

@interface RMVideoPlaybackDetailsViewController ()<RMAFNRequestManagerDelegate> {

}

@property (nonatomic, copy) HMSegmentedControl *segmentedControl;

@property (nonatomic, strong) RMVideoPlotIntroducedViewController * videoPlotIntroducedCtl;
@property (nonatomic, strong) RMVideoBroadcastAddressViewController * videoBroadcastAddressCtl;
@property (nonatomic, strong) RMVideoCreativeStaffViewController * videoCreativeStaff;

@end

@implementation RMVideoPlaybackDetailsViewController

- (instancetype)init{
    self = [super init];
    if (self) {
        self.tabBarIdentifier = [[NSMutableString alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    [self.videoRateView setImagesDeselected:@"mx_rateEmpty_img" partlySelected:@"mx_rateEmpty_img" fullSelected:@"mx_rateFull_img" andDelegate:nil];
    [self.videoRateView displayRating:3];
    
    if (IS_IPHONE_4_SCREEN | IS_IPHONE_5_SCREEN){
        self.videoHeadBGView.frame = CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth, 205);
        self.videoImg.frame = CGRectMake(10, 10, 128, 175);
    }else if (IS_IPHONE_6_SCREEN){
        
    }else if (IS_IPHONE_6p_SCREEN){
        self.videoHeadBGView.frame = CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth, 267);
        self.videoImg.frame = CGRectMake(20, 17, 167, 233);
        self.videoTitle.frame = CGRectMake(200, 65, 210, 21);
        self.videoRateView.frame = CGRectMake(200, 100, 200, 30);
        self.videoPlayImg.frame = CGRectMake(200, 125, 10, 10);
        self.videoPlayCount.frame = CGRectMake(220, 120, 200, 20);
        self.videoUpLine.frame = CGRectMake(200, 157, 200, 2);
        self.videoDownLine.frame = CGRectMake(200, 199, 200, 2);
        self.videoLeftLine.frame = CGRectMake(260, 164, 2, 30);
        self.videoRightLine.frame = CGRectMake(340, 164, 2, 30);
        self.videoDownloadBtn.frame = CGRectMake(215, 166, 25, 25);
        self.videoCollectionBtn.frame = CGRectMake(290, 166, 25, 25);
        self.videoShareBtn.frame = CGRectMake(360, 166, 25, 25);
    }
    
    [self setTitle:@"电影"];
    [leftBarButton setBackgroundImage:LOADIMAGE(@"backup_img", kImageTypePNG) forState:UIControlStateNormal];
    rightBarButton.hidden = YES;
    
    [self.videoRateView setImagesDeselected:@"mx_rateEmpty_img" partlySelected:@"mx_rateEmpty_img" fullSelected:@"mx_rateFull_img" andDelegate:nil];
    [self.videoRateView displayRating:4];
    
    _segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"", @"", @""] withIdentifierType:@"videoIdentifier"];
    __block RMVideoPlaybackDetailsViewController *blockSelf = self;
    
    [_segmentedControl setIndexChangeBlock:^(NSUInteger index) {
        [blockSelf.segmentedControl ChangeLabelTitleColor:index];
        switch (index) {
            case 0:{
                //默认进第一个
                if (! blockSelf.videoPlotIntroducedCtl){
                    blockSelf.videoPlotIntroducedCtl = [[RMVideoPlotIntroducedViewController alloc] init];
                }
                if (IS_IPHONE_4_SCREEN |IS_IPHONE_5_SCREEN){
                    blockSelf.videoPlotIntroducedCtl.view.frame = CGRectMake(0, 245, [UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleHeight - 225);
                }else if (IS_IPHONE_6_SCREEN){
                    
                }else if (IS_IPHONE_6p_SCREEN){
                    blockSelf.videoPlotIntroducedCtl.view.frame = CGRectMake(0, 245 + 62, [UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleHeight - 225);
                }
                [blockSelf.view addSubview:blockSelf.videoPlotIntroducedCtl.view];
                break;
            }
            case 1:{
                if (! blockSelf.videoBroadcastAddressCtl){
                    blockSelf.videoBroadcastAddressCtl = [[RMVideoBroadcastAddressViewController alloc] init];
                }
                if (IS_IPHONE_4_SCREEN | IS_IPHONE_5_SCREEN){
                blockSelf.videoBroadcastAddressCtl.view.frame = CGRectMake(0, 245, [UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleHeight - 225);
                }else if (IS_IPHONE_6_SCREEN){
                    
                }else if (IS_IPHONE_6p_SCREEN){
                blockSelf.videoBroadcastAddressCtl.view.frame = CGRectMake(0, 245 + 62, [UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleHeight - 225);
                }

                [blockSelf.view addSubview:blockSelf.videoBroadcastAddressCtl.view];
                break;
            }
            case 2:{
                if (! blockSelf.videoCreativeStaff){
                    blockSelf.videoCreativeStaff = [[RMVideoCreativeStaffViewController alloc] init];
                }
                if (IS_IPHONE_4_SCREEN | IS_IPHONE_5_SCREEN){
                    blockSelf.videoCreativeStaff.view.frame = CGRectMake(0, 245, [UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleHeight - 225);
                }else if (IS_IPHONE_6_SCREEN){
                    
                }else if (IS_IPHONE_6p_SCREEN){
                    blockSelf.videoCreativeStaff.view.frame = CGRectMake(0, 245 + 62, [UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleHeight - 225);
                }
 
                [blockSelf.view addSubview:blockSelf.videoCreativeStaff.view];
                break;
            }
                
            default:
                break;
        }
    }];
    if (IS_IPHONE_4_SCREEN | IS_IPHONE_5_SCREEN){
        _segmentedControl.frame = CGRectMake(0, 205, [UtilityFunc shareInstance].globleWidth, 40);
    }else if (IS_IPHONE_6_SCREEN){
        
    }else if (IS_IPHONE_6p_SCREEN){
        _segmentedControl.frame = CGRectMake(0, 267, [UtilityFunc shareInstance].globleWidth, 40);
    }
    [_segmentedControl setSelectedIndex:0];
    [_segmentedControl setBackgroundColor:[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1]];
    [_segmentedControl setTextColor:[UIColor clearColor]];
    [_segmentedControl setSelectionIndicatorColor:[UIColor clearColor]];
    [_segmentedControl setTag:3];
    [self.view addSubview:_segmentedControl];
    
    //TODO:修改成动态
    //self.currentVideo_id
    RMAFNRequestManager * request = [[RMAFNRequestManager alloc] init];
    [request getVideoDetailWithID:@"623" andToken:@""];
    request.delegate = self;
}

#pragma mark - Base Method

- (void)navgationBarButtonClick:(UIBarButtonItem *)sender {
    switch (sender.tag) {
        case 1:{
            NSLog(@"tabBarIdentifier:%@",self.tabBarIdentifier);
            [self.navigationController popViewControllerAnimated:YES];
            if ([self.tabBarIdentifier isEqualToString:kYES]){
                [[NSNotificationCenter defaultCenter] postNotificationName:kAppearTabbar object:nil];
            }else{
            }
            break;
        }
        case 2:{
            
        }
            
        default:
            break;
    }
}



- (IBAction)mbuttonClick:(UIButton *)sender {
    switch (sender.tag) {
        case 101:{
            //下载
            NSLog(@"下载");
            
            break;
        }
        case 102:{
            //收藏
            NSLog(@"收藏");
            
            break;
        }
        case 103:{
            //分享
            NSLog(@"分享");
            
            break;
        }
            
        default:
            break;
    }
}

#pragma mark - 返回（pop）上一级界面时候，设置TabBar是否出现 YES 为显示 NO 为隐藏

- (void)setAppearTabBarNextPopViewController:(NSString *)identifier {
    self.tabBarIdentifier = [NSMutableString stringWithFormat:@"%@",identifier];
}

#pragma mark request RMAFNRequestManagerDelegate

- (void)requestFinishiDownLoadWith:(NSMutableArray *)data {
//    RMPublicModel * model = [data objectAtIndex:0];
    NSLog(@"self.currentVideo_id:%@",self.currentVideo_id);
//    NSLog(@"name:%@, hits:%@,video_id:%@",model.name,model.hits,model.video_id);

}

- (void)requestError:(NSError *)error {
    NSLog(@"视频详情：error:%@",error);
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
