//
//  RMRecommendedDailyViewController.m
//  RMVideo
//
//  Created by 润华联动 on 14-10-13.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMRecommendedDailyViewController.h"
#import "RMSetupViewController.h"
#import "RMSearchViewController.h"
#import "RMVideoPlaybackDetailsViewController.h"
#import "AFSoundManager.h"
#import "SDiPhoneVersion.h"
#import "RMCustomNavViewController.h"
#import "RMCustomPresentNavViewController.h"
#import "RMWebViewPlayViewController.h"
#import "RMModel.h"
#import "RMPlayer.h"

@interface RMRecommendedDailyViewController (){
    UIImageView * splashView;
}

@end

@implementation RMRecommendedDailyViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [Flurry logEvent:@"VIEW_ToDayRecommended" timed:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [Flurry endTimedEvent:@"VIEW_ToDayRecommended" withParameters:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1];
    [leftBarButton setImage:LOADIMAGE(@"setup", kImageTypePNG) forState:UIControlStateNormal];
    [rightBarButton setImage:LOADIMAGE(@"search", kImageTypePNG) forState:UIControlStateNormal];
    CellScrollimageArray = [[NSMutableArray alloc] init];
    cellHeadImageArray = [NSArray arrayWithObjects:@"jr_movie",@"jr_teleplay",@"jr_Variety", nil];
    self.title = @"今日推荐";
    cellHeadStringArray = [NSArray arrayWithObjects:@"电影",@"电视剧",@"综艺", nil];
    
    mainTableVeiew = [[PullToRefreshTableView alloc] initWithFrame:CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleHeight-49-44)];
    mainTableVeiew.backgroundColor = [UIColor clearColor];
    mainTableVeiew.delegate = self;
    mainTableVeiew.dataSource = self;
    mainTableVeiew.separatorStyle = UITableViewCellSeparatorStyleNone;
    [mainTableVeiew setIsCloseFooter:YES];
    [mainTableVeiew setTableViewFootNil];
    [self.view addSubview:mainTableVeiew];
    
    [SVProgressHUD showWithStatus:@"下载中" maskType:SVProgressHUDMaskTypeBlack];
    RMAFNRequestManager *manager = [[RMAFNRequestManager alloc] init];
    manager.delegate = self;
    [manager getDailyRecommend];
    
}

#pragma mark main tableVeiw dataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataArray.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellName = @"RecommendedDaily";
    RMRecommendedDailyTableViewCell *cell = [mainTableVeiew dequeueReusableCellWithIdentifier:cellName];
    if(cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"RMRecommendedDailyTableViewCell" owner:self options:nil] lastObject];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.headImageView.image = NULL;
    cell.headImageView.image = [UIImage imageNamed:[cellHeadImageArray objectAtIndex:indexPath.row]];
    NSMutableArray *cellImage = [NSMutableArray array];
    for(RMPublicModel *model in [[dataArray objectAtIndex:indexPath.row] objectForKey:[cellHeadStringArray objectAtIndex:indexPath.row]]){
        [cellImage addObject:model.DailyRecommendPic];
    }
    [cell cellAddMovieCountFromDataArray:cellImage andCellIdentifiersName:[cellHeadStringArray objectAtIndex:indexPath.row]];
    cell.delegate = self;

    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(IS_IPHONE_4_SCREEN){
        return 332;
    }else if (IS_IPHONE_5_SCREEN){
        return 365;
    }else if (IS_IPHONE_6_SCREEN){
        return 460;
    }else if (IS_IPHONE_6p_SCREEN){
        return 502;
    }
    return 0;
}
#pragma mark -
#pragma mark Scroll View Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [mainTableVeiew tableViewDidDragging];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"tableViewDidEndDecelerating" object:nil];
    NSInteger returnKey = [mainTableVeiew tableViewDidEndDragging];
    
    //  returnKey用来判断执行的拖动是下拉还是上拖
    //  如果数据正在加载，则回返DO_NOTHING
    //  如果是下拉，则返回k_RETURN_REFRESH
    //  如果是上拖，则返回k_RETURN_LOADMORE
    //  相应的Key宏定义也封装在PullToRefreshTableView中
    //  根据返回的值，您可以自己写您的数据改变方式
    
    if (returnKey != k_RETURN_DO_NOTHING) {
        //  这里执行方法
        NSString * key = [NSString stringWithFormat:@"%lu", (long)returnKey];
        [NSThread detachNewThreadSelector:@selector(updateThread:) toTarget:self withObject:key];
    }
}

- (void)updateThread:(id)sender {
    int index = [sender intValue];
    switch (index) {
        case k_RETURN_DO_NOTHING://不执行操作
        {
            
        }
            break;
        case k_RETURN_REFRESH://刷新
        {
            [SVProgressHUD showWithStatus:@"下载中" maskType:SVProgressHUDMaskTypeBlack];
            RMAFNRequestManager *manager = [[RMAFNRequestManager alloc] init];
            manager.delegate = self;
            [manager getDailyRecommend];
        }
            break;
        case k_RETURN_LOADMORE://加载更多
        {
            
        }
            break;
            
        default:
            break;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"tableViewWillBeginDragging" object:nil];
}

#pragma mark cell Image点击事件 tag标识每个cell的位置 identifier标识cell

