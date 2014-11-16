//
//  RMVideoCreativeStaffViewController.m
//  RMVideo
//
//  Created by runmobile on 14-10-17.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMVideoCreativeStaffViewController.h"
#import "RMVideoCreativeStaffCell.h"
#import "PullToRefreshTableView.h"
#import "RMLoginViewController.h"
#import "RMCustomPresentNavViewController.h"
#import "RMVideoPlaybackDetailsViewController.h"

typedef enum{
    requestAddCreativeStaffType = 1,
    requestDeleteCreativeStaffType
}LoadType;

@interface RMVideoCreativeStaffViewController ()<UITableViewDataSource,UITableViewDelegate,CreativeStaffCellDelegate,RMAFNRequestManagerDelegate> {
    NSMutableArray * dataArr;
    NSMutableDictionary * starTypeDic;
    NSInteger pageCount;
    BOOL isRefresh;
    LoadType loadType;
    RMImageView * rmImage;                  //获取点击cell的图片
}

@end

@implementation RMVideoCreativeStaffViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [Flurry logEvent:@"VIEW_StarDetail_CreativeStaff" timed:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [Flurry endTimedEvent:@"VIEW_StarDetail_CreativeStaff" withParameters:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    dataArr = [[NSMutableArray alloc] init];
    starTypeDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"导演", @"1", @"演员", @"2", @"主持人", @"6", @"编剧", @"7", nil];

    PullToRefreshTableView * tableView;
    if (IS_IPHONE_4_SCREEN | IS_IPHONE_5_SCREEN){
        tableView = [[PullToRefreshTableView alloc] initWithFrame:CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleHeight - 205 - 82)];
    }else if (IS_IPHONE_6_SCREEN){
        tableView = [[PullToRefreshTableView alloc] initWithFrame:CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleHeight - 295)];
    }else if (IS_IPHONE_6p_SCREEN){
        tableView = [[PullToRefreshTableView alloc] initWithFrame:CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleHeight - 267 - 82)];
    }
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.tag = 101;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableView setIsCloseHeader:YES];
    [tableView setIsCloseFooter:YES];
    [self.view addSubview:tableView];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([dataArr count] == 0){
        [self showUnderEmptyViewWithImage:LOADIMAGE(@"no_cashe_video", kImageTypePNG) WithTitle:@"暂无主创人员" WithHeight:([UtilityFunc shareInstance].globleHeight-154)/2 - 77-90];
    }else{
        [self isShouldSetHiddenUnderEmptyView:YES];
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
    static NSString * CellIdentifier = @"RMVideoCreativeStaffCellIdentifier";
    RMVideoCreativeStaffCell * cell = (RMVideoCreativeStaffCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (! cell){
        NSArray *array;
        if (IS_IPHONE_6_SCREEN){
            array = [[NSBundle mainBundle] loadNibNamed:@"RMVideoCreativeStaffCell_6" owner:self options:nil];
        }else if (IS_IPHONE_6p_SCREEN){
            array = [[NSBundle mainBundle] loadNibNamed:@"RMVideoCreativeStaffCell_6p" owner:self options:nil];
        }else{
            array = [[NSBundle mainBundle] loadNibNamed:@"RMVideoCreativeStaffCell" owner:self options:nil];
        }
        cell = [array objectAtIndex:0];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.backgroundColor = [UIColor clearColor];
        cell.delegate = self;
    }
    
    NSMutableDictionary * dic_left = [dataArr objectAtIndex:indexPath.row * 3];
    cell.leftTitle.text = [dic_left objectForKey:@"name"];
    [cell.leftHeadImg sd_setImageWithURL:[NSURL URLWithString:[dic_left objectForKey:@"pic_url"]] placeholderImage:LOADIMAGE(@"rb_loadingImg", kImageTypePNG)];
    cell.leftAddImg.identifierString = [dic_left objectForKey:@"tag_id"];
    cell.leftAddImg.indexPath = indexPath;
//    if ([model_left.is_follow integerValue] == 0){
//        cell.starAddLeftImg.image = LOADIMAGE(@"mx_add_img", kImageTypePNG);
//        cell.starAddLeftImg.isAttentionStarState = 0;
//    }else{
//        cell.starAddLeftImg.image = LOADIMAGE(@"mx_add_success_img", kImageTypePNG);
//        cell.starAddLeftImg.isAttentionStarState = 1;
//    }
    cell.leftRotatingTitle.text = [starTypeDic objectForKey:[dic_left objectForKey:@"type"]];
    [UtilityFunc rotatingView:cell.leftRotatView];
    
    if (indexPath.row * 3 + 1 >= [dataArr count]){
        cell.centerAddImg.hidden = YES;
        cell.centerRotatView.hidden = YES;
    }else{
        NSMutableDictionary * dic_center = [dataArr objectAtIndex:indexPath.row * 3 +1];
        cell.centerTitle.text = [dic_center objectForKey:@"name"];
        [cell.centerHeadImg sd_setImageWithURL:[NSURL URLWithString:[dic_center objectForKey:@"pic_url"]] placeholderImage:LOADIMAGE(@"rb_loadingImg", kImageTypePNG)];
        cell.centerAddImg.identifierString = [dic_center objectForKey:@"tag_id"];
        cell.centerAddImg.indexPath = indexPath;
//        if ([model_left.is_follow integerValue] == 0){
//            cell.starAddLeftImg.image = LOADIMAGE(@"mx_add_img", kImageTypePNG);
//            cell.starAddLeftImg.isAttentionStarState = 0;
//        }else{
//            cell.starAddLeftImg.image = LOADIMAGE(@"mx_add_success_img", kImageTypePNG);
//            cell.starAddLeftImg.isAttentionStarState = 1;
//        }
        cell.centerRotatingTitle.text = [starTypeDic objectForKey:[dic_center objectForKey:@"type"]];
        [UtilityFunc rotatingView:cell.centerRotatView];
    }
        
    if (indexPath.row * 3 + 2 >= [dataArr count]){
        cell.rightAddImg.hidden = YES;
        cell.rightRotatView.hidden = YES;
    }else{
        NSMutableDictionary * dic_right = [dataArr objectAtIndex:indexPath.row * 3 +2];
        cell.rightTitle.text = [dic_right objectForKey:@"name"];
        [cell.rightHeadImg sd_setImageWithURL:[NSURL URLWithString:[dic_right objectForKey:@"pic_url"]] placeholderImage:LOADIMAGE(@"rb_loadingImg", kImageTypePNG)];
        cell.rightAddImg.identifierString = [dic_right objectForKey:@"tag_id"];
        cell.rightAddImg.indexPath = indexPath;
//        if ([model_left.is_follow integerValue] == 0){
//            cell.starAddLeftImg.image = LOADIMAGE(@"mx_add_img", kImageTypePNG);
//            cell.starAddLeftImg.isAttentionStarState = 0;
//        }else{
//            cell.starAddLeftImg.image = LOADIMAGE(@"mx_add_success_img", kImageTypePNG);
//            cell.starAddLeftImg.isAttentionStarState = 1;
//        }
        cell.rightRotatingTitle.text = [starTypeDic objectForKey:[dic_right objectForKey:@"type"]];
        [UtilityFunc rotatingView:cell.rightRotatView];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 150;
}

#pragma mark - 添加或者删除 主创明星

- (void)clickCreativeStaffCellAddMyChannelMethod:(RMImageView *)imageView {
    if ([UtilityFunc isConnectionAvailable] == 0){
        return;
    }
    CUSFileStorage *storage = [CUSFileStorageManager getFileStorage:CURRENTENCRYPTFILE];
    if (![[AESCrypt decrypt:[storage objectForKey:LoginStatus_KEY] password:PASSWORD] isEqualToString:@"islogin"]){
        RMLoginViewController * loginCtl = [[RMLoginViewController alloc] init];
        RMVideoPlaybackDetailsViewController * videoPlaybackDetailsCtl = self.videoPlayBackDetailsDelegate;
        RMCustomPresentNavViewController * loginNav = [[RMCustomPresentNavViewController alloc] initWithRootViewController:loginCtl];
        [videoPlaybackDetailsCtl presentViewController:loginNav animated:YES completion:^{
        }];
        return;
    }
    if (imageView.identifierString){
        if (imageView.isAttentionStarState == 0){
            loadType = requestAddCreativeStaffType;
            RMAFNRequestManager * request = [[RMAFNRequestManager alloc] init];
            NSDictionary *dict = [storage objectForKey:UserLoginInformation_KEY];
            [request getJoinMyChannelWithToken:[NSString stringWithFormat:@"%@",[dict objectForKey:@"token"]] andID:imageView.identifierString];
            request.delegate = self;
            rmImage = imageView;
        }else{
            loadType = requestDeleteCreativeStaffType;
            RMAFNRequestManager * requset = [[RMAFNRequestManager alloc] init];
            CUSFileStorage *storage = [CUSFileStorageManager getFileStorage:CURRENTENCRYPTFILE];
            NSDictionary *dict = [storage objectForKey:UserLoginInformation_KEY];
            [requset getDeleteMyChannelWithTag:imageView.identifierString WithToken:[NSString stringWithFormat:@"%@",[dict objectForKey:@"token"]]];
            requset.delegate = self;
            rmImage = imageView;
        }
    }else{
    }
}

- (void)updateCreativeStaff:(RMPublicModel *)model {
    dataArr = model.creatorArr;
    [(UITableView *)[self.view viewWithTag:101] reloadData];
}
#pragma mark -
#pragma mark Scroll View Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [(PullToRefreshTableView *)[self.view viewWithTag:101]tableViewDidDragging];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    NSInteger returnKey = [(PullToRefreshTableView *)[self.view viewWithTag:201]tableViewDidEndDragging];
    
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
            [(PullToRefreshTableView *)[self.view viewWithTag:101] reloadData:NO];
            break;
        }
        case k_RETURN_LOADMORE://加载更多
        {
            [(PullToRefreshTableView *)[self.view viewWithTag:101] reloadData:NO];
            break;
        }
            
        default:
            break;
    }
}

#pragma mark - request RMAFNRequestManagerDelegate

- (void)requestFinishiDownLoadWith:(NSMutableArray *)data {
    if (loadType == requestAddCreativeStaffType){
        RMVideoCreativeStaffCell * cell = (RMVideoCreativeStaffCell *)[(PullToRefreshTableView *)[self.view viewWithTag:201] cellForRowAtIndexPath:rmImage.indexPath];
        UIImage * image = [[UIImage alloc] init];
        image = [UIImage imageNamed:@"mx_add_success_img"];
        [cell setImageWithImage:image IdentifierString:rmImage.identifierString AddMyChannel:YES];
    }else if (loadType == requestDeleteCreativeStaffType){
        RMVideoCreativeStaffCell * cell = (RMVideoCreativeStaffCell *)[(PullToRefreshTableView *)[self.view viewWithTag:201] cellForRowAtIndexPath:rmImage.indexPath];
        UIImage * image = [[UIImage alloc] init];
        image = [UIImage imageNamed:@"mx_add_img"];
        [cell setImageWithImage:image IdentifierString:rmImage.identifierString AddMyChannel:NO];
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
