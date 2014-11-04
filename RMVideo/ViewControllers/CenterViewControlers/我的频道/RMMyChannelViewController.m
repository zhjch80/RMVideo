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
#import "PullToRefreshTableView.h"
#import "UMSocial.h"

typedef enum{
    usingSinaLogin = 1,
    usingTencentLogin
    
}LoginType;

typedef enum{
    requestMyChannelListType = 1,
    requestLoginType,
    requestDeleteMyChannel
}LoadType;


@interface RMMyChannelViewController ()<UITableViewDataSource,UITableViewDelegate,MyChannemMoreWonderfulDelegate,RMAFNRequestManagerDelegate,UMSocialUIDelegate> {
    NSMutableArray * dataArr;
    LoginType loginType;
    LoadType loadType;
    NSString *userName;
    NSMutableString *headImageURLString;
    RMAFNRequestManager *manager;
    NSInteger GetDeleteRow;
}
@property (nonatomic, strong) NSString * kLoginStatus;
@property (nonatomic, strong) PullToRefreshTableView * tableView;
@property (nonatomic, strong) NSArray * btnImgWithTitleArr;
@property (nonatomic, strong) UILabel * tipTitle;
@property (nonatomic, strong) UIView * verticalLine;

@end

@implementation RMMyChannelViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshCurrentCtl];
}

#pragma mark - 刷新当前Ctl

- (void)refreshCurrentCtl {
    CUSFileStorage *storage = [CUSFileStorageManager getFileStorage:CURRENTENCRYPTFILE];
    self.kLoginStatus = [AESCrypt decrypt:[storage objectForKey:LoginStatus_KEY] password:PASSWORD];
    NSDictionary *dict = [storage objectForKey:UserLoginInformation_KEY];    
    
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
        loadType = requestMyChannelListType;
        [manager getMyChannelVideoListWithToken:[NSString stringWithFormat:@"%@",[dict objectForKey:@"token"]] pageNumber:@"1" count:@"10"];

        self.tipTitle.hidden = YES;
        self.verticalLine.hidden = YES;
        for (int i=0; i<2; i++) {
            ((UIButton *)[self.view viewWithTag:101+i]).hidden = YES;
            ((UILabel *)[self.view viewWithTag:201+i]).hidden = YES;
        }
    }else{
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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    manager = [[RMAFNRequestManager alloc] init];
    manager.delegate = self;
    dataArr = [[NSMutableArray alloc] init];
    self.btnImgWithTitleArr = [[NSArray alloc] initWithObjects:@"logo_weibo", @"logo_qq", @"微博登录", @"QQ登录", nil];
    [self.moreWonderfulImg addTarget:self WithSelector:@selector(moreWonderfulMethod)];
    
    
    [self setTitle:@"我的频道"];
    [leftBarButton setBackgroundImage:LOADIMAGE(@"setup", kImageTypePNG) forState:UIControlStateNormal];
    [rightBarButton setBackgroundImage:LOADIMAGE(@"search", kImageTypePNG) forState:UIControlStateNormal];
    
    self.tableView = [[PullToRefreshTableView alloc] initWithFrame:CGRectMake(0, 40, [UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleHeight - 40 - 49 - 44)];
    self.tableView.delegate = self;
    self.tableView.dataSource  =self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView setIsCloseFooter:NO];
    [self.tableView setIsCloseHeader:NO];
    [self.view addSubview:self.tableView];
    
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
        button.frame = CGRectMake(85 + i*100, 50, 50, 50);
        [button setBackgroundImage:LOADIMAGE([self.btnImgWithTitleArr objectAtIndex:i], kImageTypePNG) forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonMethod:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = 101+i;
        button.backgroundColor = [UIColor clearColor];
        [self.view addSubview:button];
        
        UILabel * title = [[UILabel alloc] initWithFrame:CGRectMake(62 + i*100, 100, 100, 40)];
        title.text = [self.btnImgWithTitleArr objectAtIndex:2+i];
        title.textAlignment = NSTextAlignmentCenter;
        title.font = [UIFont systemFontOfSize:14.0];
        title.tag = 201+i;
        title.textColor = [UIColor colorWithRed:0.38 green:0.38 blue:0.38 alpha:1];
        title.backgroundColor = [UIColor clearColor];
        [self.view addSubview:title];
    }
    
    [self refreshCurrentCtl];
    
}

