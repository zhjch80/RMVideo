//
//  RMMyChannelViewController.m
//  RMVideo
//
//  Created by runmobile on 14-10-13.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMMyChannelViewController.h"
#import "RMMoreWonderfulViewController.h"
#import "RMMyChannelCell.h"
#import "RMSetupViewController.h"
#import "RMSearchViewController.h"
#import "RMImageView.h"
#import "RMVideoPlaybackDetailsViewController.h"
#import "RMMyChannelShouldSeeViewController.h"
#import "UMSocial.h"
#import "RMCustomNavViewController.h"
#import "RMCustomPresentNavViewController.h"
#import "RMGenderTabViewController.h"
#import "RefreshControl.h"
#import "CustomRefreshView.h"
#import "RMWebViewPlayViewController.h"
#import "RMModel.h"
#import "RMPlayer.h"


typedef enum{
    usingSinaLogin = 1,
    usingTencentLogin
    
}LoginType;

typedef enum{
    requestMyChannelListType = 1,
    requestLoginType,
    requestDeleteMyChannel
}LoadType;


@interface RMMyChannelViewController ()<UITableViewDataSource,UITableViewDelegate,MyChannemMoreWonderfulDelegate,RMAFNRequestManagerDelegate,UMSocialUIDelegate,RefreshControlDelegate> {
    NSMutableArray * dataArr;
    LoginType loginType;
    LoadType loadType;
    NSString *userName;
    NSMutableString *headImageURLString;
    RMAFNRequestManager *manager;
    NSInteger GetDeleteRow;
    
    NSInteger pageCount;
    NSInteger AltogetherRows;
    BOOL isRefresh;
    BOOL isFirstViewDidAppear;
}
@property (nonatomic, strong) NSString * kLoginStatus;
@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) RefreshControl * refreshControl;

@property (nonatomic, strong) NSArray * btnImgWithTitleArr;
@property (nonatomic, strong) UILabel * tipTitle;
@property (nonatomic, strong) UIView * verticalLine;

@end

@implementation RMMyChannelViewController

#pragma mark - 刷新当前Ctl

- (void)refreshCurrentCtl {
    CUSFileStorage *storage = [CUSFileStorageManager getFileStorage:CURRENTENCRYPTFILE];
    self.kLoginStatus = [AESCrypt decrypt:[storage objectForKey:LoginStatus_KEY] password:PASSWORD];
    if ([self.kLoginStatus isEqualToString:@"islogin"]){
        [self setTitle:@"我的频道"];
        self.moreWonderfulImg.hidden = NO;
        self.moreBgImg.hidden = NO;
        self.moreTitle.hidden = NO;
        self.moreBtn.hidden = NO;
        leftBarButton.hidden = NO;
        rightBarButton.hidden = NO;
        [leftBarButton setBackgroundImage:LOADIMAGE(@"setup", kImageTypePNG) forState:UIControlStateNormal];
        [rightBarButton setBackgroundImage:LOADIMAGE(@"search", kImageTypePNG) forState:UIControlStateNormal];
        self.tableView.hidden = NO;
        pageCount = 1;
        isRefresh = YES;
        [self startRequest];

        self.tipTitle.hidden = YES;
        self.verticalLine.hidden = YES;
        for (int i=0; i<2; i++) {
            ((UIButton *)[self.view viewWithTag:101+i]).hidden = YES;
            ((UILabel *)[self.view viewWithTag:201+i]).hidden = YES;
        }
    }else{
        [self isShouldSetHiddenEmptyView:YES];
        [self setTitle:@"登录"];
        self.moreWonderfulImg.hidden = YES;
        self.moreBgImg.hidden = YES;
        self.moreTitle.hidden = YES;
        self.moreBtn.hidden = YES;
        leftBarButton.hidden = YES;
        rightBarButton.hidden = YES;
        self.tableView.hidden = YES;
        
        self.tipTitle.hidden = NO;
        self.verticalLine.hidden = NO;
        for (int i=0; i<2; i++) {
            ((UIButton *)[self.view viewWithTag:101+i]).hidden = NO;
            ((UILabel *)[self.view viewWithTag:201+i]).hidden = NO;
        }
    }
}

