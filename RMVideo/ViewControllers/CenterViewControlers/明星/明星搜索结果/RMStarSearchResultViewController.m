//
//  RMStarSearchResultViewController.m
//  RMVideo
//
//  Created by runmobile on 14-11-3.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMStarSearchResultViewController.h"
#import "RMStarSearchResultCell.h"
#import "PullToRefreshTableView.h"
#import "RMStarDetailsViewController.h"

@interface RMStarSearchResultViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) PullToRefreshTableView * tableView;

@end

@implementation RMStarSearchResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [leftBarButton setBackgroundImage:LOADIMAGE(@"backup_img", kImageTypePNG) forState:UIControlStateNormal];
    rightBarButton.hidden = YES;
    [self setTitle:@"搜索结果"];
    
    NSLog(@"count:%d \n obj:%@",self.resultData.count,self.resultData);
    
    self.tableView = [[PullToRefreshTableView alloc] initWithFrame:CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleHeight - 44)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tag = 101;
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.tableView];

}

#pragma mark - UITableViewDataSource UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.resultData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * CellIdentifier = @"RMStarSearchResultCellIdentifier";
    RMStarSearchResultCell * cell = (RMStarSearchResultCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (! cell) {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"RMStarSearchResultCell" owner:self options:nil];
        cell = [array objectAtIndex:0];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.backgroundColor = [UIColor clearColor];
    }
    
    RMPublicModel * model = [self.resultData objectAtIndex:indexPath.row];
    [cell.headImg sd_setImageWithURL:[NSURL URLWithString:model.pic_url] placeholderImage:nil];
    cell.name.text = model.name;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 110;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RMPublicModel * model = [self.resultData objectAtIndex:indexPath.row];
    RMStarDetailsViewController * starDetailsCtl = [[RMStarDetailsViewController alloc] init];
    [self.navigationController pushViewController:starDetailsCtl animated:YES];
    [starDetailsCtl setStarID:model.tag_id];
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
            [self.tableView reloadData:YES];
            break;
        }
        case k_RETURN_LOADMORE://加载更多
        {
            [self.tableView reloadData:YES];
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
