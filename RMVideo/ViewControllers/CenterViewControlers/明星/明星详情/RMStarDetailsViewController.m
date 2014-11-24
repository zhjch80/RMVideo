//
//  RMStarDetailsViewController.m
//  RMVideo
//
//  Created by runmobile on 14-10-13.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMStarDetailsViewController.h"
#import "HMSegmentedControl.h"
#import "RMStarTeleplayListViewController.h"
#import "RMStarFilmListViewController.h"
#import "RMStarVarietyListViewController.h"
#import "RMLoginViewController.h"
#import "RMCustomNavViewController.h"
#import "RMCustomPresentNavViewController.h"

typedef enum{
    requestIntroType = 1,
    requestAddMyChannelType,
    requestDeleteMyChannelType
}LoadType;

#define maskView_TAG            101

#define kFold_on                @"fold_on"
#define kFold_off               @"fold_off"

@interface RMStarDetailsViewController ()<RMAFNRequestManagerDelegate>{
    NSString * foldType;
    RMAFNRequestManager * manager;
    NSMutableArray * introDataArr;
    LoadType loadType;
    BOOL isStarAttentionMyChannel;             //1为已经加入，0为没有加入
    
}
@property (nonatomic, strong) NSMutableString * star_id;

@property (nonatomic, copy) HMSegmentedControl *segmentedControl;

@property RMStarTeleplayListViewController * starTeleplayListCtl;
@property RMStarFilmListViewController * starFilmListCtl;
@property RMStarVarietyListViewController * starVarietyListCtl;

@end

@implementation RMStarDetailsViewController
@synthesize segmentedControl = _segmentedControl;

