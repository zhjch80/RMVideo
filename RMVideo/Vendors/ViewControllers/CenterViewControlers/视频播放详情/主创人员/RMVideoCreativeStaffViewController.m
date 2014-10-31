//
//  RMVideoCreativeStaffViewController.m
//  RMVideo
//
//  Created by runmobile on 14-10-17.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMVideoCreativeStaffViewController.h"
#import "RMVideoCreativeStaffCell.h"

@interface RMVideoCreativeStaffViewController ()<UITableViewDataSource,UITableViewDelegate,CreativeStaffCellDelegate>

@end

@implementation RMVideoCreativeStaffViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UITableView * tableView;
    if (IS_IPHONE_4_SCREEN | IS_IPHONE_5_SCREEN){
        tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleHeight - 205 - 82) style:UITableViewStylePlain];
    }else if (IS_IPHONE_6_SCREEN){

    }else if (IS_IPHONE_6p_SCREEN){
        tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleHeight - 267 - 82) style:UITableViewStylePlain];
    }
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableView];
    
    
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
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
    
    [UtilityFunc rotatingView:cell.leftRotatView];
    
    [UtilityFunc rotatingView:cell.centerRotatView];

    [UtilityFunc rotatingView:cell.rightRotatView];

    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 150.0;
}

- (void)startCellDidSelectWithIndex:(NSInteger)index {
    NSLog(@"加入频道");
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
