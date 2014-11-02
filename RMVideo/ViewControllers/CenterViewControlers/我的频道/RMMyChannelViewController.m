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

#import "RMLoginRecommendViewController.h"
#import "RMAFNRequestManager.h"
#import "UIImageView+AFNetworking.h"
#import "RMMyChannelShouldSeeViewController.h"

@interface RMMyChannelViewController ()<UITableViewDataSource,UITableViewDelegate,MyChannemMoreWonderfulDelegate,RMAFNRequestManagerDelegate> {
    NSMutableArray * dataArr;
}

@end

@implementation RMMyChannelViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    CUSFileStorage *storage = [CUSFileStorageManager getFileStorage:CURRENTENCRYPTFILE];
    NSString * loginStatus = [AESCrypt decrypt:[storage objectForKey:LoginStatus_KEY] password:PASSWORD];
    loginStatus = @"islogin";
    
    if ([loginStatus isEqualToString:@"islogin"]){
        //登录
        dataArr = [[NSMutableArray alloc] init];
        
        [self setTitle:@"我的频道"];
        [leftBarButton setBackgroundImage:LOADIMAGE(@"setup", kImageTypePNG) forState:UIControlStateNormal];
        [rightBarButton setBackgroundImage:LOADIMAGE(@"search", kImageTypePNG) forState:UIControlStateNormal];
        [self.moreWonderfulImg addTarget:self WithSelector:@selector(moreWonderfulMethod)];
        
        UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 40, [UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleHeight - 40 - 49 - 44) style:UITableViewStylePlain];
        tableView.delegate = self;
        tableView.dataSource  =self;
        tableView.tag = 101;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:tableView];
        
        RMAFNRequestManager * request = [[RMAFNRequestManager alloc] init];
        [request getMyChannelVideoListWithToken:testToken pageNumber:@"1" count:@"10"];
        request.delegate = self;
        
    }else{
        //未登录
        self.moreWonderfulImg.hidden = YES;
        self.moreBgImg.hidden = YES;
        self.moreTitle.hidden = YES;
        self.moreBtn.hidden = YES;
    
        NSArray * btnImgWithTitleArr = [[NSArray alloc] initWithObjects:@"logo_weibo", @"logo_qq", @"微博登录", @"QQ登录", nil];
        
        [self setTitle:@"登录"];
        
        leftBarButton.hidden = YES;
        rightBarButton.hidden = YES;

        UILabel * tipTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth, 50)];
        tipTitle.backgroundColor = [UIColor clearColor];
        tipTitle.text = @"使用社交账号登录到XXX";
        tipTitle.textAlignment = NSTextAlignmentCenter;
        tipTitle.font = [UIFont systemFontOfSize:16.0];
        tipTitle.textColor = [UIColor colorWithRed:0.16 green:0.16 blue:0.16 alpha:1];
        [self.view addSubview:tipTitle];
        
        UIView * verticalLine = [[UIView alloc] initWithFrame:CGRectMake([UtilityFunc shareInstance].globleWidth/2-0.5, 50, 1, 50)];
        verticalLine.backgroundColor = [UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1];
        [self.view addSubview:verticalLine];
        
        for (int i=0; i<2; i++) {
            UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(85 + i*100, 50, 50, 50);
            [button setBackgroundImage:LOADIMAGE([btnImgWithTitleArr objectAtIndex:i], kImageTypePNG) forState:UIControlStateNormal];
            [button addTarget:self action:@selector(buttonMethod:) forControlEvents:UIControlEventTouchUpInside];
            button.tag = 101+i;
            button.backgroundColor = [UIColor clearColor];
            [self.view addSubview:button];
            
            UILabel * title = [[UILabel alloc] initWithFrame:CGRectMake(62 + i*100, 100, 100, 40)];
            title.text = [btnImgWithTitleArr objectAtIndex:2+i];
            title.textAlignment = NSTextAlignmentCenter;
            title.font = [UIFont systemFontOfSize:14.0];
            title.textColor = [UIColor colorWithRed:0.38 green:0.38 blue:0.38 alpha:1];
            title.backgroundColor = [UIColor clearColor];
            [self.view addSubview:title];
        }
    }
}

