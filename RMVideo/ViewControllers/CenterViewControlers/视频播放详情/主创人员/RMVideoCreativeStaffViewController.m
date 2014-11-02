//
//  RMVideoCreativeStaffViewController.m
//  RMVideo
//
//  Created by runmobile on 14-10-17.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMVideoCreativeStaffViewController.h"
#import "RMVideoCreativeStaffCell.h"

#import "RMAFNRequestManager.h"
#import "RMPublicModel.h"
#import "UIImageView+AFNetworking.h"
#import "PullToRefreshTableView.h"

@interface RMVideoCreativeStaffViewController ()<UITableViewDataSource,UITableViewDelegate,CreativeStaffCellDelegate,RMAFNRequestManagerDelegate> {
    NSMutableArray * dataArr;
    NSMutableDictionary * starTypeDic;
}

@end

@implementation RMVideoCreativeStaffViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    dataArr = [[NSMutableArray alloc] init];
    starTypeDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"导演", @"1", @"演员", @"2", @"主持人", @"6", @"编剧", @"7", nil];

    PullToRefreshTableView * tableView;
    if (IS_IPHONE_4_SCREEN | IS_IPHONE_5_SCREEN){
        tableView = [[PullToRefreshTableView alloc] initWithFrame:CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleHeight - 205 - 82)];
    }else if (IS_IPHONE_6_SCREEN){

    }else if (IS_IPHONE_6p_SCREEN){
        tableView = [[PullToRefreshTableView alloc] initWithFrame:CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleHeight - 267 - 82)];
    }
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.tag = 101;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableView setIsCloseHeader:NO];
    [tableView setIsCloseFooter:NO];
    [self.view addSubview:tableView];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([dataArr count]/3 == 0){
        return [dataArr count]/3;
    }else if ([dataArr count]/3 == 1){
        return ([dataArr count] + 2) / 3;
    }else {
        return ([dataArr count] + 1) / 3;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * CellIdentifier = @"RMVideoCreativeStaffCellIdentifier";
    RMVideoCreativeStaffCell * cell = (RMVideoCreativeStaffCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (! cell){
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"RMVideoCreativeStaffCell" owner:self options:nil];
        cell = [array objectAtIndex:0];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.backgroundColor = [UIColor clearColor];
        cell.delegate = self;
    }
    NSMutableDictionary * dic_left = [dataArr objectAtIndex:indexPath.row * 3];
    NSMutableDictionary * dic_center = [dataArr objectAtIndex:indexPath.row * 3 +1];
    NSMutableDictionary * dic_right = [dataArr objectAtIndex:indexPath.row * 3 +2];
    
    cell.leftTitle.text = [dic_left objectForKey:@"name"];
    cell.centerTitle.text = [dic_center objectForKey:@"name"];
    cell.rightTitle.text = [dic_right objectForKey:@"name"];
    
    [cell.leftHeadImg sd_setImageWithURL:[NSURL URLWithString:[dic_left objectForKey:@"pic_url"]] placeholderImage:nil];
    [cell.centerHeadImg sd_setImageWithURL:[NSURL URLWithString:[dic_center objectForKey:@"pic_url"]] placeholderImage:nil];
    [cell.rightHeadImg sd_setImageWithURL:[NSURL URLWithString:[dic_right objectForKey:@"pic_url"]] placeholderImage:nil];
    
    cell.leftAddImg.identifierString = [dic_left objectForKey:@"tag_id"];
    cell.centerAddImg.identifierString = [dic_center objectForKey:@"tag_id"];
    cell.rightAddImg.identifierString = [dic_right objectForKey:@"tag_id"];
    
    cell.leftRotatingTitle.text = [starTypeDic objectForKey:[dic_left objectForKey:@"type"]];
    cell.centerRotatingTitle.text = [starTypeDic objectForKey:[dic_center objectForKey:@"type"]];
    cell.rightRotatingTitle.text = [starTypeDic objectForKey:[dic_right objectForKey:@"type"]];

    [UtilityFunc rotatingView:cell.leftRotatView];
    [UtilityFunc rotatingView:cell.centerRotatView];
    [UtilityFunc rotatingView:cell.rightRotatView];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([dataArr count]/3 == 0){
        if (indexPath.row == [dataArr count]/3){
            return 170;
        }else {
            return 150;
        }
    }else if ([dataArr count]/3 == 1){
        if (indexPath.row == ([dataArr count] + 2) / 3){
            return 170;
        }else {
            return 150;
        }
    }else {
        if (indexPath.row == ([dataArr count] + 1) / 3){
            return 170;
        }else {
            return 150;
        }
    }
}

- (void)clickCreativeStaffCellAddMyChannelMethod:(RMImageView *)imageView {
    RMAFNRequestManager * request = [[RMAFNRequestManager alloc] init];
    [request getJoinMyChannelWithToken:testToken andID:imageView.identifierString];
    request.delegate = self;
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
    
}

- (void)requestError:(NSError *)error {
    
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
