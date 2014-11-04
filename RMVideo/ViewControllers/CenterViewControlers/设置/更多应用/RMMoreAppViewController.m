//
//  RMMoreAppViewController.m
//  RMVideo
//
//  Created by 润华联动 on 14-10-22.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMMoreAppViewController.h"
#import "RMMoreAPPTableViewCell.h"

@interface RMMoreAppViewController ()<UITableViewDelegate,UITableViewDataSource,RMMoreAPPTableViewCellDelegate,RMAFNRequestManagerDelegate> {
    NSMutableArray * dataArr;
}

@end

@implementation RMMoreAppViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    RMAFNRequestManager * request = [[RMAFNRequestManager alloc] init];
    [request getMoreAppSpread];
    request.delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    dataArr = [[NSMutableArray alloc] init];
    
    self.title = @"更多应用";
    rightBarButton.hidden = YES;
    [leftBarButton setImage:[UIImage imageNamed:@"backup_img"] forState:UIControlStateNormal];
    [self setExtraCellLineHidden:self.mainTableView];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [dataArr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdetifier = @"CELLIDENTIFIER";
    RMMoreAPPTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdetifier];
    if(cell==nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"RMMoreAPPTableViewCell" owner:self options:nil] lastObject];
        cell.backgroundColor = [UIColor clearColor];
    }
    cell.delegate = self;
    
    RMPublicModel * model = [dataArr objectAtIndex:indexPath.row];
    [cell.headImage sd_setImageWithURL:[NSURL URLWithString:model.appPic] placeholderImage:nil];
    cell.titleLable.text = model.appName;
    cell.openBtn.tag = indexPath.row;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}

- (void)cellBtnSelectWithIndex:(NSInteger)index{
    RMPublicModel * model = [dataArr objectAtIndex:index];
    NSString *evaluateString = [NSString stringWithFormat:@"%@",model.ios];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:evaluateString]];
}

#pragma mark- request RMAFNRequestManagerDelegate

- (void)requestFinishiDownLoadWith:(NSMutableArray *)data {
    dataArr = data;
    [self.mainTableView reloadData];
}

- (void)requestError:(NSError *)error {
    NSLog(@"error:%@",error);
}

#pragma mark - base Method

- (void) navgationBarButtonClick:(UIBarButtonItem *)sender{
    if(sender.tag==1){
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
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
