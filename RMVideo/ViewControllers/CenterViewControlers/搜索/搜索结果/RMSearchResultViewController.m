//
//  RMSearchResultViewController.m
//  RMVideo
//
//  Created by runmobile on 14-11-3.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMSearchResultViewController.h"
#import "PullToRefreshTableView.h"
#import "RMSearchCell.h"
#import "RMVideoPlaybackDetailsViewController.h"

@interface RMSearchResultViewController ()<UITableViewDataSource,UITableViewDelegate,RMAFNRequestManagerDelegate> {
    NSInteger pageCount;
    NSInteger AltogetherRows;               //总共有多少条数据
    BOOL isRefresh;
    
}
@property (nonatomic, strong) PullToRefreshTableView * tableView;
@property (nonatomic, strong) RMAFNRequestManager * manager;
@property (nonatomic, strong) NSString * keyWord;
@property (nonatomic, strong) NSMutableArray * dataArr;

@end

@implementation RMSearchResultViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [Flurry logEvent:@"VIEW_SearchResult" timed:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [Flurry endTimedEvent:@"VIEW_SearchResult" withParameters:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.dataArr = [[NSMutableArray alloc] init];
    [self showEmptyViewWithImage:LOADIMAGE(@"no_search_result", kImageTypePNG) WithTitle:@"没有搜索到你要找的视频"];
    RMPublicModel * model = [self.resultData objectAtIndex:0];
    if ([model.list isKindOfClass:[NSString class]]){
        
    }else{
        self.keyWord = model.keyword;
        self.dataArr = [NSMutableArray arrayWithArray:model.list];
        AltogetherRows = [model.rows integerValue];
    }
    
    [leftBarButton setBackgroundImage:LOADIMAGE(@"backup_img", kImageTypePNG) forState:UIControlStateNormal];
    rightBarButton.hidden = YES;
    [self setTitle:@"搜索结果"];
    
    self.manager = [[RMAFNRequestManager alloc] init];
    self.manager.delegate = self;
    
    self.tableView = [[PullToRefreshTableView alloc] initWithFrame:CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleHeight - 44)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tag = 101;
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.tableView];
    isRefresh = YES;
    pageCount = 1;
}

#pragma mark - UITableViewDataSource UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.dataArr.count == 0){
        [self isShouldSetHiddenEmptyView:NO];
    }else{
        [self isShouldSetHiddenEmptyView:YES];
    }
    if (self.dataArr.count < 20) {
        self.tableView.isCloseFooter = YES;
    }else{
        self.tableView.isCloseFooter = NO;
    }
    return [self.dataArr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * CellIdentifier = @"RMSearchResultCellIdentifier";
    RMSearchCell * cell = (RMSearchCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (! cell) {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"RMSearchCell" owner:self options:nil];
        cell = [array objectAtIndex:0];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.backgroundColor = [UIColor clearColor];
    }
    cell.type.text = @"";
    
    switch ([[[self.dataArr objectAtIndex:indexPath.row] objectForKey:@"video_type"] integerValue]) {
        case 1:{
            cell.type.text = @"电影";
            break;
        }
        case 2:{
            cell.type.text = @"电视剧";
            break;
        }
        case 3:{
            cell.type.text = @"综艺";
            break;
        }
            
        default:
            cell.type.text = @"";
            break;
    }
    [cell.headImg sd_setImageWithURL:[NSURL URLWithString:[[self.dataArr objectAtIndex:indexPath.row] objectForKey:@"pic"]] placeholderImage:LOADIMAGE(@"Default85_135", kImageTypePNG)];
    cell.name.text = [[self.dataArr objectAtIndex:indexPath.row] objectForKey:@"name"];
    [cell.searchFirstRateView setImagesDeselected:@"mx_rateEmpty_img" partlySelected:@"mx_rateEmpty_img" fullSelected:@"mx_rateFull_img" andDelegate:nil];
    [cell.searchFirstRateView displayRating:[[[self.dataArr objectAtIndex:indexPath.row] objectForKey:@"gold"] integerValue]];
    cell.hits.text = [NSString stringWithFormat:@"点击量:%@",[[self.dataArr objectAtIndex:indexPath.row] objectForKey:@"hits"]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 155;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RMVideoPlaybackDetailsViewController * videoPlaybackDetailsCtl = [[RMVideoPlaybackDetailsViewController alloc] init];
    [self.navigationController pushViewController:videoPlaybackDetailsCtl animated:YES];
    videoPlaybackDetailsCtl.currentVideo_id  = [[self.dataArr objectAtIndex:indexPath.row] objectForKey:@"video_id"];
    [videoPlaybackDetailsCtl setAppearTabBarNextPopViewController:kNO];
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
            pageCount = 1;
            isRefresh = YES;
            [self startRequest];
            break;
        }
        case k_RETURN_LOADMORE://加载更多
        {
            if (pageCount * 20 > AltogetherRows){
                [self.tableView reloadData:YES];
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

#pragma mark - base Method

- (void)navgationBarButtonClick:(UIBarButtonItem *)sender {
    switch (sender.tag) {
        case 1:{
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
                [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];
            }
            [self dismissViewControllerAnimated:YES completion:^{
                 
            }];
            break;
        }
        case 2:{
            
            break;
        }

        default:
            break;
    }
}

#pragma mark - request RMAFNRequestManagerDelegate

- (void)startRequest {
    [self.manager getSearchVideoWithKeyword:[self.keyWord stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] Page:[NSString stringWithFormat:@"%d",pageCount] count:@"20"];
}

- (void)requestFinishiDownLoadWith:(NSMutableArray *)data {
    if ([data count] == 0){
        self.tableView.isCloseFooter = YES;
        return;
    }
    self.tableView.isCloseFooter = NO;
    RMPublicModel * model = [data objectAtIndex:0];
    AltogetherRows = [model.rows integerValue];
    if (isRefresh){
        [self.dataArr removeAllObjects];
        for (int i=0; i<[model.list count]; i++){
            [self.dataArr addObject:[model.list objectAtIndex:i]];
        }
        if (self.dataArr.count < 20) {
            self.tableView.isCloseFooter = YES;
        }else{
            self.tableView.isCloseFooter = NO;
        }
    }else{
        for (int i=0; i<[model.list count]; i++){
            [self.dataArr addObject:[model.list objectAtIndex:i]];
        }
    }
    [self.tableView reloadData:NO];
}

- (void)requestError:(NSError *)error {
    [self.tableView reloadData:NO];
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
