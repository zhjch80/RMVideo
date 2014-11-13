//
//  RMMyDownLoadViewController.m
//  RMVideo
//
//  Created by 润华联动 on 14-10-22.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMMyDownLoadViewController.h"
#import "RMDownLoadTVSeriesDetailViewController.h"
#import "CustomVideoPlayerController.h"
#import "RMCustomNavViewController.h"

@interface RMMyDownLoadViewController ()

@end

@implementation RMMyDownLoadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"我的下载";
    isSeleltAllCell = YES;
    isEditing = YES; //编辑按钮为关闭状态
    [leftBarButton setImage:[UIImage imageNamed:@"backup_img"] forState:UIControlStateNormal];
    
    sunSliderSwitchView = [[SUNSlideSwitchView alloc] initWithFrame:CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleHeight-69)];
    sunSliderSwitchView.slideSwitchViewDelegate = self;
    //downLoading_noselectImage  downLoading_selectImage finish_downLoad_noselectImage finish_downLoad_selectImage
    sunSliderSwitchView.BGImgArr = [NSMutableArray arrayWithObjects:@"finish_downLoad_noselectImage",@"downLoading_noselectImage",nil];
    sunSliderSwitchView.SelectBtnImageArray = [NSMutableArray arrayWithObjects:@"finish_downLoad_selectImage",@"downLoading_selectImage", nil];
    downLoadingViewContr = [[RMDownLoadingViewController shared] init];
//    __unsafe_unretained RMMyDownLoadViewController *weekSelf = self;
    [downLoadingViewContr selectTableViewCellWithIndex:^(NSInteger index) {
//        RMDownLoadTVSeriesDetailViewController *TVSeriesDetailView = [[RMDownLoadTVSeriesDetailViewController alloc] init];
//        [weekSelf.navigationController pushViewController:TVSeriesDetailView animated:YES];
    }];
    [downLoadingViewContr delectCellArray:^(NSMutableArray *array) {
        UIButton *button = (UIButton *)[btnView viewWithTag:11];
        if(array.count>0){
            [button setImage:[UIImage imageNamed:@"undelect_all_btn"] forState:UIControlStateNormal];
            button.enabled = YES;
        }else{
            [button setImage:[UIImage imageNamed:@"nodelect_all_btn"] forState:UIControlStateNormal];
            button.enabled = NO;
        }

    }];
    finishDownViewContr = [[RMFinishDownViewController alloc] init];
    [finishDownViewContr selectTableViewCellWithIndex:^(NSString *movieName) {
        
        NSString *document = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *path = [document stringByAppendingPathComponent:@"DownLoadSuccess"];
        NSString *str = [NSString stringWithFormat:@"%@/%@.mp4",path,movieName];

        CustomVideoPlayerController *customVideo = [[CustomVideoPlayerController alloc] init];
        [customVideo createPlayerViewWithURL:str isPlayLocalVideo:YES];
        [customVideo createTopTool];
        
        [self presentViewController:customVideo animated:YES completion:nil];
    }];
    [finishDownViewContr delectCellArray:^(NSMutableArray *array) {
        UIButton *button = (UIButton *)[btnView viewWithTag:11];
        if(array.count>0){
            [button setImage:[UIImage imageNamed:@"undelect_all_btn"] forState:UIControlStateNormal];
            button.enabled = YES;
        }else{
            [button setImage:[UIImage imageNamed:@"nodelect_all_btn"] forState:UIControlStateNormal];
            button.enabled = NO;
        }
    }];
    sunSliderSwitchView.btnWidth = 145;
    sunSliderSwitchView.btnHeight = 30;
    if(IS_IPHONE_6p_SCREEN){
        /**
         *  btnHeight = 40;
            btnWidth =140
         */
    }
    [sunSliderSwitchView buildUI];

    [self.view insertSubview:sunSliderSwitchView belowSubview:btnView];
    
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downLoadSuccess) name:DownLoadSuccess_KEY object:nil];
    
}

- (void)downLoadSuccess{
    [self setRightBarBtnItemState];
}
- (void)creatDownLoadDetailViewControllerWithController:(UIViewController *)viewControl{
//    RMDownLoadTVSeriesDetailViewController *TVSeriesDetailView = [[RMDownLoadTVSeriesDetailViewController alloc] init];
//    [viewControl.navigationController pushViewController:TVSeriesDetailView animated:YES];
}