@synthesize starTeleplayListCtl = _starTeleplayListCtl;
@synthesize starFilmListCtl = _starFilmListCtl;
@synthesize starVarietyListCtl = _starVarietyListCtl;

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setTitle:@"明星"];
    [Flurry logEvent:@"VIEW_StarDetail" timed:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [Flurry endTimedEvent:@"VIEW_StarDetail" withParameters:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    introDataArr = [[NSMutableArray alloc] init];
    foldType = [[NSString alloc] init];
    foldType = kFold_off;
    loadType = requestIntroType;
    
    [leftBarButton setBackgroundImage:LOADIMAGE(@"backup_img", kImageTypePNG) forState:UIControlStateNormal];
    rightBarButton.hidden = YES;
    
    self.headView.frame = CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth, 140);
    self.headView.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1];
    self.headSubView.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1];
    self.starName.backgroundColor = [UIColor clearColor];
    self.starIntrduce.editable = NO;
    
    if (IS_IPHONE_4_SCREEN | IS_IPHONE_5_SCREEN){
        self.starIntrduce.frame = CGRectMake(0, 20, 200, 60);
        self.headSubView.frame = CGRectMake(120, 10, 204, 129);
        self.foldMarkTitle.frame = CGRectMake(130, 96, 31, 21);
        self.foldImg.frame = CGRectMake(164, 102, 12, 8);
        self.foldBtn.frame = CGRectMake(130, 93, 56, 28);
    }else if (IS_IPHONE_6_SCREEN){
        self.starIntrduce.frame = CGRectMake(0, 20, 260, 60);
        [self.starIntrduce setContentOffset:CGPointMake(0, 0) animated:YES];
        self.starIntrduce.bouncesZoom = NO;
        self.headSubView.frame = CGRectMake(120, 10, 264, 129);
        self.foldMarkTitle.frame = CGRectMake(180, 96, 31, 21);
        self.foldImg.frame = CGRectMake(214, 102, 12, 8);
        self.foldBtn.frame = CGRectMake(180, 93, 56, 28);
    }else if (IS_IPHONE_6p_SCREEN){
        self.starIntrduce.frame = CGRectMake(0, 20, 300, 60);
        [self.starIntrduce setContentOffset:CGPointMake(0, 0) animated:YES];
        self.starIntrduce.bouncesZoom = NO;
        self.headSubView.frame = CGRectMake(120, 10, 304, 129);
        self.foldMarkTitle.frame = CGRectMake(220, 96, 31, 21);
        self.foldImg.frame = CGRectMake(254, 102, 12, 8);
        self.foldBtn.frame = CGRectMake(220, 93, 56, 28);
    }
    
    [self.headSubChannelView.layer setCornerRadius:8.0];
    self.starIntrduce.scrollEnabled = YES;
    
    UIView * maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleHeight - 180)];
    maskView.alpha = 0.4;
    maskView.userInteractionEnabled = YES;
    maskView.hidden = YES;
    maskView.tag = maskView_TAG;
    maskView.backgroundColor = [UIColor blackColor];
    [maskView bringSubviewToFront:self.starFilmListCtl.view];
    [maskView bringSubviewToFront:self.starTeleplayListCtl.view];
    [maskView bringSubviewToFront:self.starVarietyListCtl.view];
    [self.contentView addSubview:maskView];
    
    _segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"", @"", @""] withIdentifierType:@"starIdentifier"];
    __block RMStarDetailsViewController *blockSelf = self;
    
    [_segmentedControl setIndexChangeBlock:^(NSUInteger index) {
        [blockSelf.segmentedControl ChangeLabelTitleColor:index];
        switch (index) {
            case 0:{
                //默认进第一个
                if (! blockSelf.starFilmListCtl){
                    blockSelf.starFilmListCtl = [[RMStarFilmListViewController alloc] init];
                }
                if (IS_IPHONE_6_SCREEN){
                    blockSelf.starFilmListCtl.view.frame = CGRectMake(0, 40, [UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleHeight - 175);
                }else if (IS_IPHONE_6p_SCREEN){
                    blockSelf.starFilmListCtl.view.frame = CGRectMake(0, 40, [UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleHeight - 175);
                }else{
                    blockSelf.starFilmListCtl.view.frame = CGRectMake(0, 40, [UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleHeight - 175);
                }
                blockSelf.starFilmListCtl.starDetailsDelegate = blockSelf;
                [blockSelf.contentView insertSubview:blockSelf.starFilmListCtl.view belowSubview:maskView];
                blockSelf.starFilmListCtl.star_id = blockSelf.star_id;
                [blockSelf.starFilmListCtl startRequest];
                break;
            }
            case 1:{
                if (! blockSelf.starTeleplayListCtl){
                    blockSelf.starTeleplayListCtl = [[RMStarTeleplayListViewController alloc] init];
                }
                if (IS_IPHONE_6_SCREEN){
                    blockSelf.starTeleplayListCtl.view.frame = CGRectMake(0, 40, [UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleHeight - 175);
                }else if (IS_IPHONE_6p_SCREEN){
                    blockSelf.starTeleplayListCtl.view.frame = CGRectMake(0, 40, [UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleHeight - 175);
                }else{
                    blockSelf.starTeleplayListCtl.view.frame = CGRectMake(0, 40, [UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleHeight - 175);
                }
                blockSelf.starTeleplayListCtl.starDetailsDelegate = blockSelf;
                [blockSelf.contentView insertSubview:blockSelf.starTeleplayListCtl.view belowSubview:maskView];
                blockSelf.starTeleplayListCtl.star_id = blockSelf.star_id;
                [blockSelf.starTeleplayListCtl startRequest];
                break;
            }
            case 2:{
                if (! blockSelf.starVarietyListCtl){
                    blockSelf.starVarietyListCtl = [[RMStarVarietyListViewController alloc] init];
                }
                if (IS_IPHONE_6_SCREEN){
                    blockSelf.starVarietyListCtl.view.frame = CGRectMake(0, 40, [UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleHeight - 175);
                }else if (IS_IPHONE_6p_SCREEN){
                    blockSelf.starVarietyListCtl.view.frame = CGRectMake(0, 40, [UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleHeight - 175);
                }else{
                    blockSelf.starVarietyListCtl.view.frame = CGRectMake(0, 40, [UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleHeight - 175);
                }
                blockSelf.starVarietyListCtl.starDetailsDelegate = blockSelf;
                [blockSelf.contentView insertSubview:blockSelf.starVarietyListCtl.view belowSubview:maskView];
                blockSelf.starVarietyListCtl.star_id = blockSelf.star_id;
                [blockSelf.starVarietyListCtl startRequest];
                break;
            }
                
            default:
                break;
        }
    }];
    
    _segmentedControl.frame = CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth, 40);

    [_segmentedControl setSelectedIndex:0];
    [_segmentedControl setBackgroundColor:[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1]];
    [_segmentedControl setTextColor:[UIColor clearColor]];
    [_segmentedControl setSelectionIndicatorColor:[UIColor clearColor]];
    [_segmentedControl setTag:3];
    [self.contentView addSubview:_segmentedControl];

    CUSFileStorage *storage = [CUSFileStorageManager getFileStorage:CURRENTENCRYPTFILE];
    NSDictionary *dict = [storage objectForKey:UserLoginInformation_KEY];
    manager = [[RMAFNRequestManager alloc] init];
    [manager getStartDetailWithID:self.star_id WithToken:[NSString stringWithFormat:@"%@",[dict objectForKey:@"token"]]];
    manager.delegate = self;
}


#pragma mark - Base Method

- (void)navgationBarButtonClick:(UIBarButtonItem *)sender {
    switch (sender.tag) {
        case 1:{
            [self.navigationController popViewControllerAnimated:YES];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kAppearTabbar object:nil];
            break;
        }
        case 2:{
            
            break;
        }
            
        default:
            break;
    }
}

#pragma mark - buttonClick Method

- (void)willStartAddOrDeleteStar {
    if ([UtilityFunc isConnectionAvailable] == 0){
        [SVProgressHUD showErrorWithStatus:kShowConnectionAvailableError duration:1.0];
        return;
    }
    [SVProgressHUD dismiss];
    //加入 或者 删除 明星  在我的频道
    CUSFileStorage *storage = [CUSFileStorageManager getFileStorage:CURRENTENCRYPTFILE];
    if (![[AESCrypt decrypt:[storage objectForKey:LoginStatus_KEY] password:PASSWORD] isEqualToString:@"islogin"]){
        RMLoginViewController * loginCtl = [[RMLoginViewController alloc] init];
        RMCustomPresentNavViewController * loginNav = [[RMCustomPresentNavViewController alloc] initWithRootViewController:loginCtl];
        [self presentViewController:loginNav animated:YES completion:^{
        }];
        return;
    }
    if (isStarAttentionMyChannel){
        loadType = requestDeleteMyChannelType;
        RMPublicModel * model = [introDataArr objectAtIndex:0];
        CUSFileStorage *storage = [CUSFileStorageManager getFileStorage:CURRENTENCRYPTFILE];
        NSDictionary *dict = [storage objectForKey:UserLoginInformation_KEY];
        [manager getDeleteMyChannelWithTag:model.tag_id WithToken:[NSString stringWithFormat:@"%@",[dict objectForKey:@"token"]]];
        manager.delegate = self;
    }else{
        loadType = requestAddMyChannelType;
        RMPublicModel * model = [introDataArr objectAtIndex:0];
        CUSFileStorage *storage = [CUSFileStorageManager getFileStorage:CURRENTENCRYPTFILE];
        NSDictionary *dict = [storage objectForKey:UserLoginInformation_KEY];
        [manager getJoinMyChannelWithToken:[NSString stringWithFormat:@"%@",[dict objectForKey:@"token"]] andID:model.tag_id];
        manager.delegate = self;
    }
}

- (IBAction)mbuttonClick:(UIButton *)sender {
    switch (sender.tag) {
        case 201:{
            [SVProgressHUD showWithStatus:@"处理中" maskType:SVProgressHUDMaskTypeBlack];
            [self performSelector:@selector(willStartAddOrDeleteStar) withObject:nil afterDelay:1.0];
            break;
        }
        case 202:{
            if ([foldType isEqualToString:kFold_on]){
                //合上
                self.contentView.userInteractionEnabled = YES;
                ((UIView *)[self.view viewWithTag:maskView_TAG]).hidden = YES;
                [UIView animateWithDuration:0.3 animations:^{
                    if (IS_IPHONE_4_SCREEN | IS_IPHONE_5_SCREEN){
                        self.starIntrduce.frame = CGRectMake(0, 20, 200, 60);
                        self.headSubView.frame = CGRectMake(120, 10, 204, 129);
                        self.foldMarkTitle.frame = CGRectMake(130, 96, 31, 21);
                        self.foldImg.frame = CGRectMake(164, 102, 12, 8);
                        self.foldBtn.frame = CGRectMake(130, 93, 56, 28);
                    }else if (IS_IPHONE_6_SCREEN){
                        self.starIntrduce.frame = CGRectMake(0, 20, 260, 60);
                        self.headSubView.frame = CGRectMake(120, 10, 264, 129);
                        self.foldMarkTitle.frame = CGRectMake(180, 96, 31, 21);
                        self.foldImg.frame = CGRectMake(214, 102, 12, 8);
                        self.foldBtn.frame = CGRectMake(180, 93, 56, 28);
                    }else if (IS_IPHONE_6p_SCREEN){
                        self.starIntrduce.frame = CGRectMake(0, 20, 300, 60);
                        self.headSubView.frame = CGRectMake(120, 10, 304, 129);
                        self.foldMarkTitle.frame = CGRectMake(220, 96, 31, 21);
                        self.foldImg.frame = CGRectMake(254, 102, 12, 8);
                        self.foldBtn.frame = CGRectMake(220, 93, 56, 28);                    }
                } completion:^(BOOL finished) {
                    self.foldMarkTitle.text = @"展开";
                    self.foldImg.image = LOADIMAGE(@"mx_unfold",kImageTypePNG);
                    self.headSubChannelView.hidden = NO;
                }];
                foldType = kFold_off;
            }else if ([foldType isEqualToString:kFold_off]){
                //展开
                self.contentView.userInteractionEnabled = NO;
                self.headSubChannelView.hidden = YES;
                ((UIView *)[self.view viewWithTag:maskView_TAG]).hidden = NO;
                [((UIView *)[self.view viewWithTag:maskView_TAG]) bringSubviewToFront:self.view];
                [UIView animateWithDuration:0.3 animations:^{
                    if (IS_IPHONE_4_SCREEN | IS_IPHONE_5_SCREEN){
                        self.starIntrduce.frame = CGRectMake(0, 20, 200, [UtilityFunc shareInstance].globleHeight - 110);
                        self.headSubView.frame = CGRectMake(120, 10, 204, [UtilityFunc shareInstance].globleHeight - 54);
                        self.foldMarkTitle.frame = CGRectMake(130, [UtilityFunc shareInstance].globleHeight - 85, 31, 21);
                        self.foldImg.frame = CGRectMake(164, [UtilityFunc shareInstance].globleHeight - 78, 12, 8);
                        self.foldBtn.frame = CGRectMake(130, [UtilityFunc shareInstance].globleHeight - 85, 56, 28);
                    }else if (IS_IPHONE_6_SCREEN){
                        self.starIntrduce.frame = CGRectMake(0, 20, 260, [UtilityFunc shareInstance].globleHeight - 110);
                        self.headSubView.frame = CGRectMake(120, 10, 264, [UtilityFunc shareInstance].globleHeight - 54);
                        self.foldMarkTitle.frame = CGRectMake(180, [UtilityFunc shareInstance].globleHeight - 85, 31, 21);
                        self.foldImg.frame = CGRectMake(214, [UtilityFunc shareInstance].globleHeight - 78, 12, 8);
                        self.foldBtn.frame = CGRectMake(180, [UtilityFunc shareInstance].globleHeight - 85, 56, 28);
                    }else if (IS_IPHONE_6p_SCREEN){
                        self.starIntrduce.frame = CGRectMake(0, 20, 300, [UtilityFunc shareInstance].globleHeight - 110);
                        self.headSubView.frame = CGRectMake(120, 10, 304, [UtilityFunc shareInstance].globleHeight - 54);
                        self.foldMarkTitle.frame = CGRectMake(220, [UtilityFunc shareInstance].globleHeight - 85, 31, 21);
                        self.foldImg.frame = CGRectMake(254, [UtilityFunc shareInstance].globleHeight - 78, 12, 8);
                        self.foldBtn.frame = CGRectMake(220, [UtilityFunc shareInstance].globleHeight - 85, 56, 28);
                    }
                } completion:^(BOOL finished) {
                    self.foldMarkTitle.text = @"收起";
                    self.foldImg.image = LOADIMAGE(@"mx_fold",kImageTypePNG);
                }];
                foldType = kFold_on;
            }
            break;
        }
  
        default:
            break;
    }
}

- (void)setStarID:(NSString *)star_id {
    self.star_id = [[NSMutableString alloc] initWithString:star_id];
}

#pragma mark - requset RMAFNRequestManagerDelegate

/**
 *刷新电影
 */
- (void)refreshStarFilmListDate:(RMPublicModel *)model {
//    [self.videoPlotIntroducedCtl updatePlotIntroduced:model];
}

/**
 *刷新电视剧
 */
- (void)refreshStarTeleplayListDate:(RMPublicModel *)model {
//    [self.videoBroadcastAddressCtl updateBroadcastAddress:model];
}

/**
 *刷新综艺
 */
- (void)refreshStarVarietyListDate:(RMPublicModel *)model {
//    [self.videoCreativeStaffCtl updateCreativeStaff:model];
}

- (void)refreshIntroductionView {
    RMPublicModel * model = [introDataArr objectAtIndex:0];
    [self setTitle:model.name];
    [self.starPhoto sd_setImageWithURL:[NSURL URLWithString:model.pic_url] placeholderImage:LOADIMAGE(@"Default90_119", kImageTypePNG)];
    
    [self.starName loadTextViewWithString:model.name WithTextFont:[UIFont systemFontOfSize:16.0]WithTextColor:[UIColor whiteColor] WithTextAlignment:NSTextAlignmentLeft WithSetupLabelCenterPoint:NO WithTextOffset:0];
    [self.starName startScrolling];
    
    self.starIntrduce.text = model.detail;
    if ([model.is_follow integerValue] == 1){
        self.myChannelImgState.image = LOADIMAGE(@"mx_add_success_img", kImageTypePNG);
        self.myChannelState.text = @"已在我的频道";
        isStarAttentionMyChannel = YES;
    }else{
        self.myChannelImgState.image = LOADIMAGE(@"mx_add_img", kImageTypePNG);
        self.myChannelState.text = @"加入我的频道";
        isStarAttentionMyChannel = NO;
    }
}

- (void)requestFinishiDownLoadWith:(NSMutableArray *)data {
    if (loadType == requestIntroType) {
        introDataArr = data;
        [self refreshIntroductionView];
    }else if (loadType == requestAddMyChannelType) {
        self.myChannelImgState.image = LOADIMAGE(@"mx_add_success_img", kImageTypePNG);
        self.myChannelState.text = @"已在我的频道";
        isStarAttentionMyChannel = 1;
    }else if (loadType == requestDeleteMyChannelType){
        self.myChannelImgState.image = LOADIMAGE(@"mx_add_img", kImageTypePNG);
        self.myChannelState.text = @"加入我的频道";
        isStarAttentionMyChannel = 0;
    }
}

- (void)requestError:(NSError *)error {
    NSLog(@"明星详情:%@",error);
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
