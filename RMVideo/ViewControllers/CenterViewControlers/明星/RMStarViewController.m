//
//  RMStarViewController.m
//  RMVideo
//
//  Created by runmobile on 14-10-13.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMStarViewController.h"
#import "RMStarCell.h"
#import "RMImageView.h"
#import "PullToRefreshTableView.h"
#import "RMSetupViewController.h"
#import "RMStarDetailsViewController.h"
#import "RMLoginViewController.h"
#import "RMCustomNavViewController.h"
#import "RMCustomPresentNavViewController.h"
#import "RMSearchViewController.h"

#import "RMStarDetailsViewController.h"



#import <QuartzCore/QuartzCore.h>

typedef enum{
    requestStarListType = 1,
    requestAddStarMyChannelType,
    requestDeleteStarMyChannelType,
    requestSuccessType
}LoadType;

@interface RMStarViewController ()<UITableViewDataSource,UITableViewDelegate,StarCellDelegate,RMAFNRequestManagerDelegate> {
    NSMutableArray * dataArr;
    LoadType loadType;
    NSInteger pageCount;
    BOOL isRefresh;
    RMImageView * rmImage;                  //获取点击cell的图片
    NSInteger AltogetherRows;               //总共有多少条数据
}
@property (nonatomic, strong) PullToRefreshTableView * tableView;

@end

@implementation RMStarViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [Flurry logEvent:@"VIEW_Star" timed:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [Flurry endTimedEvent:@"VIEW_Star" withParameters:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    loadType = requestStarListType;

    dataArr = [[NSMutableArray alloc] init];

    [self setTitle:@"明星"];
    [leftBarButton setImage:LOADIMAGE(@"setup", kImageTypePNG) forState:UIControlStateNormal];
    [rightBarButton setImage:LOADIMAGE(@"search", kImageTypePNG) forState:UIControlStateNormal];
    
    
    self.tableView = [[PullToRefreshTableView alloc] initWithFrame:CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleHeight - 44 - 49)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView setIsCloseHeader:NO];
    [self.tableView setIsCloseFooter:NO];
    [self.view addSubview:self.tableView];
    
    pageCount = 1;
    isRefresh = YES;
    [self startRequest];
}

