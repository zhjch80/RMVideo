//
//  RMConstellationTabViewController.m
//  yemianbuju
//
//  Created by 润华联动 on 14-12-17.
//  Copyright (c) 2014年 润华联动. All rights reserved.
//

#import "RMConstellationTabViewController.h"

@interface RMConstellationTabViewController (){
    NSString *likeTypeString;
    NSString *constellationString;
}

@end

@implementation RMConstellationTabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [leftBarButton setImage:[UIImage imageNamed:@"backup_img"] forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)navgationBarButtonClick:(UIBarButtonItem *)sender{
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)likeGenreBtnClick:(UIButton *)sender {
    //重口味
    if(sender.tag == 200){
        [SmallFreshBtn setImage:[UIImage imageNamed:@"no-select_cellImage"] forState:UIControlStateNormal];
        [HeavyTasteBtn setImage:[UIImage imageNamed:@"select_cellImage"] forState:UIControlStateNormal];
    }
    //小清新
    else{
        [HeavyTasteBtn setImage:[UIImage imageNamed:@"no-select_cellImage"] forState:UIControlStateNormal];
        [SmallFreshBtn setImage:[UIImage imageNamed:@"select_cellImage"] forState:UIControlStateNormal];
    }
    likeTypeString = sender.titleLabel.text;
}

- (IBAction)constellation:(UIButton *)sender {
    
    constellationString = sender.titleLabel.text;
    
    [sender setBackgroundImage:[UIImage imageNamed:@"redbg"] forState:UIControlStateNormal];
    [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    for(int i=100;i<112;i++){
        if(i==sender.tag) continue;
        UIButton *button = (UIButton *)[self.view viewWithTag:i];
        [button setBackgroundImage:[UIImage imageNamed:@"bg"] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }

}

- (IBAction)finishBtnClick:(UIButton *)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"completethesurvey" object:nil];
    [self.navigationController popToRootViewControllerAnimated:YES];
}
@end