#pragma mark -

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [Flurry logEvent:@"VIEW_MyChannel" timed:YES];
    [self refreshCurrentCtl];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [Flurry endTimedEvent:@"VIEW_MyChannel" withParameters:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    manager = [[RMAFNRequestManager alloc] init];
    manager.delegate = self;
    dataArr = [[NSMutableArray alloc] init];
    self.btnImgWithTitleArr = [[NSArray alloc] initWithObjects:@"logo_weibo", @"txwb", @"新浪微博登录", @"腾讯微博登录", nil];
    [self.moreWonderfulImg addTarget:self WithSelector:@selector(moreWonderfulMethod)];
    
    
    [self setTitle:@"我的频道"];
    [leftBarButton setBackgroundImage:LOADIMAGE(@"setup", kImageTypePNG) forState:UIControlStateNormal];
    [rightBarButton setBackgroundImage:LOADIMAGE(@"search", kImageTypePNG) forState:UIControlStateNormal];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 40, [UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleHeight - 40 - 49 - 44)];
    self.tableView.delegate = self;
    self.tableView.dataSource  =self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.tableView];
    
    self.refreshControl=[[RefreshControl alloc] initWithScrollView:self.tableView delegate:self];
    self.refreshControl.topEnabled=YES;
    self.refreshControl.bottomEnabled=YES;
    [self.refreshControl registerClassForTopView:[CustomRefreshView class]];
    
    self.moreWonderfulImg.hidden = YES;
    self.moreBgImg.hidden = YES;
    self.moreTitle.hidden = YES;
    self.moreBtn.hidden = YES;
    
    [self setTitle:@"登录"];
    
    leftBarButton.hidden = YES;
    rightBarButton.hidden = YES;
    
    self.tipTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth, 50)];
    self.tipTitle.backgroundColor = [UIColor clearColor];
    self.tipTitle.text = [NSString stringWithFormat:@"使用社交账号登录到%@",kAppName];
    self.tipTitle.textAlignment = NSTextAlignmentCenter;
    self.tipTitle.font = [UIFont systemFontOfSize:16.0];
    self.tipTitle.textColor = [UIColor colorWithRed:0.16 green:0.16 blue:0.16 alpha:1];
    [self.view addSubview:self.tipTitle];
    
    self.verticalLine = [[UIView alloc] initWithFrame:CGRectMake([UtilityFunc shareInstance].globleWidth/2-0.5, 50, 1, 50)];
    self.verticalLine.backgroundColor = [UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1];
    [self.view addSubview:self.verticalLine];
    
    for (int i=0; i<2; i++) {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake([UtilityFunc shareInstance].globleWidth/4 * (1-i)+ ([UtilityFunc shareInstance].globleWidth/4)*3*i - i*50, 50, 50, 50);
        [button setBackgroundImage:LOADIMAGE([self.btnImgWithTitleArr objectAtIndex:i], kImageTypePNG) forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonMethod:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = 101+i;
        button.backgroundColor = [UIColor clearColor];
        [self.view addSubview:button];
        
        UILabel * title = [[UILabel alloc] initWithFrame:CGRectMake([UtilityFunc shareInstance].globleWidth/4 * (1-i)+ ([UtilityFunc shareInstance].globleWidth/4)*3*i - i*50 - 15, 100, 100, 40)];
        title.text = [self.btnImgWithTitleArr objectAtIndex:2+i];
        title.textAlignment = NSTextAlignmentLeft;
        title.font = [UIFont systemFontOfSize:14.0];
        title.tag = 201+i;
        title.textColor = [UIColor colorWithRed:0.38 green:0.38 blue:0.38 alpha:1];
        title.backgroundColor = [UIColor clearColor];
        [self.view addSubview:title];
    }
    
    [self refreshCurrentCtl];
}

- (void)startRequest {
    [SVProgressHUD showWithStatus:@"加载中..." maskType:SVProgressHUDMaskTypeClear];
    CUSFileStorage *storage = [CUSFileStorageManager getFileStorage:CURRENTENCRYPTFILE];
    NSDictionary *dict = [storage objectForKey:UserLoginInformation_KEY];
    loadType = requestMyChannelListType;
    [manager getMyChannelVideoListWithToken:[NSString stringWithFormat:@"%@",[dict objectForKey:@"token"]] pageNumber:[NSString stringWithFormat:@"%d",pageCount] count:@"30"];
}