#pragma mark - UITableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([dataArr count] == 0){
        [self showEmptyViewWithImage:LOADIMAGE(@"no_cashe_video", kImageTypePNG) WithTitle:@"暂无内容"];
    }else{
        [self isShouldSetHiddenEmptyView:YES];
    }
    if ([dataArr count]%3 == 0){
        return [dataArr count] / 3;
    }else if ([dataArr count]%3 == 1){
        return ([dataArr count] + 2) / 3;
    }else {
        return ([dataArr count] + 1) / 3;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString * CellIdentifier = [NSString stringWithFormat:@"RMStarCellIdentifier%d",indexPath.row];
    RMStarCell * cell = (RMStarCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (! cell) {
        NSArray *array;
        if (IS_IPHONE_6_SCREEN){
            array = [[NSBundle mainBundle] loadNibNamed:@"RMStarCell_6" owner:self options:nil];
        }else if (IS_IPHONE_6p_SCREEN){
            array = [[NSBundle mainBundle] loadNibNamed:@"RMStarCell_6p" owner:self options:nil];
        }else {
            array = [[NSBundle mainBundle] loadNibNamed:@"RMStarCell" owner:self options:nil];
        }
        cell = [array objectAtIndex:0];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.backgroundColor = [UIColor clearColor];
        cell.delegate = self;
    }
    RMPublicModel *model_left;
    RMPublicModel *model_center;
    RMPublicModel *model_right;
    
    model_left = [dataArr objectAtIndex:indexPath.row*3];
    [cell.leftTitle loadTextViewWithString:model_left.name WithTextFont:[UIFont systemFontOfSize:14.0] WithTextColor:[UIColor blackColor] WithTextAlignment:NSTextAlignmentCenter WithSetupLabelCenterPoint:YES WithTextOffset:6];
    [cell.leftTitle startScrolling];
    [cell.starLeftImg sd_setImageWithURL:[NSURL URLWithString:model_left.pic_url] placeholderImage:LOADIMAGE(@"Default90_119", kImageTypePNG)];
    cell.starLeftImg.identifierString = model_left.tag_id;
    cell.starAddLeftImg.identifierString = model_left.tag_id;
    cell.starAddLeftImg.indexPath = indexPath;
    if ([model_left.is_follow integerValue] == 0){
        cell.starAddLeftImg.image = LOADIMAGE(@"mx_add_img", kImageTypePNG);
        cell.starAddLeftImg.isAttentionStarState = 0;
    }else{
        cell.starAddLeftImg.image = LOADIMAGE(@"mx_add_success_img", kImageTypePNG);
        cell.starAddLeftImg.isAttentionStarState = 1;
    }
    
    if (indexPath.row * 3 + 1 >= [dataArr count]){
        cell.starAddCenterImg.hidden = YES;
    }else{
        model_center = [dataArr objectAtIndex:indexPath.row*3 + 1];
        [cell.centerTitle loadTextViewWithString:model_center.name WithTextFont:[UIFont systemFontOfSize:14.0] WithTextColor:[UIColor blackColor] WithTextAlignment:NSTextAlignmentCenter WithSetupLabelCenterPoint:YES WithTextOffset:6];
        [cell.centerTitle startScrolling];
        [cell.starCenterImg sd_setImageWithURL:[NSURL URLWithString:model_center.pic_url] placeholderImage:LOADIMAGE(@"Default90_119", kImageTypePNG)];
        cell.starCenterImg.identifierString = model_center.tag_id;
        cell.starAddCenterImg.identifierString = model_center.tag_id;
        cell.starAddCenterImg.indexPath = indexPath;
        if ([model_center.is_follow integerValue] == 0){
            cell.starAddCenterImg.image = LOADIMAGE(@"mx_add_img", kImageTypePNG);
            cell.starAddCenterImg.isAttentionStarState = 0;
        }else{
            cell.starAddCenterImg.image = LOADIMAGE(@"mx_add_success_img", kImageTypePNG);
            cell.starAddCenterImg.isAttentionStarState = 1;
        }
    }
    
    if (indexPath.row * 3 + 2 >= [dataArr count]){
        cell.starAddRightImg.hidden = YES;
    }else{
        model_right = [dataArr objectAtIndex:indexPath.row*3 + 2];
        [cell.rightTitle loadTextViewWithString:model_right.name WithTextFont:[UIFont systemFontOfSize:14.0] WithTextColor:[UIColor blackColor] WithTextAlignment:NSTextAlignmentCenter WithSetupLabelCenterPoint:YES WithTextOffset:6];
        [cell.rightTitle startScrolling];
        [cell.starRightImg sd_setImageWithURL:[NSURL URLWithString:model_right.pic_url] placeholderImage:LOADIMAGE(@"Default90_119", kImageTypePNG)];
        cell.starRightImg.identifierString = model_right.tag_id;
        cell.starAddRightImg.identifierString = model_right.tag_id;
        cell.starAddRightImg.indexPath = indexPath;
        if ([model_right.is_follow integerValue] == 0){
            cell.starAddRightImg.image = LOADIMAGE(@"mx_add_img", kImageTypePNG);
            cell.starAddRightImg.isAttentionStarState = 0;
        }else{
            cell.starAddRightImg.image = LOADIMAGE(@"mx_add_success_img", kImageTypePNG);
            cell.starAddRightImg.isAttentionStarState = 1;
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger value = 0;
    
    if ([dataArr count]%3 == 0){
        value = [dataArr count]/3;
    }else if ([dataArr count]%3 == 1){
        value = ([dataArr count] + 2) / 3;
    }else {
        value = ([dataArr count] + 1) / 3;
    }
    
    if (indexPath.row == value - 1){
        if (IS_IPHONE_4_SCREEN | IS_IPHONE_5_SCREEN){
            return 160;
        }else if (IS_IPHONE_6_SCREEN){
            return 172;
        }else{
            return 190;
        }
    }else{
        if (IS_IPHONE_4_SCREEN | IS_IPHONE_5_SCREEN){
            return 150;
        }else if (IS_IPHONE_6_SCREEN){
            return 162;
        }else{
            return 180;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark - 进入明星详情页面

- (void)clickVideoImageViewMehtod:(RMImageView *)imageView {
//    if (imageView.identifierString) {
//        RMStarDetailsViewController * starDetailsCtl = [[RMStarDetailsViewController alloc] init];
//        [self.navigationController pushViewController:starDetailsCtl animated:YES];
//        [starDetailsCtl setStarID:imageView.identifierString];
//        [[NSNotificationCenter defaultCenter] postNotificationName:kHideTabbar object:nil];
//    }
    
    RMStarDetailsViewController * newStarDetailsCtl = [[RMStarDetailsViewController alloc] init];
    [self.navigationController pushViewController:newStarDetailsCtl animated:YES];
    newStarDetailsCtl.star_id = imageView.identifierString;
    [[NSNotificationCenter defaultCenter] postNotificationName:kHideTabbar object:nil];

}

#pragma mark - 添加或者删除 明星 在我的频道里

- (void)willStartAddMyChannelMethod:(RMImageView *)imageView {
    if ([UtilityFunc isConnectionAvailable] == 0){
        [SVProgressHUD showErrorWithStatus:kShowConnectionAvailableError duration:1.0];
        return;
    }
    
    [SVProgressHUD dismiss];
    CUSFileStorage *storage = [CUSFileStorageManager getFileStorage:CURRENTENCRYPTFILE];
    if (![[AESCrypt decrypt:[storage objectForKey:LoginStatus_KEY] password:PASSWORD] isEqualToString:@"islogin"]){
        RMLoginViewController * loginCtl = [[RMLoginViewController alloc] init];
        RMCustomPresentNavViewController * loginNav = [[RMCustomPresentNavViewController alloc] initWithRootViewController:loginCtl];
        [self presentViewController:loginNav animated:YES completion:^{
        }];
        return;
    }
    if (imageView.identifierString){
        if (imageView.isAttentionStarState == 0){
            [SVProgressHUD show];
            loadType = requestAddStarMyChannelType;
            RMAFNRequestManager * requset = [[RMAFNRequestManager alloc] init];
            CUSFileStorage *storage = [CUSFileStorageManager getFileStorage:CURRENTENCRYPTFILE];
            NSDictionary *dict = [storage objectForKey:UserLoginInformation_KEY];
            [requset getJoinMyChannelWithToken:[NSString stringWithFormat:@"%@",[dict objectForKey:@"token"]] andID:imageView.identifierString];
            requset.delegate = self;
            rmImage = imageView;
        }else{
            [SVProgressHUD show];
            loadType = requestDeleteStarMyChannelType;
            RMAFNRequestManager * requset = [[RMAFNRequestManager alloc] init];
            CUSFileStorage *storage = [CUSFileStorageManager getFileStorage:CURRENTENCRYPTFILE];
            NSDictionary *dict = [storage objectForKey:UserLoginInformation_KEY];
            [requset getDeleteMyChannelWithTag:imageView.identifierString WithToken:[NSString stringWithFormat:@"%@",[dict objectForKey:@"token"]]];
            requset.delegate = self;
            rmImage = imageView;
        }
    }
}

- (void)clickAddMyChannelMethod:(RMImageView *)imageView {
    [SVProgressHUD showWithStatus:@"处理中" maskType:SVProgressHUDMaskTypeBlack];
    [self performSelector:@selector(willStartAddMyChannelMethod:) withObject:imageView afterDelay:1.0];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.tableView tableViewDidDragging];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
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
            pageCount = 1;
            isRefresh = YES;
            loadType =  requestStarListType;
            [self startRequest];
            break;
        }
        case k_RETURN_LOADMORE://加载更多
        {
            if (pageCount * 12 > AltogetherRows){
                [self.tableView reloadData:YES];
            }else{
                pageCount ++;
                isRefresh = NO;
                loadType =  requestStarListType;
                [self startRequest];
            }

            break;
        }
            
        default:
            break;
    }
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

- (void)startRequest {
    [SVProgressHUD showWithStatus:@"加载中..." maskType:SVProgressHUDMaskTypeBlack];
    CUSFileStorage *storage = [CUSFileStorageManager getFileStorage:CURRENTENCRYPTFILE];
    NSDictionary *dict = [storage objectForKey:UserLoginInformation_KEY];
    RMAFNRequestManager * requset = [[RMAFNRequestManager alloc] init];
    [requset getStarListWithPage:[NSString stringWithFormat:@"%d",pageCount] count:@"12" WithToken:[NSString stringWithFormat:@"%@",[dict objectForKey:@"token"]]];
    requset.delegate = self;
}

- (void)requestFinishiDownLoadWith:(NSMutableArray *)data {
    [SVProgressHUD dismiss];
    self.tableView.isCloseFooter = NO;
    if (loadType == requestStarListType){
        RMPublicModel * model_row = [data objectAtIndex:0];
        AltogetherRows = [model_row.rows integerValue];
        if (isRefresh){
            dataArr = data;
        }else{
            for (int i=0; i<data.count; i++) {
                RMPublicModel * model = [data objectAtIndex:i];
                [dataArr addObject:model];
            }
        }
        [self.tableView reloadData:NO];
    }else if (loadType == requestAddStarMyChannelType){
        RMStarCell * cell = (RMStarCell *)[self.tableView cellForRowAtIndexPath:rmImage.indexPath];
        UIImage * image = [[UIImage alloc] init];
        image = [UIImage imageNamed:@"mx_add_success_img"];
        [cell setImageWithImage:image IdentifierString:rmImage.identifierString AddMyChannel:YES];
        [SVProgressHUD dismiss];
    }else if (loadType == requestDeleteStarMyChannelType){
        RMStarCell * cell = (RMStarCell *)[self.tableView cellForRowAtIndexPath:rmImage.indexPath];
        UIImage * image = [[UIImage alloc] init];
        image = [UIImage imageNamed:@"mx_add_img"];
        [cell setImageWithImage:image IdentifierString:rmImage.identifierString AddMyChannel:NO];
        [SVProgressHUD dismiss];
    }
    loadType = requestSuccessType;
}

- (void)requestError:(NSError *)error {
    self.tableView.isCloseFooter = YES;
    [self.tableView reloadData:NO];
    [SVProgressHUD dismiss];
}

@end
