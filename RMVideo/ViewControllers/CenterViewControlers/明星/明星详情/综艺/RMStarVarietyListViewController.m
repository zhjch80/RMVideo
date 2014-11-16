//
//  RMStarVarietyListViewController.m
//  RMVideo
//
//  Created by runmobile on 14-10-14.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMStarVarietyListViewController.h"
#import "RMStarDetailsCell.h"
#import "RMVideoPlaybackDetailsViewController.h"
#import "RMStarDetailsViewController.h"

#import "PullToRefreshTableView.h"

@interface RMStarVarietyListViewController ()<UITableViewDataSource,UITableViewDelegate,StarDetailsCellDelegate,RMAFNRequestManagerDelegate> {
    NSMutableArray * dataArr;
    NSInteger AltogetherRows;
    NSInteger pageCount;
    BOOL isRefresh;
}

@end

@implementation RMStarVarietyListViewController
@synthesize starDetailsDelegate = _starDetailsDelegate;

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [Flurry logEvent:@"VIEW_StarDetail_Variety" timed:YES];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [Flurry endTimedEvent:@"VIEW_StarDetail_Variety" withParameters:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    dataArr = [[NSMutableArray alloc] init];
    PullToRefreshTableView * tableView = [[PullToRefreshTableView alloc] init];
    if (IS_IPHONE_6_SCREEN){
        tableView.frame = CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleHeight - 42 - 180);
    }else if (IS_IPHONE_6p_SCREEN){
        tableView.frame = CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleHeight - 42 - 180);
    }else{
        tableView.frame = CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleHeight - 42 - 180);
    }
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.tag = 203;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableView setIsCloseHeader:NO];
    [tableView setIsCloseFooter:NO];
    [self.view addSubview:tableView];
    pageCount = 1;
}

- (void)startRequest {
    RMAFNRequestManager * request = [[RMAFNRequestManager alloc] init];
    [request getTagOfVideoListWithID:self.star_id andVideoType:@"3" WithPage:[NSString stringWithFormat:@"%d",pageCount] count:@"12"];
    request.delegate = self;
}

