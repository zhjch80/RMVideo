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
#import "UMSocial.h"
#import "RMLoginViewController.h"
#import "RMCustomNavViewController.h"
#import "RMDownLoadingViewController.h"
#import "RMCustomPresentNavViewController.h"
#import "RMTVDownLoadViewController.h"

typedef enum{
    requestVideoContentType = 1,
    requestAddVideoCollectlType,
    requestDeleteVideoCollectlType
}LoadType;

@interface RMVideoPlaybackDetailsViewController ()<RMAFNRequestManagerDelegate,UMSocialUIDelegate> {
    LoadType loadType;
    BOOL isCollect;                 //1为收藏   0为未收藏
    BOOL isFirstViewDidAppear;      //第一次进入界面
    
    BOOL isDownload;                //该影片已经下载完成
    BOOL isDownloading;             //该影片正在下载
    BOOL isNotRecords;              //本地没有找到该影片的记录
    BOOL isDownloadAddress;      //判断是否网络上有该影片的下载地址
    
}
@property (nonatomic, strong) NSMutableArray * dataArr;

@property (nonatomic, copy) HMSegmentedControl *segmentedControl;

@property (nonatomic, strong) RMVideoPlotIntroducedViewController * videoPlotIntroducedCtl;
@property (nonatomic, strong) RMVideoBroadcastAddressViewController * videoBroadcastAddressCtl;
@property (nonatomic, strong) RMVideoCreativeStaffViewController * videoCreativeStaffCtl;
//@property (nonatomic, strong) RMPublicModel * publicModel;

@end

@implementation RMVideoPlaybackDetailsViewController

