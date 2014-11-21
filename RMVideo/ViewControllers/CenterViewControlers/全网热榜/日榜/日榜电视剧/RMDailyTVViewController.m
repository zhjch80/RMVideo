//
//  RMDailyTVViewController.m
//  RMVideo
//
//  Created by 润华联动 on 14-10-16.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMDailyTVViewController.h"
#import "RMDailyListTableViewCell.h"
#import "RMImageView.h"

@interface RMDailyTVViewController ()

@end

@implementation RMDailyTVViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [Flurry logEvent:@"VIEW_ToDayRecommended_TVseries" timed:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [Flurry endTimedEvent:@"VIEW_ToDayRecommended_TVseries" withParameters:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if (IS_IPHONE_4_SCREEN | IS_IPHONE_5_SCREEN){
        self.mainTableView.frame = CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth,[UtilityFunc shareInstance].globleAllHeight-44-64);
    }else if (IS_IPHONE_6_SCREEN){
        self.mainTableView.frame = CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth,[UtilityFunc shareInstance].globleAllHeight-44-64);
    }else{
        self.mainTableView.frame = CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth,[UtilityFunc shareInstance].globleAllHeight-54-64);
    }
    [self.mainTableView setIsCloseFooter:YES];
    [SVProgressHUD showWithStatus:@"下载中..." maskType:SVProgressHUDMaskTypeBlack];
    RMAFNRequestManager *manager = [[RMAFNRequestManager alloc] init];
    manager.delegate = self;
    //视频类型（1：电影 2：电视剧 3：综艺）
    //排行类型（1：日榜 2：周榜 3：月榜）
    [manager getTopListWithVideoTpye:@"2" andTopType:self.downLoadTopType searchPageNumber:@"1" andCount:@"10"];
    
[self setExtraCellLineHidden:self.mainTableView];
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.dataArray.count == 0){
        [self showEmptyViewWithImage:LOADIMAGE(@"no_cashe_video", kImageTypePNG) WithTitle:@"暂无数据"];
    }else{
        [self isShouldSetHiddenEmptyView:YES];
    }
    return self.dataArray.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 150;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    static NSString *cellName = @"DailyListCellIndex";
    RMDailyListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if(cell ==nil){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"RMDailyListTableViewCell" owner:self options:nil] lastObject];
    }
    RMPublicModel *model = [self.dataArray objectAtIndex:indexPath.row];
    [cell.headImage sd_setImageWithURL:[NSURL URLWithString:model.pic] placeholderImage:LOADIMAGE(@"rb_loadingImg", kImageTypePNG)];
    cell.movieName.text = model.name;
    cell.playCount.text = model.sum_i_hits;
    cell.movieKind.text = [NSString stringWithFormat:@"分类:%@",model.video_type];
    [(RMImageView *)cell.TopImage addTopNumber:[model.topNum intValue]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    RMPublicModel *model = [self.dataArray objectAtIndex:indexPath.row];
    if([self.delegate respondsToSelector:@selector(selectTVTableViewCellWithIndex: andStringID:)])
    {
        [self.delegate selectTVTableViewCellWithIndex:indexPath.row andStringID:model.video_id];
    }
}

#pragma mark -
#pragma mark Scroll View Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.mainTableView tableViewDidDragging];
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    NSInteger returnKey = [self.mainTableView tableViewDidEndDragging];
    
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

- (void)updateThread:(id)sender
{
    int index = [sender intValue];
    switch (index) {
        case k_RETURN_DO_NOTHING://不执行操作
        {
            
        }
            break;
        case k_RETURN_REFRESH://刷新
        {
            RMAFNRequestManager *manager = [[RMAFNRequestManager alloc] init];
            manager.delegate = self;
            [manager getTopListWithVideoTpye:@"2" andTopType:self.downLoadTopType searchPageNumber:@"1" andCount:@"10"];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)requestFinishiDownLoadWith:(NSMutableArray *)data{
    if (data.count==0) {
        [SVProgressHUD showErrorWithStatus:@"电视剧暂无数据"];
        return;
    }
    [SVProgressHUD dismiss];
    self.dataArray = data;
    [self.mainTableView reloadData];
    [self.mainTableView reloadData:NO];
}

- (void)requestError:(NSError *)error{
    [SVProgressHUD showErrorWithStatus:@"下载失败"];
}


@end