#pragma mark - UITableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [dataArr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString * CellIdentifier = [NSString stringWithFormat:@"RMMyChannelCellIdentifier%d",indexPath.row];
    RMMyChannelCell * cell = (RMMyChannelCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (! cell) {
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
        [cell.videoFirstImg sd_setImageWithURL:[NSURL URLWithString:[[model.video_list objectAtIndex:0] objectForKey:@"pic"]] placeholderImage:nil];
        [cell.firstMovieRateView setImagesDeselected:@"mx_rateEmpty_img" partlySelected:@"mx_rateEmpty_img" fullSelected:@"mx_rateFull_img" andDelegate:nil];
        [cell.firstMovieRateView displayRating:0];
        cell.videoFirstImg.identifierString = [[model.video_list objectAtIndex:0] objectForKey:@"video_id"];
    
    }else if ([model.video_list count] == 2){
        cell.videoFirstName.text = [[model.video_list objectAtIndex:0] objectForKey:@"name"];
        [cell.videoFirstImg sd_setImageWithURL:[NSURL URLWithString:[[model.video_list objectAtIndex:0] objectForKey:@"pic"]] placeholderImage:nil];
        [cell.firstMovieRateView setImagesDeselected:@"mx_rateEmpty_img" partlySelected:@"mx_rateEmpty_img" fullSelected:@"mx_rateFull_img" andDelegate:nil];
        [cell.firstMovieRateView displayRating:0];
        cell.videoFirstImg.identifierString = [[model.video_list objectAtIndex:0] objectForKey:@"video_id"];
        
        cell.videoSecondName.text = [[model.video_list objectAtIndex:1] objectForKey:@"name"];
        [cell.videoSecondImg sd_setImageWithURL:[NSURL URLWithString:[[model.video_list objectAtIndex:1] objectForKey:@"pic"]] placeholderImage:nil];
        [cell.secondMovieRateView setImagesDeselected:@"mx_rateEmpty_img" partlySelected:@"mx_rateEmpty_img" fullSelected:@"mx_rateFull_img" andDelegate:nil];
        [cell.secondMovieRateView displayRating:4];
        cell.videoSecondImg.identifierString = [[model.video_list objectAtIndex:1] objectForKey:@"video_id"];

        
    }else if ([model.video_list count] == 3){
        cell.videoFirstName.text = [[model.video_list objectAtIndex:0] objectForKey:@"name"];
        [cell.videoFirstImg sd_setImageWithURL:[NSURL URLWithString:[[model.video_list objectAtIndex:0] objectForKey:@"pic"]] placeholderImage:nil];
        [cell.firstMovieRateView setImagesDeselected:@"mx_rateEmpty_img" partlySelected:@"mx_rateEmpty_img" fullSelected:@"mx_rateFull_img" andDelegate:nil];
        [cell.firstMovieRateView displayRating:0];
        cell.videoFirstImg.identifierString = [[model.video_list objectAtIndex:0] objectForKey:@"video_id"];

        cell.videoSecondName.text = [[model.video_list objectAtIndex:1] objectForKey:@"name"];
        [cell.videoSecondImg sd_setImageWithURL:[NSURL URLWithString:[[model.video_list objectAtIndex:1] objectForKey:@"pic"]] placeholderImage:nil];
        [cell.secondMovieRateView setImagesDeselected:@"mx_rateEmpty_img" partlySelected:@"mx_rateEmpty_img" fullSelected:@"mx_rateFull_img" andDelegate:nil];
        [cell.secondMovieRateView displayRating:4];
        cell.videoSecondImg.identifierString = [[model.video_list objectAtIndex:1] objectForKey:@"video_id"];
        
        cell.videoThirdName.text = [[model.video_list objectAtIndex:2] objectForKey:@"name"];
        [cell.videoThirdImg sd_setImageWithURL:[NSURL URLWithString:[[model.video_list objectAtIndex:2] objectForKey:@"pic"]] placeholderImage:nil];
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
            RMSearchViewController * searchCtl = [[RMSearchViewController alloc] init];
            
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
                    [SVProgressHUD showWithStatus:@"登录中" maskType:SVProgressHUDMaskTypeBlack];
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
                    [SVProgressHUD showWithStatus:@"登录中" maskType:SVProgressHUDMaskTypeBlack];
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
    //授权成功后的回调函数
    if (response.viewControllerType == UMSViewControllerOauth) {
        NSDictionary *snsAccountDic = [UMSocialAccountManager socialAccountDictionary];
        if(loginType == usingTencentLogin){
            BOOL isOauth = [UMSocialAccountManager isOauthAndTokenNotExpired:UMShareToTencent];
            if(isOauth){
                UMSocialAccountEntity *tencentAccount = [snsAccountDic valueForKey:UMShareToTencent];
                userName = tencentAccount.userName;
                headImageURLString = [NSMutableString stringWithFormat:@"%@",tencentAccount.iconURL];
                [SVProgressHUD showWithStatus:@"登录中" maskType:SVProgressHUDMaskTypeBlack];
                loadType = requestLoginType;
                [manager postLoginWithSourceType:@"2" sourceId:tencentAccount.usid username:[tencentAccount.userName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] headImageURL:[headImageURLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            }
        }else if ( loginType == usingSinaLogin){
            BOOL isOauth = [UMSocialAccountManager isOauthAndTokenNotExpired:UMShareToSina];
            if(isOauth){
                UMSocialAccountEntity *sinaAccount = [snsAccountDic valueForKey:UMShareToSina];
                userName = sinaAccount.userName;
                headImageURLString = [NSMutableString stringWithFormat:@"%@",sinaAccount.iconURL];
                [SVProgressHUD showWithStatus:@"登录中" maskType:SVProgressHUDMaskTypeBlack];
                loadType = requestLoginType;
                [manager postLoginWithSourceType:@"4" sourceId:sinaAccount.usid username:[sinaAccount.userName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] headImageURL:[headImageURLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            }
        }
    }
}

#pragma mark -
#pragma mark Scroll View Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.tableView tableViewDidDragging];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    NSInteger returnKey = [self.tableView tableViewDidEndDragging];
    
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
            break;
        }
        case k_RETURN_REFRESH://刷新
        {
            [self.tableView reloadData:NO];
            break;
        }
        case k_RETURN_LOADMORE://加载更多
        {
            [self.tableView reloadData:NO];
            break;
        }
            
        default:
            break;
    }
}

#pragma mark - request RMAFNRequestManagerDelegate

- (void)requestFinishiDownLoadWith:(NSMutableArray *)data {
    if (loadType == requestMyChannelListType){
        dataArr = data;
        [self.tableView reloadData];
    }else if (loadType == requestLoginType){
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setValue:userName forKey:@"userName"];
        [dict setValue:headImageURLString forKey:@"HeadImageURL"];
        [dict setValue:[data objectAtIndex:0] forKey:@"token"];
        CUSFileStorage *storage = [CUSFileStorageManager getFileStorage:CURRENTENCRYPTFILE];
        [storage beginUpdates];
        NSString * loginStatus = [AESCrypt encrypt:@"islogin" password:PASSWORD];
        [storage setObject:dict forKey:UserLoginInformation_KEY];
        [storage setObject:loginStatus forKey:LoginStatus_KEY];
        [storage endUpdates];
        [SVProgressHUD dismiss];
        [self refreshCurrentCtl];
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