- (void)EditingViewBtnClick:(UIButton *)sender{
    //全选
    if(sender.tag == 10){
        
        if(isSeleltAllCell){
            [sender setImage:LOADIMAGE(@"uncancle_select_all", kImageTypePNG) forState:UIControlStateNormal];
            ((UIButton *)[btnView viewWithTag:11]).enabled = YES;
            [((UIButton *)[btnView viewWithTag:11]) setImage:LOADIMAGE(@"undelect_all_btn", kImageTypePNG) forState:UIControlStateNormal];

        }
        else{
            [sender setImage:LOADIMAGE(@"unselect_all_btn", kImageTypePNG) forState:UIControlStateNormal];
            ((UIButton *)[btnView viewWithTag:11]).enabled = NO;
            [((UIButton *)[btnView viewWithTag:11]) setImage:LOADIMAGE(@"nodelect_all_btn", kImageTypePNG) forState:UIControlStateNormal];
        }

        if(selectViewControl == 0){
            
            [finishDownViewContr selectAllTableViewCellWithState:isSeleltAllCell];
        }
        else{
            
            [downLoadingViewContr selectAllTableViewCellWithState:isSeleltAllCell];
        }
        isSeleltAllCell = !isSeleltAllCell;
    }
    //删除
    else{
        if (selectViewControl == 0 && !isEditing) {
            //当开启编辑状态的时候才进行结束cell的动画
            [finishDownViewContr deleteAllTableViewCell];
        } else if (selectViewControl == 1 && !isEditing) {
            [downLoadingViewContr deleteAllTableViewCell];
        }
        [self setRightBarBtnItemState];
        isEditing = YES;
        [sender setImage:[UIImage imageNamed:@"nodelect_all_btn"] forState:UIControlStateNormal];
        [(UIButton *)[btnView viewWithTag:10] setImage:LOADIMAGE(@"unselect_all_btn", kImageTypePNG) forState:UIControlStateNormal];
        sender.enabled = NO;
        btnView.frame = CGRectMake(0, [UtilityFunc shareInstance].globleAllHeight, [UtilityFunc shareInstance].globleWidth, 49);
    }
    
}


#pragma mark - 滑动tab视图代理方法
- (NSUInteger)numberOfTab:(SUNSlideSwitchView *)view {
    return 2;
}

- (UIViewController *)slideSwitchView:(SUNSlideSwitchView *)view viewOfTab:(NSUInteger)number {
    if (number == 0) {
        return finishDownViewContr;
    } else if (number == 1) {
        return downLoadingViewContr;
    } else {
        return nil;
    }
}

- (void)slideSwitchView:(SUNSlideSwitchView *)view panLeftEdge:(UIPanGestureRecognizer *)panParam {
    NSLog(@"left");
}

- (void)slideSwitchView:(SUNSlideSwitchView *)view didselectTab:(NSUInteger)number {
    [self setRightBarBtnItemImageWith:YES];
    selectViewControl = number;
    [self setRightBarBtnItemState];
    isSeleltAllCell = YES;
    if (number == 0 && !isEditing) {
        //当开启编辑状态的时候才进行结束cell的动画
        [[NSNotificationCenter defaultCenter] postNotificationName:kDownLoadingControEndEditing object:nil];
    } else if (number == 1 && !isEditing) {
        [[NSNotificationCenter defaultCenter ] postNotificationName:kFinishViewControEndEditing object:nil];
    }
    isEditing = YES;
    UIButton *button = (UIButton *)[btnView viewWithTag:11];
    [button setImage:[UIImage imageNamed:@"nodelect_all_btn"] forState:UIControlStateNormal];
    button.enabled = NO;
    [(UIButton *)[btnView viewWithTag:10] setImage:LOADIMAGE(@"unselect_all_btn", kImageTypePNG) forState:UIControlStateNormal];
    btnView.frame = CGRectMake(0, [UtilityFunc shareInstance].globleAllHeight, [UtilityFunc shareInstance].globleWidth, 49);
}


- (void) navgationBarButtonClick:(UIBarButtonItem *)sender{
    
    if(sender.tag==1){
        if (selectViewControl == 1 && !isEditing) {
            [[NSNotificationCenter defaultCenter ] postNotificationName:kDownLoadingControEndEditing object:nil];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        [self setRightBarBtnItemImageWith:!isEditing];
        if(isEditing){
            btnView.frame = CGRectMake(0, [UtilityFunc shareInstance].globleAllHeight-49-64, [UtilityFunc shareInstance].globleWidth, 49);
            if(selectViewControl==0)
                [[NSNotificationCenter defaultCenter] postNotificationName:kFinishViewControStartEditing object:nil];
            else
                [[NSNotificationCenter defaultCenter] postNotificationName:kDownLoadingControStartEditing object:nil];
        }
        else{
            
            btnView.frame = CGRectMake(0, [UtilityFunc shareInstance].globleAllHeight, [UtilityFunc shareInstance].globleWidth, 49);
            isSeleltAllCell = YES;
            UIButton *button = (UIButton *)[btnView viewWithTag:11];
            [button setImage:[UIImage imageNamed:@"nodelect_all_btn"] forState:UIControlStateNormal];
            button.enabled = NO;
            [(UIButton *)[btnView viewWithTag:10] setImage:LOADIMAGE(@"unselect_all_btn", kImageTypePNG) forState:UIControlStateNormal];
            if(selectViewControl==0)
                [[NSNotificationCenter defaultCenter ] postNotificationName:kFinishViewControEndEditing object:nil];
            else
                [[NSNotificationCenter defaultCenter] postNotificationName:kDownLoadingControEndEditing object:nil];
        }
        isEditing = !isEditing;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setRightBarBtnItemState{
    NSInteger count = 0;
    if(selectViewControl==0){
        count = finishDownViewContr.dataArray.count;
    }else{
        count = downLoadingViewContr.dataArray.count;
    }
    if(count>0){
        rightBarButton.hidden = NO;
    }else{
        rightBarButton.hidden = YES;
    }

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