- (void)didSelectCellImageWithTag:(NSInteger)tag andImageViewIdentifier:(NSString *)identifier{
    NSString *movieID ;
    for(NSDictionary *dict in dataArray){
        NSMutableArray *array = [dict objectForKey:identifier];
        if(array){
            RMPublicModel *model = [array objectAtIndex:tag];
            movieID = model.DailyRecommendVideo_id;
        }
    }

    RMVideoPlaybackDetailsViewController *videoPlay = [[RMVideoPlaybackDetailsViewController alloc] init];
    videoPlay.tabBarIdentifier = kYES;
    videoPlay.currentVideo_id = movieID;
    [self.navigationController pushViewController:videoPlay animated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:kHideTabbar object:nil];
}
- (void)clickDirectlyPlayBtnWithTag:(NSInteger)tag andtypeIdentifier:(NSString *)identifier{
    
    for(NSDictionary *dict in dataArray){
        NSMutableArray *array = [dict objectForKey:identifier];
        if(array.count>0){
            RMPublicModel *model = [array objectAtIndex:tag];
            NSLog(@"jump:%@  playUrl:%@",model.jumpurl,model.downLoadURL);
            if([model.downLoadURL isEqualToString:@""]||model.downLoadURL== nil){
                if([model.jumpurl isEqualToString:@""]||model.jumpurl==nil){
                    [SVProgressHUD showErrorWithStatus:@"暂时不能播放该视频"];
                    return;
                }
                //跳转web
                //保存数据sqlit
                RMPublicModel *insertModel = [[RMPublicModel alloc] init];
                insertModel.name = model.name;
                insertModel.pic_url = model.pic;
                insertModel.jumpurl = model.jumpurl;
                insertModel.playTime = @"0";
                insertModel.video_id = model.video_id;
                [[Database sharedDatabase] insertProvinceItem:insertModel andListName:PLAYHISTORYLISTNAME];
                RMWebViewPlayViewController *webView = [[RMWebViewPlayViewController alloc] init];
                RMCustomPresentNavViewController * webNav = [[RMCustomPresentNavViewController alloc] initWithRootViewController:webView];
                webView.urlString = model.jumpurl;
                [self presentViewController:webNav animated:YES completion:^{
                }];
            }
            else{
                //使用custom play 播放mp4
                //保存数据sqlit
                RMPublicModel *insertModel = [[RMPublicModel alloc] init];
                insertModel.name = model.name;
                insertModel.pic_url = model.pic;
                insertModel.reurl = model.downLoadURL;
                insertModel.playTime = @"0";
                insertModel.video_id = model.video_id;
                [[Database sharedDatabase] insertProvinceItem:insertModel andListName:PLAYHISTORYLISTNAME];
                //电影
                RMModel * playmodel = [[RMModel alloc] init];
                playmodel.url = model.downLoadURL;
                playmodel.title = model.name;
                [RMPlayer presentVideoPlayerWithPlayModel:playmodel withUIViewController:self withVideoType:1];
            }
        }
    }
    
}

#pragma mark - Base Method

- (void)navgationBarButtonClick:(UIBarButtonItem *)sender{
    switch (sender.tag) {
        case 1:{
            RMSetupViewController * setupCtl = [[RMSetupViewController alloc] init];
            RMCustomPresentNavViewController * setupNav = [[RMCustomPresentNavViewController alloc] initWithRootViewController:setupCtl];
            [self presentViewController:setupNav animated:YES completion:^{
                
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

- (void)requestFinishiDownLoadWith:(NSMutableArray *)data{
    dataArray = data;
    [mainTableVeiew reloadData];
    [SVProgressHUD dismiss];
    [mainTableVeiew reloadData:NO];
}

- (void)requestError:(NSError *)error{
    [mainTableVeiew reloadData:NO];
}

#pragma mark - Animation 广告展示页面
/**
 启动完成后的广告展示页面
 
 添加网络请求 刷新 splashView
 */
- (void)AnimationForWindowHidden {
    splashView = [[UIImageView alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    //视觉过渡
    if (IS_IPHONE_5_SCREEN){
        splashView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Default-568h" ofType:@"png"]];
    }else{
        splashView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Default" ofType:@"png"]];
    }
    
    splashView.backgroundColor = [UIColor clearColor];
    splashView.contentMode = UIViewContentModeScaleAspectFill;
    
    UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    [window addSubview:splashView];
    [window bringSubviewToFront:splashView];
    self.view.userInteractionEnabled = NO;
    
    
    [self performSelector:@selector(hiddenA) withObject:nil afterDelay:3];
}

- (void)hiddenA {
    [[AFSoundManager sharedManager] startPlayingLocalFileWithName:@"loading.wav" andBlock:^(int percentage, CGFloat elapsedTime, CGFloat timeRemaining, NSError *error, BOOL finished) {
    }];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:3.2];
    [UIView setAnimationTransition:UIViewAnimationTransitionNone forView: self.navigationController.view cache:YES];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animateStop)];
    splashView.alpha = 0.0;
    if (!IS_IPHONE_5_SCREEN){
        splashView.frame = CGRectMake(-60, -85, 440, 635);
    }else{
        splashView.frame = CGRectMake(-60, -85, 440, 735);
    }
    [UIView commitAnimations];
    self.view.userInteractionEnabled = YES;
}

- (void)animateStop {
    [[AFSoundManager sharedManager] stop];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