#pragma mark - UITableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [dataArr count];
//    if ([dataArr count]/3 == 0){
//        return [dataArr count]/3;
//    }else if ([dataArr count]/3 == 1){
//        return ([dataArr count] + 2) / 3;
//    }else {
//        return ([dataArr count] + 1) / 3;
//    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString * CellIdentifier = [NSString stringWithFormat:@"RMMyChannelCellIdentifier%d",indexPath.row];
    RMMyChannelCell * cell = (RMMyChannelCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (! cell) {
        /*
         cell = [[RMStarCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
         [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
         cell.backgroundColor = [UIColor clearColor];
         */
        
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"RMMyChannelCell" owner:self options:nil];
        cell = [array objectAtIndex:0];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.backgroundColor = [UIColor clearColor];
        cell.delegate = self;
    }
    RMPublicModel *model = [dataArr objectAtIndex:indexPath.row];    
    CGFloat width = [UtilityFunc boundingRectWithSize:CGSizeMake(0, 30) font:[UIFont systemFontOfSize:14.0] text:model.name].width;
    cell.tag_title.frame = CGRectMake(2, 0, width + 30, 30);
    cell.tag_title.text = model.name;
    cell.moreBtn.tag = indexPath.row;
    
    if ([model.video_list count] == 0){
        
    } else if ([model.video_list count] == 1){
        cell.videoFirstName.text = [[model.video_list objectAtIndex:0] objectForKey:@"name"];
        [cell.videoFirstImg setImageWithURL:[NSURL URLWithString:[[model.video_list objectAtIndex:0] objectForKey:@"pic"]] placeholderImage:nil];
        [cell.firstMovieRateView setImagesDeselected:@"mx_rateEmpty_img" partlySelected:@"mx_rateEmpty_img" fullSelected:@"mx_rateFull_img" andDelegate:nil];
        [cell.firstMovieRateView displayRating:0];
        cell.videoFirstImg.identifierString = [[model.video_list objectAtIndex:0] objectForKey:@"video_id"];
    
    }else if ([model.video_list count] == 2){
        cell.videoFirstName.text = [[model.video_list objectAtIndex:0] objectForKey:@"name"];
        [cell.videoFirstImg setImageWithURL:[NSURL URLWithString:[[model.video_list objectAtIndex:0] objectForKey:@"pic"]] placeholderImage:nil];
        [cell.firstMovieRateView setImagesDeselected:@"mx_rateEmpty_img" partlySelected:@"mx_rateEmpty_img" fullSelected:@"mx_rateFull_img" andDelegate:nil];
        [cell.firstMovieRateView displayRating:0];
        cell.videoFirstImg.identifierString = [[model.video_list objectAtIndex:0] objectForKey:@"video_id"];
        
        cell.videoSecondName.text = [[model.video_list objectAtIndex:1] objectForKey:@"name"];
        [cell.videoSecondImg setImageWithURL:[NSURL URLWithString:[[model.video_list objectAtIndex:1] objectForKey:@"pic"]] placeholderImage:nil];
        [cell.secondMovieRateView setImagesDeselected:@"mx_rateEmpty_img" partlySelected:@"mx_rateEmpty_img" fullSelected:@"mx_rateFull_img" andDelegate:nil];
        [cell.secondMovieRateView displayRating:4];
        cell.videoSecondImg.identifierString = [[model.video_list objectAtIndex:1] objectForKey:@"video_id"];

        
    }else if ([model.video_list count] == 3){
        cell.videoFirstName.text = [[model.video_list objectAtIndex:0] objectForKey:@"name"];
        [cell.videoFirstImg setImageWithURL:[NSURL URLWithString:[[model.video_list objectAtIndex:0] objectForKey:@"pic"]] placeholderImage:nil];
        [cell.firstMovieRateView setImagesDeselected:@"mx_rateEmpty_img" partlySelected:@"mx_rateEmpty_img" fullSelected:@"mx_rateFull_img" andDelegate:nil];
        [cell.firstMovieRateView displayRating:0];
        cell.videoFirstImg.identifierString = [[model.video_list objectAtIndex:0] objectForKey:@"video_id"];

        
        cell.videoSecondName.text = [[model.video_list objectAtIndex:1] objectForKey:@"name"];
        [cell.videoSecondImg setImageWithURL:[NSURL URLWithString:[[model.video_list objectAtIndex:1] objectForKey:@"pic"]] placeholderImage:nil];
        [cell.secondMovieRateView setImagesDeselected:@"mx_rateEmpty_img" partlySelected:@"mx_rateEmpty_img" fullSelected:@"mx_rateFull_img" andDelegate:nil];
        [cell.secondMovieRateView displayRating:4];
        cell.videoSecondImg.identifierString = [[model.video_list objectAtIndex:1] objectForKey:@"video_id"];

        
        
        cell.videoThirdName.text = [[model.video_list objectAtIndex:2] objectForKey:@"name"];
        [cell.videoThirdImg setImageWithURL:[NSURL URLWithString:[[model.video_list objectAtIndex:2] objectForKey:@"pic"]] placeholderImage:nil];
        [cell.thirdMovieRateView setImagesDeselected:@"mx_rateEmpty_img" partlySelected:@"mx_rateEmpty_img" fullSelected:@"mx_rateFull_img" andDelegate:nil];
        [cell.thirdMovieRateView displayRating:3];
        cell.videoThirdImg.identifierString = [[model.video_list objectAtIndex:2] objectForKey:@"video_id"];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (IS_IPHONE_6_SCREEN){
        return 215;
    }else if (IS_IPHONE_6p_SCREEN){
        return 205;
    }else{
        return 205;
    }
}

#pragma mark - RMImageView Method

- (void)moreWonderfulMethod {
    RMMoreWonderfulViewController * moreWonderfulCtl = [[RMMoreWonderfulViewController alloc] init];
    [self.navigationController pushViewController:moreWonderfulCtl animated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:kHideTabbar object:nil];
}

#pragma mark - Base Method

- (void)navgationBarButtonClick:(UIBarButtonItem *)sender {
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

- (IBAction)mbuttonClick:(UIButton *)sender {
    [self moreWonderfulMethod];
}

- (void)buttonMethod:(UIButton *)sender {
    switch (sender.tag) {
        case 101:{
            NSLog(@"微博分享");
            
            break;
        }
        case 102:{
            NSLog(@"QQ分享");
            
            break;
        }
            
        default:
            break;
    }
}

- (void)requestFinishiDownLoadWith:(NSMutableArray *)data {
    dataArr = data;
    [(UITableView *)[self.view viewWithTag:101] reloadData];
}

- (void)requestError:(NSError *)error {
    NSLog(@"error:%@",error);
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
