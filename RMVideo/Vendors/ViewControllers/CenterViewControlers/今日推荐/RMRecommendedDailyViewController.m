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


@interface RMRecommendedDailyViewController (){
    UIImageView * splashView;
}

@end

@implementation RMRecommendedDailyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1];
    
    [leftBarButton setImage:[UIImage imageNamed:@"setup"] forState:UIControlStateNormal];
    [rightBarButton setImage:[UIImage imageNamed:@"search"] forState:UIControlStateNormal];
    CellScrollimageArray = [[NSMutableArray alloc] init];
    cellHeadImageArray = [NSArray arrayWithObjects:@"jr_movie",@"jr_teleplay",@"jr_Variety", nil];
    self.title = @"今日推荐";
    cellHeadStringArray = [NSArray arrayWithObjects:@"电影",@"电视剧",@"综艺", nil];
    
    mainTableVeiew = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleHeight-49-44) style:UITableViewStylePlain];
    mainTableVeiew.backgroundColor = [UIColor clearColor];
    mainTableVeiew.delegate = self;
    mainTableVeiew.dataSource = self;
    mainTableVeiew.separatorStyle = UITableViewCellSeparatorStyleNone;
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
        return 375;
    }else if (IS_IPHONE_6_SCREEN){
        return 460;
    }else if (IS_IPHONE_6p_SCREEN){
        return 502;
    }
    return 0;
}
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"tableViewDidEndDecelerating" object:nil];
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"tableViewWillBeginDragging" object:nil];
}
#pragma mark cell Image点击事件 tag标识每个cell的位置 identifier标识cell
- (void)didSelectCellImageWithTag:(NSInteger)tag andImageViewIdentifier:(NSString *)identifier{
    NSLog(@"tag:%d identifier:%@",tag,identifier);
    NSString *movieID ;
    for(NSDictionary *dict in dataArray){
        NSMutableArray *array = [dict objectForKey:identifier];
        if(array){
            RMPublicModel *model = [array objectAtIndex:tag];
            movieID = model.DailyRecommendVideo_id;
        }
    }
    if ([identifier isEqualToString:@"电影"]) {
    }
    else if ([identifier isEqualToString:@"电视剧"]) {

    }else{
        
    }
    RMVideoPlaybackDetailsViewController *videoPlay = [[RMVideoPlaybackDetailsViewController alloc] init];
    videoPlay.tabBarIdentifier = kYES;
    [self.navigationController pushViewController:videoPlay animated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:kHideTabbar object:nil];
}

#pragma mark - Base Method

- (void)navgationBarButtonClick:(UIBarButtonItem *)sender{
    switch (sender.tag) {
        case 1:{
            RMSetupViewController * setupCtl = [[RMSetupViewController alloc] init];
            [self presentViewController:[[UINavigationController alloc] initWithRootViewController:setupCtl] animated:YES completion:^{
                
            }];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kHideTabbar object:nil];
            break;
        }
        case 2:{
            RMSearchViewController * searchCtl = [[RMSearchViewController shared] init];
            
            [self presentViewController:[[UINavigationController alloc] initWithRootViewController:searchCtl] animated:YES completion:^{
                
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
}

- (void)requestError:(NSError *)error{
    [SVProgressHUD showErrorWithStatus:@"下载失败"];
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