- (instancetype)init{
    self = [super init];
    if (self) {
        self.tabBarIdentifier = [[NSMutableString alloc] init];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [Flurry logEvent:@"VIEW_VideoPlayDetails" timed:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [Flurry endTimedEvent:@"VIEW_VideoPlayDetails" withParameters:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!isFirstViewDidAppear){
        [SVProgressHUD showWithStatus:@"加载中..." maskType:SVProgressHUDMaskTypeBlack];
        [self performSelector:@selector(willStartRequest) withObject:nil afterDelay:1.0];
        isFirstViewDidAppear = YES;
    }
}

- (void)willStartRequest {
    if ([UtilityFunc isConnectionAvailable] == 0){
        self.videoDownloadBtn.hidden = YES;
        self.videoShareBtn.hidden = YES;
        self.videoCollectionBtn.hidden = YES;
        self.videoPlayImg.hidden = YES;
        [SVProgressHUD showErrorWithStatus:kShowConnectionAvailableError duration:1.0];
        [self refreshPlotIntroducedDate:nil];
    }else{
        [SVProgressHUD dismiss];
        RMAFNRequestManager * request = [[RMAFNRequestManager alloc] init];
        CUSFileStorage *storage = [CUSFileStorageManager getFileStorage:CURRENTENCRYPTFILE];
        NSDictionary *dict = [storage objectForKey:UserLoginInformation_KEY];
        [request getVideoDetailWithID:self.currentVideo_id andToken:[NSString stringWithFormat:@"%@",[dict objectForKey:@"token"]]];
        request.delegate = self;
        [SVProgressHUD showWithStatus:@"加载中..." maskType:SVProgressHUDMaskTypeBlack];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    isFirstViewDidAppear = NO;
    self.dataArr = [[NSMutableArray alloc] init];
    loadType = requestVideoContentType;
    if (IS_IPHONE_4_SCREEN | IS_IPHONE_5_SCREEN){
        self.videoHeadBGView.frame = CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth, 205);
        self.videoImg.frame = CGRectMake(10, 10, 128, 175);
    }else if (IS_IPHONE_6_SCREEN){
        self.videoHeadBGView.frame = CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth, 210);
        self.videoImg.frame = CGRectMake(20, 17, 128, 175);
        self.videoTitle.frame = CGRectMake(155, 25, 210, 21);
        self.videoRateView.frame = CGRectMake(155, 55, 84, 20);
        self.videoPlayImg.frame = CGRectMake(155, 80, 10, 10);
        self.videoPlayCount.frame = CGRectMake(180, 75, 210, 20);
        self.videoUpLine.frame = CGRectMake(155, 130, 210, 2);
        self.videoDownLine.frame = CGRectMake(155, 170, 210, 2);
        self.videoLeftLine.frame = CGRectMake(220, 135, 2, 30);
        self.videoRightLine.frame = CGRectMake(295, 135, 2, 30);
        self.videoDownloadBtn.frame = CGRectMake(165, 140, 25, 25);
        self.videoCollectionBtn.frame = CGRectMake(245, 140, 25, 25);
        self.videoShareBtn.frame = CGRectMake(325, 140, 25, 25);
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
    
    [leftBarButton setBackgroundImage:LOADIMAGE(@"backup_img", kImageTypePNG) forState:UIControlStateNormal];
    rightBarButton.hidden = YES;
    
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
                    blockSelf.videoPlotIntroducedCtl.view.frame = CGRectMake(0, 250, [UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleHeight - 235);
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
                    blockSelf.videoBroadcastAddressCtl.view.frame = CGRectMake(0, 250, [UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleHeight - 225);
                }else if (IS_IPHONE_6p_SCREEN){
                    blockSelf.videoBroadcastAddressCtl.view.frame = CGRectMake(0, 245 + 62, [UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleHeight - 225);
                }
                blockSelf.videoBroadcastAddressCtl.videoPlayDelegate = blockSelf;
                [blockSelf.view addSubview:blockSelf.videoBroadcastAddressCtl.view];
                if (blockSelf.dataArr.count == 0){
                    [blockSelf refreshBroadcastAddressDate:nil];
                }else{
                    RMPublicModel * model = [blockSelf.dataArr objectAtIndex:0];
                    [blockSelf refreshBroadcastAddressDate:model];
                }
                
                break;
            }
            case 2:{
                if (! blockSelf.videoCreativeStaffCtl){
                    blockSelf.videoCreativeStaffCtl = [[RMVideoCreativeStaffViewController alloc] init];
                }
                if (IS_IPHONE_4_SCREEN | IS_IPHONE_5_SCREEN){
                    blockSelf.videoCreativeStaffCtl.view.frame = CGRectMake(0, 245, [UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleHeight - 225);
                }else if (IS_IPHONE_6_SCREEN){
                    blockSelf.videoCreativeStaffCtl.view.frame = CGRectMake(0, 250, [UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleHeight - 235);
                }else if (IS_IPHONE_6p_SCREEN){
                    blockSelf.videoCreativeStaffCtl.view.frame = CGRectMake(0, 245 + 62, [UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleHeight - 225);
                }
                [blockSelf.view addSubview:blockSelf.videoCreativeStaffCtl.view];
                blockSelf.videoCreativeStaffCtl.videoPlayBackDetailsDelegate = blockSelf;
                if (blockSelf.dataArr.count == 0){
                    [blockSelf refreshCreativeStaffDate:nil];
                }else{
                    RMPublicModel * model = [blockSelf.dataArr objectAtIndex:0];
                    [blockSelf refreshCreativeStaffDate:model];
                }
                break;
            }
                
            default:
                break;
        }
    }];
    if (IS_IPHONE_4_SCREEN | IS_IPHONE_5_SCREEN){
        _segmentedControl.frame = CGRectMake(0, 205, [UtilityFunc shareInstance].globleWidth, 40);
    }else if (IS_IPHONE_6_SCREEN){
        _segmentedControl.frame = CGRectMake(0, 210, [UtilityFunc shareInstance].globleWidth, 40);
    }else if (IS_IPHONE_6p_SCREEN){
        _segmentedControl.frame = CGRectMake(0, 267, [UtilityFunc shareInstance].globleWidth, 40);
    }
    [_segmentedControl setSelectedIndex:0];
    [_segmentedControl setBackgroundColor:[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1]];
    [_segmentedControl setTextColor:[UIColor clearColor]];
    [_segmentedControl setSelectionIndicatorColor:[UIColor clearColor]];
    [_segmentedControl setTag:3];
    [self.view addSubview:_segmentedControl];
}

#pragma mark - Base Method

- (void)navgationBarButtonClick:(UIBarButtonItem *)sender {
    switch (sender.tag) {
        case 1:{
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

- (void)willDownload {
    if ([UtilityFunc isConnectionAvailable] == 0){
        [SVProgressHUD showErrorWithStatus:kShowConnectionAvailableError duration:0.44];
        return;
    }
    [SVProgressHUD dismiss];
    RMPublicModel * model = [self.dataArr objectAtIndex:0];
    if ([model.video_type isEqualToString:@"1"]) {
        //电影  直接下载
        if (isDownloadAddress){
            //有片源
            if(model.downLoadURL == nil){
//                NSLog(@"下载地址:%@",[[model.playurlArr objectAtIndex:0] objectForKey:@"m_down_url"]);
                RMDownLoadingViewController *rmDownLoading = [RMDownLoadingViewController shared];
                model.downLoadURL = [[model.playurlArr objectAtIndex:0] objectForKey:@"m_down_url"];
                model.downLoadState = @"等待缓存";
                model.totalMemory = @"0M";
                model.alreadyCasheMemory = @"0M";
                model.cacheProgress = @"0.0";
                //已经下载过了
                if([[Database sharedDatabase] isDownLoadMovieWith:model]){
                    UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"" message:@"已经下载成功了" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                    [alerView show];
                };
                if(![rmDownLoading dataArrayContainsModel:model]){
                    [rmDownLoading.dataArray addObject:model];
                    [rmDownLoading.downLoadIDArray addObject:model];
                    [rmDownLoading BeginDownLoad];
                    UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"" message:@"添加成功" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                    [alerView show];
                }
            }else{
                UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"" message:@"已经在下载队列中" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alerView show];
            }

        }else{
            //没有片源
            [SVProgressHUD showSuccessWithStatus:@"暂无片源可下载" duration:0.44];
        }
    }else{
        RMTVDownLoadViewController * TVDownLoadCtl = [[RMTVDownLoadViewController alloc] init];
        TVDownLoadCtl.modelID = model.video_id;
        TVDownLoadCtl.TVName = model.name;
        TVDownLoadCtl.TVHeadImage = model.pic;
        [self.navigationController pushViewController:TVDownLoadCtl animated:YES];
    }
}

- (void)willAddOrCancel {
    if ([UtilityFunc isConnectionAvailable] == 0){
        [SVProgressHUD showErrorWithStatus:kShowConnectionAvailableError duration:1.0];
        return;
    }
    [SVProgressHUD dismiss];
    //收藏 或者 取消收藏
    CUSFileStorage *storage = [CUSFileStorageManager getFileStorage:CURRENTENCRYPTFILE];
    if (![[AESCrypt decrypt:[storage objectForKey:LoginStatus_KEY] password:PASSWORD] isEqualToString:@"islogin"]){
        RMLoginViewController * loginCtl = [[RMLoginViewController alloc] init];
        RMCustomPresentNavViewController * loginNav = [[RMCustomPresentNavViewController alloc] initWithRootViewController:loginCtl];
        [self presentViewController:loginNav animated:YES completion:^{
        }];
        return;
    }
    
    if (isCollect){
        [Flurry logEvent:@"Click_AddCollect_Btn"];
        loadType = requestDeleteVideoCollectlType;
        RMAFNRequestManager * request = [[RMAFNRequestManager alloc] init];
        CUSFileStorage *storage = [CUSFileStorageManager getFileStorage:CURRENTENCRYPTFILE];
        NSDictionary *dict = [storage objectForKey:UserLoginInformation_KEY];
        [request getDeleteFavoriteVideoWithToken:[NSString stringWithFormat:@"%@",[dict objectForKey:@"token"]] videoID:self.currentVideo_id];
        request.delegate = self;
    }else{
        [Flurry logEvent:@"Click_CancelCollect_Btn"];
        loadType = requestAddVideoCollectlType;
        RMAFNRequestManager * request = [[RMAFNRequestManager alloc] init];
        CUSFileStorage *storage = [CUSFileStorageManager getFileStorage:CURRENTENCRYPTFILE];
        NSDictionary *dict = [storage objectForKey:UserLoginInformation_KEY];
        [request getAddFavoriteWithID:self.currentVideo_id andToken:[NSString stringWithFormat:@"%@",[dict objectForKey:@"token"]]];
        request.delegate = self;
    }
}

- (void)willShare {
    if ([UtilityFunc isConnectionAvailable] == 0){
        [SVProgressHUD showErrorWithStatus:kShowConnectionAvailableError duration:1.0];
        return;
    }
    [SVProgressHUD dismiss];
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:@"544db5aafd98c570d2069586"
                                      shareText:@"测试"
                                     shareImage:[UIImage imageNamed:@"001.png"]
                                shareToSnsNames:[NSArray arrayWithObjects:UMShareToSina,UMShareToWechatSession,UMShareToWechatTimeline,UMShareToQQ,UMShareToTencent,nil]
                                       delegate:self];
}

- (IBAction)mbuttonClick:(UIButton *)sender {
    switch (sender.tag) {
        case 101:{
            [Flurry logEvent:@"Click_Download_Btn"];
            [SVProgressHUD showWithStatus:@"处理中..." maskType:SVProgressHUDMaskTypeBlack];
            [self performSelector:@selector(willDownload) withObject:nil afterDelay:1.0];
            break;
        }
        case 102:{
            [SVProgressHUD showWithStatus:@"处理中..." maskType:SVProgressHUDMaskTypeBlack];
            [self performSelector:@selector(willAddOrCancel) withObject:nil afterDelay:1.0];
            break;
        }
        case 103:{
            [Flurry logEvent:@"Click_Share_Btn"];
            [SVProgressHUD showWithStatus:@"请稍后..." maskType:SVProgressHUDMaskTypeBlack];
            [self performSelector:@selector(willShare) withObject:nil afterDelay:1.0];
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
/**
 刷新视频详情界面
 */
- (void)refreshVideoHeadView {
    RMPublicModel * model = [self.dataArr objectAtIndex:0];
    if ([model.video_type isEqualToString:@"1"]) {
        [self setTitle:@"电影"];
    }else if ([model.video_type isEqualToString:@"2"]) {
        [self setTitle:@"电视剧"];
    }else if ([model.video_type isEqualToString:@"3"]) {
        [self setTitle:@"综艺"];
    }
    [self.videoImg sd_setImageWithURL:[NSURL URLWithString:model.pic] placeholderImage:LOADIMAGE(@"sp_loadingImg", kImageTypePNG)];
    self.videoTitle.text = model.name;
    [self.videoRateView setImagesDeselected:@"mx_rateEmpty_img" partlySelected:@"mx_rateEmpty_img" fullSelected:@"mx_rateFull_img" andDelegate:nil];
    [self.videoRateView displayRating:[model.gold integerValue]];
    self.videoPlayCount.text = [NSString stringWithFormat:@"播放%@次",model.hits];
    
    self.videoDownloadBtn.hidden = NO;
    self.videoShareBtn.hidden = NO;
    self.videoPlayImg.hidden = NO;
    
    if ([model.is_favorite integerValue] == 1){
        [self.videoCollectionBtn setImage:LOADIMAGE(@"vd_collectionRedImg", kImageTypePNG) forState:UIControlStateNormal];
        isCollect = YES;
    }else{
        [self.videoCollectionBtn setImage:LOADIMAGE(@"vd_collectionWhiteImg", kImageTypePNG) forState:UIControlStateNormal];
        isCollect = NO;
    }
    
    [self refreshPlotIntroducedDate:model];
    
    if ([model.playurlArr count] == 0){
        //没有片源
        [self.videoDownloadBtn setImage:LOADIMAGE(@"vd_loadImg_selected", kImageTypePNG) forState:UIControlStateNormal];
        isDownloadAddress = NO;
        return ;
    }
    
    if ([model.video_type integerValue] == 1){
        //电影
        if ([NSString stringWithFormat:@"%@",[[model.playurlArr objectAtIndex:0] objectForKey:@"m_down_url"]].length == 0){
            //没有片源
            [self.videoDownloadBtn setImage:LOADIMAGE(@"vd_loadImg_selected", kImageTypePNG) forState:UIControlStateNormal];
            isDownloadAddress = NO;
        }else{
            //有片源
            [self.videoDownloadBtn setImage:LOADIMAGE(@"vd_loadImg_selected", kImageTypePNG) forState:UIControlStateNormal];
            isDownloadAddress = YES;
        }
        
        RMDownLoadingViewController *rmDownLoading = [RMDownLoadingViewController shared];
        if ([[Database sharedDatabase] isDownLoadMovieWith:model]){
            //该部影片已经下载完成了
            isDownload = YES;
            isDownloading = NO;
            isNotRecords = YES;
            [self.videoDownloadBtn setImage:LOADIMAGE(@"vd_loadImg_selected", kImageTypePNG) forState:UIControlStateNormal];
        }else if ([rmDownLoading dataArrayContainsModel:model]){
            //该部影片正在下载
            isDownload = NO;
            isDownloading = YES;
            isNotRecords = YES;
            [self.videoDownloadBtn setImage:LOADIMAGE(@"vd_loadImg_selected", kImageTypePNG) forState:UIControlStateNormal];
        }else{
            //本地没有该部影片的记录
            isDownload = NO;
            isDownloading = NO;
            isNotRecords = NO;
            [self.videoDownloadBtn setImage:LOADIMAGE(@"vd_loadImg", kImageTypePNG) forState:UIControlStateNormal];
        }
    }else{
        //电视剧 综艺
    }
}

/**
 *刷新剧情介绍的内容
 */
- (void)refreshPlotIntroducedDate:(RMPublicModel *)model {
    [self.videoPlotIntroducedCtl updatePlotIntroduced:model];
}

/**
 *刷新播放地址的内容
 */
- (void)refreshBroadcastAddressDate:(RMPublicModel *)model {
    [self.videoBroadcastAddressCtl updateBroadcastAddress:model];
}

/**
 *刷新主创人员的内容
 */
- (void)refreshCreativeStaffDate:(RMPublicModel *)model {
    [self.videoCreativeStaffCtl updateCreativeStaff:model];
}

- (void)requestFinishiDownLoadWith:(NSMutableArray *)data {
    if (loadType == requestVideoContentType) {
        self.dataArr = data;
        [self refreshVideoHeadView];
        [SVProgressHUD dismiss];
    }else if (loadType == requestAddVideoCollectlType) {
        [self.videoCollectionBtn setImage:LOADIMAGE(@"vd_collectionRedImg", kImageTypePNG) forState:UIControlStateNormal];
        isCollect = YES;
    }else if (loadType == requestDeleteVideoCollectlType){
        [self.videoCollectionBtn setImage:LOADIMAGE(@"vd_collectionWhiteImg", kImageTypePNG) forState:UIControlStateNormal];
        isCollect = NO;
    }
}

- (void)requestError:(NSError *)error {
    NSLog(@"error:%@",error);
    self.videoDownloadBtn.hidden = YES;
    self.videoShareBtn.hidden = YES;
    self.videoCollectionBtn.hidden = YES;
    self.videoPlayImg.hidden = YES;
    [SVProgressHUD dismiss];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//根据responseCode得到发送结果,如果分享成功
-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response{
    if(response.responseCode == UMSResponseCodeSuccess)
    {
        //得到分享到的微博平台名
        NSLog(@"share to sns name is %@",[[response.data allKeys] objectAtIndex:0]);
    }
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