#pragma mark - UITableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.kLoginStatus isEqualToString:@"islogin"]){
        if (dataArr.count == 0){
            [self showEmptyViewWithImage:LOADIMAGE(@"no_cashe_video", kImageTypePNG) WithTitle:@"暂无数据"];
        }else{
            [self isShouldSetHiddenEmptyView:YES];
        }
    }else{
        [self isShouldSetHiddenEmptyView:YES];
    }
    return [dataArr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString * CellIdentifier = [NSString stringWithFormat:@"RMMyChannelCellIdentifier%d",indexPath.row];
    RMMyChannelCell * cell = (RMMyChannelCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (! cell) {
        NSArray *array;
        if (IS_IPHONE_6_SCREEN){
            array= [[NSBundle mainBundle] loadNibNamed:@"RMMyChannelCell_6" owner:self options:nil];
        }else if (IS_IPHONE_6p_SCREEN){
            array= [[NSBundle mainBundle] loadNibNamed:@"RMMyChannelCell_6p" owner:self options:nil];
        }else{
            array = [[NSBundle mainBundle] loadNibNamed:@"RMMyChannelCell" owner:self options:nil];
        }
        cell = [array objectAtIndex:0];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.backgroundColor = [UIColor clearColor];
        cell.delegate = self;
    }
    RMPublicModel *model = [dataArr objectAtIndex:indexPath.row];
    CGFloat width = [UtilityFunc boundingRectWithSize:CGSizeMake(0, 30) font:[UIFont systemFontOfSize:14.0] text:model.name].width;
    cell.tag_title.frame = CGRectMake(10, 0, width + 30, 30);
    cell.title_bgView.frame = CGRectMake(2, 0, width+20, 30);
    cell.tag_title.text = model.name;
    cell.moreBtn.tag = indexPath.row;
    
    if ([model.video_list count] == 0){
        [cell showEmptyView];
    } else if ([model.video_list count] == 1){
        cell.videoFirstName.text = [[model.video_list objectAtIndex:0] objectForKey:@"name"];
        [cell.videoFirstImg sd_setImageWithURL:[NSURL URLWithString:[[model.video_list objectAtIndex:0] objectForKey:@"pic"]] placeholderImage:LOADIMAGE(@"Default90_135", kImageTypePNG)];
        [cell.firstMovieRateView setImagesDeselected:@"mx_rateEmpty_img" partlySelected:@"mx_rateEmpty_img" fullSelected:@"mx_rateFull_img" andDelegate:nil];
        [cell.firstMovieRateView displayRating:[[[model.video_list objectAtIndex:0] objectForKey:@"gold"] integerValue]];
        [cell.fristDirectlyPlay setImage:[UIImage imageNamed:@"play_btn"] forState:UIControlStateNormal];
        cell.fristDirectlyPlay.tag = indexPath.row;
        cell.secondDirectlyPlay.hidden = YES;
        cell.thridDirectlyPlay.hidden = YES;
        cell.videoFirstImg.identifierString = [[model.video_list objectAtIndex:0] objectForKey:@"video_id"];
    }else if ([model.video_list count] == 2){
        cell.videoFirstName.text = [[model.video_list objectAtIndex:0] objectForKey:@"name"];
        [cell.videoFirstImg sd_setImageWithURL:[NSURL URLWithString:[[model.video_list objectAtIndex:0] objectForKey:@"pic"]] placeholderImage:LOADIMAGE(@"Default90_135", kImageTypePNG)];
        [cell.firstMovieRateView setImagesDeselected:@"mx_rateEmpty_img" partlySelected:@"mx_rateEmpty_img" fullSelected:@"mx_rateFull_img" andDelegate:nil];
        [cell.firstMovieRateView displayRating:[[[model.video_list objectAtIndex:0] objectForKey:@"gold"] integerValue]];
        [cell.fristDirectlyPlay setImage:[UIImage imageNamed:@"play_btn"] forState:UIControlStateNormal];
        cell.fristDirectlyPlay.tag = indexPath.row;
        cell.videoFirstImg.identifierString = [[model.video_list objectAtIndex:0] objectForKey:@"video_id"];
        
        cell.videoSecondName.text = [[model.video_list objectAtIndex:1] objectForKey:@"name"];
        [cell.videoSecondImg sd_setImageWithURL:[NSURL URLWithString:[[model.video_list objectAtIndex:1] objectForKey:@"pic"]] placeholderImage:LOADIMAGE(@"Default90_135", kImageTypePNG)];
        [cell.secondMovieRateView setImagesDeselected:@"mx_rateEmpty_img" partlySelected:@"mx_rateEmpty_img" fullSelected:@"mx_rateFull_img" andDelegate:nil];
        [cell.secondMovieRateView displayRating:[[[model.video_list objectAtIndex:1] objectForKey:@"gold"] integerValue]];
        [cell.secondDirectlyPlay setImage:[UIImage imageNamed:@"play_btn"] forState:UIControlStateNormal];
        cell.secondDirectlyPlay.tag = indexPath.row;
        cell.thridDirectlyPlay.hidden = YES;
        cell.videoSecondImg.identifierString = [[model.video_list objectAtIndex:1] objectForKey:@"video_id"];
    }else if ([model.video_list count] == 3){
        cell.videoFirstName.text = [[model.video_list objectAtIndex:0] objectForKey:@"name"];
        [cell.videoFirstImg sd_setImageWithURL:[NSURL URLWithString:[[model.video_list objectAtIndex:0] objectForKey:@"pic"]] placeholderImage:LOADIMAGE(@"Default90_135", kImageTypePNG)];
        [cell.firstMovieRateView setImagesDeselected:@"mx_rateEmpty_img" partlySelected:@"mx_rateEmpty_img" fullSelected:@"mx_rateFull_img" andDelegate:nil];
        [cell.firstMovieRateView displayRating:[[[model.video_list objectAtIndex:0] objectForKey:@"gold"] integerValue]];
        [cell.fristDirectlyPlay setImage:[UIImage imageNamed:@"play_btn"] forState:UIControlStateNormal];
        cell.fristDirectlyPlay.tag = indexPath.row;
        cell.videoFirstImg.identifierString = [[model.video_list objectAtIndex:0] objectForKey:@"video_id"];

        cell.videoSecondName.text = [[model.video_list objectAtIndex:1] objectForKey:@"name"];
        [cell.videoSecondImg sd_setImageWithURL:[NSURL URLWithString:[[model.video_list objectAtIndex:1] objectForKey:@"pic"]] placeholderImage:LOADIMAGE(@"Default90_135", kImageTypePNG)];
        [cell.secondMovieRateView setImagesDeselected:@"mx_rateEmpty_img" partlySelected:@"mx_rateEmpty_img" fullSelected:@"mx_rateFull_img" andDelegate:nil];
        [cell.secondMovieRateView displayRating:[[[model.video_list objectAtIndex:1] objectForKey:@"gold"] integerValue]];
        [cell.secondDirectlyPlay setImage:[UIImage imageNamed:@"play_btn"] forState:UIControlStateNormal];
        cell.secondDirectlyPlay.tag = indexPath.row;
        cell.videoSecondImg.identifierString = [[model.video_list objectAtIndex:1] objectForKey:@"video_id"];
        
        cell.videoThirdName.text = [[model.video_list objectAtIndex:2] objectForKey:@"name"];
        [cell.videoThirdImg sd_setImageWithURL:[NSURL URLWithString:[[model.video_list objectAtIndex:2] objectForKey:@"pic"]] placeholderImage:LOADIMAGE(@"Default90_135", kImageTypePNG)];
        [cell.thirdMovieRateView setImagesDeselected:@"mx_rateEmpty_img" partlySelected:@"mx_rateEmpty_img" fullSelected:@"mx_rateFull_img" andDelegate:nil];
        [cell.thirdMovieRateView displayRating:[[[model.video_list objectAtIndex:2] objectForKey:@"gold"] integerValue]];
        [cell.thridDirectlyPlay setImage:[UIImage imageNamed:@"play_btn"] forState:UIControlStateNormal];
        cell.thridDirectlyPlay.tag = indexPath.row;
        cell.videoThirdImg.identifierString = [[model.video_list objectAtIndex:2] objectForKey:@"video_id"];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (IS_IPHONE_6_SCREEN){
        return 245;
    }else if (IS_IPHONE_6p_SCREEN){
        return 260;
    }else{
        return 240;
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    RMPublicModel *model = [dataArr objectAtIndex:indexPath.row];
    CUSFileStorage *storage = [CUSFileStorageManager getFileStorage:CURRENTENCRYPTFILE];
    NSDictionary *dict = [storage objectForKey:UserLoginInformation_KEY];
    loadType = requestDeleteMyChannel;
    GetDeleteRow = indexPath.row;
    manager.delegate = self;
    [manager getDeleteMyChannelWithTag:model.tag_id WithToken:[NSString stringWithFormat:@"%@",[dict objectForKey:@"token"]]];
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}

#pragma mark - RMImageView Method

- (void)moreWonderfulMethod {
    RMMoreWonderfulViewController * moreWonderfulCtl = [[RMMoreWonderfulViewController alloc] init];
    [self.navigationController pushViewController:moreWonderfulCtl animated:YES];
    [moreWonderfulCtl setupNavTitle:@"更多精彩" SwitchingBarButtonDirection:@"left"];
    [[NSNotificationCenter defaultCenter] postNotificationName:kHideTabbar object:nil];
}

#pragma mark - Base Method

- (void)navgationBarButtonClick:(UIBarButtonItem *)sender {
    switch (sender.tag) {
        case 1:{
            RMSetupViewController * setupCtl = [[RMSetupViewController alloc] init];
            [self presentViewController:[[RMCustomPresentNavViewController alloc] initWithRootViewController:setupCtl] animated:YES completion:^{
                
            }];
            [[NSNotificationCenter defaultCenter] postNotificationName:kHideTabbar object:nil];
            break;
        }
        case 2:{
            RMSearchViewController * searchCtl = [[RMSearchViewController alloc] init];
            
            [self presentViewController:[[RMCustomPresentNavViewController alloc] initWithRootViewController:searchCtl] animated:YES completion:^{
                
            }];
            [[NSNotificationCenter defaultCenter] postNotificationName:kHideTabbar object:nil];
            break;
        }
            
        default:
            break;
    }
}

- (void)startCellDidSelectWithIndex:(NSInteger)index {
    RMPublicModel *model = [dataArr objectAtIndex:index];
    RMMyChannelShouldSeeViewController * myChannelShouldSeeCtl = [[RMMyChannelShouldSeeViewController alloc] init];
    myChannelShouldSeeCtl.titleString = model.name;
    myChannelShouldSeeCtl.downLoadID = model.tag_id;
    [self.navigationController pushViewController:myChannelShouldSeeCtl animated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:kHideTabbar object:nil];
    myChannelShouldSeeCtl.title = model.name;
}

- (void)clickVideoImageViewMehtod:(RMImageView *)imageView {
    if (imageView.identifierString){
        RMVideoPlaybackDetailsViewController * videoPlaybackDetailsCtl = [[RMVideoPlaybackDetailsViewController alloc] init];
        [self.navigationController pushViewController:videoPlaybackDetailsCtl animated:YES];
        [videoPlaybackDetailsCtl setAppearTabBarNextPopViewController:kYES];
        videoPlaybackDetailsCtl.currentVideo_id = imageView.identifierString;
        [[NSNotificationCenter defaultCenter] postNotificationName:kHideTabbar object:nil];
    }
}

#pragma mark - 直接播放

- (void)playBtnWithIndex:(NSInteger)index andLocation:(NSInteger)location{
    RMPublicModel *model = [dataArr objectAtIndex:index];
    if([[[model.video_list objectAtIndex:location] objectForKey:@"video_type"] isEqualToString:@"1"]){//电影
        if([[[[model.video_list objectAtIndex:location] objectForKey:@"urls"] objectForKey:@"m_down_url"] isEqualToString:@""] || [[[model.video_list objectAtIndex:location] objectForKey:@"urls"] objectForKey:@"m_down_url"] == nil){
            if([[[[model.video_list objectAtIndex:location] objectForKey:@"urls"] objectForKey:@"jumpurl"] isEqualToString:@""] || [[[model.video_list objectAtIndex:location] objectForKey:@"urls"] objectForKey:@"jumpurl"] == nil){
                [SVProgressHUD showErrorWithStatus:@"暂时不能播放该视频"];
                return;
            }
            //跳转web
            //保存数据sqlit
            RMPublicModel *insertModel = [[RMPublicModel alloc] init];
            insertModel.name = [[model.video_list objectAtIndex:location] objectForKey:@"name"];
            insertModel.pic_url = [[model.video_list objectAtIndex:location] objectForKey:@"pic"];
            insertModel.jumpurl = [[[model.video_list objectAtIndex:location] objectForKey:@"urls"] objectForKey:@"jumpurl"];
            insertModel.playTime = @"0";
            insertModel.video_id = [[model.video_list objectAtIndex:location] objectForKey:@"video_id"];
            [[Database sharedDatabase] insertProvinceItem:insertModel andListName:PLAYHISTORYLISTNAME];
            RMWebViewPlayViewController *webView = [[RMWebViewPlayViewController alloc] init];
            RMCustomPresentNavViewController * webNav = [[RMCustomPresentNavViewController alloc] initWithRootViewController:webView];
            webView.urlString = [[[model.video_list objectAtIndex:location] objectForKey:@"urls"] objectForKey:@"jumpurl"];
            [self presentViewController:webNav animated:YES completion:^{
            }];
        }else{
            //使用custom play 播放mp4
            //保存数据sqlit
            RMPublicModel *insertModel = [[RMPublicModel alloc] init];
            insertModel.name = [[model.video_list objectAtIndex:location] objectForKey:@"name"];
            insertModel.pic_url = [[model.video_list objectAtIndex:location] objectForKey:@"pic"];
            insertModel.reurl = [[[model.video_list objectAtIndex:location] objectForKey:@"urls"] objectForKey:@"m_down_url"];
            insertModel.playTime = @"0";
            insertModel.video_id = [[model.video_list objectAtIndex:location] objectForKey:@"video_id"];
            [[Database sharedDatabase] insertProvinceItem:insertModel andListName:PLAYHISTORYLISTNAME];
            //电影
            RMModel * playmodel = [[RMModel alloc] init];
            playmodel.url = [[[model.video_list objectAtIndex:location] objectForKey:@"urls"] objectForKey:@"m_down_url"];
            playmodel.title = [[model.video_list objectAtIndex:location] objectForKey:@"name"];
            [RMPlayer presentVideoPlayerWithPlayModel:playmodel withUIViewController:self withVideoType:1];
        }
    }else{//电视剧 综艺
        if([[[[[model.video_list objectAtIndex:location] objectForKey:@"urls"] objectAtIndex:0] objectForKey:@"m_down_url"] isEqualToString:@""] || [[[[model.video_list objectAtIndex:location] objectForKey:@"urls"] objectAtIndex:0] objectForKey:@"m_down_url"] == nil){
            if([[[[[model.video_list objectAtIndex:location] objectForKey:@"urls"] objectAtIndex:0] objectForKey:@"jumpurl"] isEqualToString:@""] || [[[[model.video_list objectAtIndex:location] objectForKey:@"urls"] objectAtIndex:0] objectForKey:@"jumpurl"] == nil){
                [SVProgressHUD showErrorWithStatus:@"暂时不能播放该视频"];
                return;
            }
            //跳转web
            //保存数据sqlit
            RMPublicModel *insertModel = [[RMPublicModel alloc] init];
            insertModel.name = [[model.video_list objectAtIndex:location] objectForKey:@"name"];
            insertModel.pic_url = [[model.video_list objectAtIndex:location] objectForKey:@"pic"];
            insertModel.jumpurl = [[[[model.video_list objectAtIndex:location] objectForKey:@"urls"] objectAtIndex:0] objectForKey:@"jumpurl"];
            insertModel.playTime = @"0";
            insertModel.video_id = [[model.video_list objectAtIndex:location] objectForKey:@"video_id"];
            [[Database sharedDatabase] insertProvinceItem:insertModel andListName:PLAYHISTORYLISTNAME];
            RMWebViewPlayViewController *webView = [[RMWebViewPlayViewController alloc] init];
            RMCustomPresentNavViewController * webNav = [[RMCustomPresentNavViewController alloc] initWithRootViewController:webView];
            webView.urlString = [[[[model.video_list objectAtIndex:location] objectForKey:@"urls"] objectAtIndex:0] objectForKey:@"jumpurl"];
            [self presentViewController:webNav animated:YES completion:^{
            }];
        }else{
            //使用custom play 播放mp4
            //保存数据sqlit
            RMPublicModel *insertModel = [[RMPublicModel alloc] init];
            insertModel.name = [[model.video_list objectAtIndex:location] objectForKey:@"name"];
            insertModel.pic_url = [[model.video_list objectAtIndex:location] objectForKey:@"pic"];
            insertModel.reurl = [[[[model.video_list objectAtIndex:location] objectForKey:@"urls"] objectAtIndex:0] objectForKey:@"m_down_url"];
            insertModel.playTime = @"0";
            insertModel.video_id = [[model.video_list objectAtIndex:location] objectForKey:@"video_id"];
            [[Database sharedDatabase] insertProvinceItem:insertModel andListName:PLAYHISTORYLISTNAME];
            
            NSMutableArray * arr = [[NSMutableArray alloc] init];
            for (int i=0; i<[[[model.video_list objectAtIndex:location] objectForKey:@"urls"] count]; i++) {
                RMModel * playmodel = [[RMModel alloc] init];
                playmodel.url = [[[[model.video_list objectAtIndex:location] objectForKey:@"urls"] objectAtIndex:i] objectForKey:@"m_down_url"];
                playmodel.title = [[model.video_list objectAtIndex:location] objectForKey:@"name"];
                playmodel.EpisodeValue = [[[[model.video_list objectAtIndex:location] objectForKey:@"urls"] objectAtIndex:i] objectForKey:@"order"];
                [arr addObject:playmodel];
            }
            [RMPlayer presentVideoPlayerWithPlayArray:arr withUIViewController:self withVideoType:2];
        }
    }
}

- (IBAction)mbuttonClick:(UIButton *)sender {
    [self moreWonderfulMethod];
}

- (void)buttonMethod:(UIButton *)sender {
    switch (sender.tag) {
        case 101:{
            CUSFileStorage *storage = [CUSFileStorageManager getFileStorage:CURRENTENCRYPTFILE];
            NSString * loginStatus = [AESCrypt decrypt:[storage objectForKey:LoginStatus_KEY] password:PASSWORD];
            loginType = usingSinaLogin;
            BOOL isOauth = [UMSocialAccountManager isOauthAndTokenNotExpired:UMShareToSina];
            if(isOauth){
                if([loginStatus isEqualToString: @"islogin"]){
                    [self showAlertView];
                }else{
                    NSDictionary *snsAccountDic = [UMSocialAccountManager socialAccountDictionary];
                    UMSocialAccountEntity *sinaAccount = [snsAccountDic valueForKey:UMShareToSina];
                    userName = sinaAccount.userName;
                    headImageURLString = [NSMutableString stringWithFormat:@"%@",sinaAccount.iconURL];
                    [SVProgressHUD showWithStatus:@"登录中" maskType:SVProgressHUDMaskTypeClear];
                    loadType = requestLoginType;
                    [manager postLoginWithSourceType:@"4" sourceId:sinaAccount.usid username:[sinaAccount.userName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] headImageURL:[headImageURLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                }
            }
            else{
                UINavigationController *oauthController = [[UMSocialControllerService defaultControllerService] getSocialOauthController:UMShareToSina];
                [self presentViewController:oauthController animated:YES completion:nil];
            }
            [UMSocialControllerService defaultControllerService].socialUIDelegate = self;

            break;
        }
        case 102:{
            CUSFileStorage *storage = [CUSFileStorageManager getFileStorage:CURRENTENCRYPTFILE];
            NSString * loginStatus = [AESCrypt decrypt:[storage objectForKey:LoginStatus_KEY] password:PASSWORD];
            
            loginType = usingTencentLogin;
            BOOL isOauth = [UMSocialAccountManager isOauthAndTokenNotExpired:UMShareToTencent];
            if(isOauth){
                if([loginStatus isEqualToString: @"islogin"]){
                    [self showAlertView];
                }else{
                    NSDictionary *snsAccountDic = [UMSocialAccountManager socialAccountDictionary];
                    UMSocialAccountEntity *tencentAccount = [snsAccountDic valueForKey:UMShareToTencent];
                    userName = tencentAccount.userName;
                    headImageURLString = [NSMutableString stringWithFormat:@"%@",tencentAccount.iconURL];
                    [SVProgressHUD showWithStatus:@"登录中" maskType:SVProgressHUDMaskTypeClear];
                    loadType = requestLoginType;
                    [manager postLoginWithSourceType:@"2" sourceId:tencentAccount.usid username:[tencentAccount.userName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] headImageURL:[headImageURLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                }
            }
            else{
                UINavigationController *oauthController = [[UMSocialControllerService defaultControllerService] getSocialOauthController:UMShareToTencent];
                [self presentViewController:oauthController animated:YES completion:nil];
            }
            [UMSocialControllerService defaultControllerService].socialUIDelegate = self;

            break;
        }
            
        default:
            break;
    }
}

- (void)showAlertView{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"该登陆方式已经登录成功了" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
    [alertView show];
}

- (void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];
    }
    //授权成功后的回调函数
    if (response.viewControllerType == UMSViewControllerOauth) {
        NSDictionary *snsAccountDic = [UMSocialAccountManager socialAccountDictionary];
        if(loginType == usingTencentLogin){
            BOOL isOauth = [UMSocialAccountManager isOauthAndTokenNotExpired:UMShareToTencent];
            if(isOauth){
                UMSocialAccountEntity *tencentAccount = [snsAccountDic valueForKey:UMShareToTencent];
                userName = tencentAccount.userName;
                headImageURLString = [NSMutableString stringWithFormat:@"%@",tencentAccount.iconURL];
                [SVProgressHUD showWithStatus:@"登录中" maskType:SVProgressHUDMaskTypeClear];
                loadType = requestLoginType;
                [manager postLoginWithSourceType:@"2" sourceId:tencentAccount.usid username:[tencentAccount.userName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] headImageURL:[headImageURLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            }
        }else if ( loginType == usingSinaLogin){
            BOOL isOauth = [UMSocialAccountManager isOauthAndTokenNotExpired:UMShareToSina];
            if(isOauth){
                UMSocialAccountEntity *sinaAccount = [snsAccountDic valueForKey:UMShareToSina];
                userName = sinaAccount.userName;
                headImageURLString = [NSMutableString stringWithFormat:@"%@",sinaAccount.iconURL];
                [SVProgressHUD showWithStatus:@"登录中" maskType:SVProgressHUDMaskTypeClear];
                loadType = requestLoginType;
                [manager postLoginWithSourceType:@"4" sourceId:sinaAccount.usid username:[sinaAccount.userName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] headImageURL:[headImageURLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            }
        }
    }
}

#pragma mark 刷新代理

- (void)refreshControl:(RefreshControl *)refreshControl didEngageRefreshDirection:(RefreshDirection)direction {
    if (direction == RefreshDirectionTop) { //下拉刷新
        isRefresh = YES;
        pageCount = 1;
        [self startRequest];
    }else if(direction == RefreshDirectionBottom) { //上拉加载
        if (pageCount * 30 > AltogetherRows){
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.44 * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [SVProgressHUD showSuccessWithStatus:@"没有更多内容了" duration:1.0];
                [self.refreshControl finishRefreshingDirection:RefreshDirectionBottom];
            });
        }else{
            pageCount ++;
            isRefresh = NO;
            [self startRequest];
        }
    }
}

#pragma mark - request RMAFNRequestManagerDelegate

- (void)requestFinishiDownLoadWith:(NSMutableArray *)data {
    if (loadType == requestMyChannelListType){
        if (self.refreshControl.refreshingDirection==RefreshingDirectionTop) {
            RMPublicModel * model = [data objectAtIndex:0];
            AltogetherRows = [model.rows integerValue];
            dataArr = data;
            [self.tableView reloadData];
            [self.refreshControl finishRefreshingDirection:RefreshDirectionTop];
        }else if(self.refreshControl.refreshingDirection==RefreshingDirectionBottom) {
            if (data.count == 0){
                [SVProgressHUD showSuccessWithStatus:@"没有更多内容了" duration:1.0];
                [self.refreshControl finishRefreshingDirection:RefreshDirectionBottom];
                return;
            }
            RMPublicModel * model = [data objectAtIndex:0];
            AltogetherRows = [model.rows integerValue];
            for (int i=0; i<data.count; i++) {
                RMPublicModel * model = [data objectAtIndex:i];
                [dataArr addObject:model];
            }
            [self.tableView reloadData];
            [self.refreshControl finishRefreshingDirection:RefreshDirectionBottom];
        }
        
        if (isRefresh){
            RMPublicModel * model = [data objectAtIndex:0];
            AltogetherRows = [model.rows integerValue];
            dataArr = data;
            [self.tableView reloadData];
        }
        [SVProgressHUD dismiss];
    }else if (loadType == requestLoginType){
        RMPublicModel * model = [data objectAtIndex:0];
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setValue:userName forKey:@"userName"];
        [dict setValue:headImageURLString forKey:@"HeadImageURL"];
        [dict setValue:model.token forKey:@"token"];
        CUSFileStorage *storage = [CUSFileStorageManager getFileStorage:CURRENTENCRYPTFILE];
        [storage beginUpdates];
        NSString * loginStatus = [AESCrypt encrypt:@"islogin" password:PASSWORD];
        [storage setObject:dict forKey:UserLoginInformation_KEY];
        [storage setObject:loginStatus forKey:LoginStatus_KEY];
        [storage endUpdates];
        [SVProgressHUD dismiss];
        [self refreshCurrentCtl];
        if ([model.status integerValue] == 1){ //没有登录过  push 获取用户信息界面
            RMGenderTabViewController *viewContro = [[RMGenderTabViewController alloc] init];
            viewContro.viewControlerrIdentify = @"MyChannelCtl";
            [self.navigationController pushViewController:viewContro animated:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:kHideTabbar object:nil];
        }else{ //登录过 拉取精彩推荐内容
            [self performSelector:@selector(myChannelLoginSuccessRecommendmethod) withObject:nil afterDelay:0.44];
        }
    }else if (loadType == requestDeleteMyChannel){
        [dataArr removeObjectAtIndex:GetDeleteRow];
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:GetDeleteRow inSection:0];
        NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
        [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)requestError:(NSError *)error {
    NSLog(@"error:%@",error);
}

#pragma mark - 登录后即推荐

- (void)myChannelLoginSuccessRecommendmethod{
    [[NSNotificationCenter defaultCenter] postNotificationName:kAppearTabbar object:nil];
    RMMoreWonderfulViewController * moreWonderfulCtl = [[RMMoreWonderfulViewController alloc] init];
    RMCustomPresentNavViewController * moreWonderfulNav = [[RMCustomPresentNavViewController alloc] initWithRootViewController:moreWonderfulCtl];
    [self presentViewController:moreWonderfulNav animated:YES completion:^{
    }];
    [moreWonderfulCtl setupNavTitle:@"你可能喜欢的内容" SwitchingBarButtonDirection:@"right"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
