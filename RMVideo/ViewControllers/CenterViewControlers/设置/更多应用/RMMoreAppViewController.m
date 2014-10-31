//
//  RMMoreAppViewController.m
//  RMVideo
//
//  Created by 润华联动 on 14-10-22.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMMoreAppViewController.h"
#import "RMMoreAPPTableViewCell.h"

@interface RMMoreAppViewController ()<UITableViewDelegate,UITableViewDataSource,RMMoreAPPTableViewCellDelegate>

@end

@implementation RMMoreAppViewController

- (void) navgationBarButtonClick:(UIBarButtonItem *)sender{
    
    if(sender.tag==1){
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"更多应用";
    rightBarButton.hidden = YES;
    [leftBarButton setImage:[UIImage imageNamed:@"backup_img"] forState:UIControlStateNormal];
    [self setExtraCellLineHidden:self.mainTableView];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdetifier = @"CELLIDENTIFIER";
    RMMoreAPPTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdetifier];
    if(cell==nil)
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"RMMoreAPPTableViewCell" owner:self options:nil] lastObject];
    }
    cell.delegate = self;
    cell.headImage.image = [UIImage imageNamed:@"003"];
    cell.openBtn.tag = indexPath.row;
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}

- (void)cellBtnSelectWithIndex:(NSInteger)index{
    NSLog(@"index:%d",index);
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
