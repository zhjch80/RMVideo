//
//  RMDownLoadBaseViewController.m
//  RMVideo
//
//  Created by 润华联动 on 14-10-22.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMDownLoadBaseViewController.h"
#import "UtilityFunc.h"
#import "RMFinishDownTableViewCell.h"

@interface RMDownLoadBaseViewController ()

@end

@implementation RMDownLoadBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    rightBarButton.frame = CGRectMake(0, 0, 35, 20);
    [rightBarButton setBackgroundImage:LOADIMAGE(@"editing_btn_image", kImageTypePNG) forState:UIControlStateNormal];

    showMemoryLable = [[UILabel alloc] initWithFrame:CGRectMake(0, [UtilityFunc shareInstance].globleHeight-44-25, [UtilityFunc shareInstance].globleWidth, 25)];
    showMemoryLable.backgroundColor = [UIColor colorWithRed:0.88 green:0.87 blue:0.81 alpha:1];
    showMemoryLable.textColor = [UIColor lightGrayColor];
    showMemoryLable.textAlignment = NSTextAlignmentCenter;
    showMemoryLable.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:12];
    float freeNum = [[UtilityFunc freeDiskSpace] floatValue];
    NSString *document = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [document stringByAppendingPathComponent:@"DownLoadSuccess"];
    float alreadyCache = [UtilityFunc folderSizeAtPath:path];
    if((freeNum/1024/1024)>1024){
        freeNum = freeNum/1024/1024/1024-0.2;
        showMemoryLable.text =[NSString stringWithFormat:@"已缓存%.2fM,剩余%.2fG可用",alreadyCache,freeNum];
    }
    else{
        freeNum = freeNum/1024/1024-200;
        showMemoryLable.text =[NSString stringWithFormat:@"已缓存%.2fM,剩余%.0fM可用",alreadyCache,freeNum];
    }
    [self.view addSubview:showMemoryLable];
    
    btnView = [[UIView alloc] initWithFrame:CGRectMake(0, [UtilityFunc shareInstance].globleAllHeight, [UtilityFunc shareInstance].globleWidth, 49)];
    for (int i = 0;i<2; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(i*([UtilityFunc shareInstance].globleWidth/2), 0, [UtilityFunc shareInstance].globleWidth/2, 49);
        if(i==0){
            [button setImage:[UIImage imageNamed:@"unselect_all_btn"] forState:UIControlStateNormal];
        }
        else{
            [button setImage:[UIImage imageNamed:@"nodelect_all_btn"] forState:UIControlStateNormal];
            [button setBackgroundColor:[UIColor colorWithWhite:0.9 alpha:0.9]];
            button.enabled = NO;
        }
        button.tag = i+10;
        [button addTarget:self action:@selector(EditingViewBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [btnView addSubview:button];
    }
    [self.view addSubview:btnView];
    [self setExtraCellLineHidden:self.mainTableView];
}
- (void)EditingViewBtnClick:(UIButton *)sender{
    
}

- (void) navgationBarButtonClick:(UIBarButtonItem *)sender{
    
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identifier = @"cellIIdentifier";
    RMFinishDownTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell==nil){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"RMFinishDownTableViewCell" owner:self options:nil] lastObject];
        if(isEditing)
            [cell setCellViewFrame];
    }
    [cell.editingImage setImage:[UIImage imageNamed:[cellEditingImageArray objectAtIndex:indexPath.row]]];
    return cell;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 140.f;
}
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)setRightBarBtnItemImageWith:(BOOL)state{
    if(!state){
        [rightBarButton setBackgroundImage:LOADIMAGE(@"cancle_btn_image", kImageTypePNG) forState:UIControlStateNormal];
    }
    else{
        [rightBarButton setBackgroundImage:LOADIMAGE(@"editing_btn_image", kImageTypePNG) forState:UIControlStateNormal];
    }
}

@end