#pragma mark - UITableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([dataArr count] == 0){
        [self showUnderEmptyViewWithImage:LOADIMAGE(@"no_cashe_video", kImageTypePNG) WithTitle:@"暂无内容" WithHeight:([UtilityFunc shareInstance].globleHeight-154)/2 - 77-90];
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
    static NSString * CellIdentifier = @"RMStarDetailsCellIdentifier";
    RMStarDetailsCell * cell = (RMStarDetailsCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (! cell) {
        NSArray *array;
        if (IS_IPHONE_6_SCREEN){
            array = [[NSBundle mainBundle] loadNibNamed:@"RMStarDetailsCell_6" owner:self options:nil];
        }else if (IS_IPHONE_6p_SCREEN){
            array = [[NSBundle mainBundle] loadNibNamed:@"RMStarDetailsCell_6p" owner:self options:nil];
        }else{
            array = [[NSBundle mainBundle] loadNibNamed:@"RMStarDetailsCell" owner:self options:nil];
        }
        cell = [array objectAtIndex:0];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.backgroundColor = [UIColor clearColor];
        cell.delegate = self;
    }
    RMPublicModel *model_left = [dataArr objectAtIndex:indexPath.row*3];
    [cell.fristLable loadTextViewWithString:model_left.name WithTextFont:[UIFont systemFontOfSize:14.0] WithTextColor:[UIColor blackColor] WithTextAlignment:NSTextAlignmentCenter WithSetupLabelCenterPoint:YES WithTextOffset:0];
    [cell.fristLable startScrolling];    [cell.fristImage sd_setImageWithURL:[NSURL URLWithString:model_left.pic] placeholderImage:LOADIMAGE(@"sp_loadingImg", kImageTypePNG)];
    cell.fristImage.identifierString = model_left.video_id;
    [cell.firstStarRateView setImagesDeselected:@"mx_rateEmpty_img" partlySelected:@"mx_rateEmpty_img" fullSelected:@"mx_rateFull_img" andDelegate:nil];
    [cell.firstStarRateView displayRating:[model_left.gold integerValue]];

    if (indexPath.row * 3 + 1 >= [dataArr count]){
        
    }else{
        RMPublicModel *model_center = [dataArr objectAtIndex:indexPath.row*3 + 1];
        [cell.secondLable loadTextViewWithString:model_center.name WithTextFont:[UIFont systemFontOfSize:14.0] WithTextColor:[UIColor blackColor] WithTextAlignment:NSTextAlignmentCenter WithSetupLabelCenterPoint:YES WithTextOffset:0];
        [cell.secondLable startScrolling];
        [cell.secondImage sd_setImageWithURL:[NSURL URLWithString:model_center.pic] placeholderImage:LOADIMAGE(@"sp_loadingImg", kImageTypePNG)];
        cell.secondImage.identifierString = model_center.video_id;
        [cell.secondStarRateView setImagesDeselected:@"mx_rateEmpty_img" partlySelected:@"mx_rateEmpty_img" fullSelected:@"mx_rateFull_img" andDelegate:nil];
        [cell.secondStarRateView displayRating:[model_center.gold integerValue]];
    }
    
    if (indexPath.row * 3 + 2 >= [dataArr count]){
        
    }else{
        RMPublicModel *model_right = [dataArr objectAtIndex:indexPath.row*3 + 2];
        [cell.threeLable loadTextViewWithString:model_right.name WithTextFont:[UIFont systemFontOfSize:14.0] WithTextColor:[UIColor blackColor] WithTextAlignment:NSTextAlignmentCenter WithSetupLabelCenterPoint:YES WithTextOffset:0];
        [cell.threeLable startScrolling];
        [cell.threeImage sd_setImageWithURL:[NSURL URLWithString:model_right.pic] placeholderImage:LOADIMAGE(@"sp_loadingImg", kImageTypePNG)];
        cell.threeImage.identifierString = model_right.video_id;
        [cell.thirdStarRateView setImagesDeselected:@"mx_rateEmpty_img" partlySelected:@"mx_rateEmpty_img" fullSelected:@"mx_rateFull_img" andDelegate:nil];
        [cell.thirdStarRateView displayRating:[model_right.gold integerValue]];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 155;
}

#pragma mark - StarDetailsCellDelegate

- (void)startDetailsCellDidSelectWithImage:(RMImageView *)imageView {
    RMVideoPlaybackDetailsViewController * videoPlaybackDetailsCtl = [[RMVideoPlaybackDetailsViewController alloc] init];
    RMStarDetailsViewController * starDetailsDelegate = _starDetailsDelegate;
    videoPlaybackDetailsCtl.currentVideo_id = imageView.identifierString;
    [starDetailsDelegate.navigationController pushViewController:videoPlaybackDetailsCtl animated:YES];
}

#pragma mark -
#pragma mark Scroll View Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [(PullToRefreshTableView *)[self.view viewWithTag:203]tableViewDidDragging];
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
            pageCount = 1;
            isRefresh = YES;
            [self startRequest];
            break;
        }
        case k_RETURN_LOADMORE://加载更多
        {
            if (pageCount * 12 > AltogetherRows){
                [(PullToRefreshTableView *)[self.view viewWithTag:203] reloadData:YES];
            }else{
                pageCount ++;
                isRefresh = NO;
                [self startRequest];
            }
            break;
        }
            
        default:
            break;
    }
}

#pragma mark - request RMAFNRequestManagerDelegate

- (void)requestFinishiDownLoadWith:(NSMutableArray *)data {
    if (data.count == 0){
        ((PullToRefreshTableView *)[self.view viewWithTag:203]).isCloseFooter = YES;
        return;
    }
    ((PullToRefreshTableView *)[self.view viewWithTag:203]).isCloseFooter = NO;
    RMPublicModel * model = [data objectAtIndex:0];
    AltogetherRows = [model.rows integerValue];
    if (isRefresh){
        dataArr = data;
    }else{
        for (int i=0; i<data.count; i++) {
            RMPublicModel * model = [data objectAtIndex:i];
            [dataArr addObject:model];
        }
    }
    [(PullToRefreshTableView *)[self.view viewWithTag:203] reloadData:NO];
}

-(void)requestError:(NSError *)error {
    NSLog(@"star 电影 error:%@",error);
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
