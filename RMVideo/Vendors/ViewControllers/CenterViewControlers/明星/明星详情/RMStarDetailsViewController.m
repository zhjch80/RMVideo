//
//  RMStarDetailsViewController.m
//  RMVideo
//
//  Created by runmobile on 14-10-13.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMStarDetailsViewController.h"
#import "HMSegmentedControl.h"

#import "RMStarTeleplayListViewController.h"
#import "RMStarFilmListViewController.h"
#import "RMStarVarietyListViewController.h"

#define maskView_TAG            101

#define kFold_on                @"fold_on"
#define kFold_off               @"fold_off"

@interface RMStarDetailsViewController (){
    NSString * foldType;
}
@property (nonatomic, strong) NSMutableString * star_id;

@property (nonatomic, copy) HMSegmentedControl *segmentedControl;

@property RMStarTeleplayListViewController * starTeleplayListCtl;
@property RMStarFilmListViewController * starFilmListCtl;
@property RMStarVarietyListViewController * starVarietyListCtl;

@end

@implementation RMStarDetailsViewController
@synthesize segmentedControl = _segmentedControl;

@synthesize starTeleplayListCtl = _starTeleplayListCtl;
@synthesize starFilmListCtl = _starFilmListCtl;
@synthesize starVarietyListCtl = _starVarietyListCtl;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
 
    foldType = [[NSString alloc] init];
    foldType = kFold_off;
    
    [self setTitle:@"明星"];
    [leftBarButton setBackgroundImage:LOADIMAGE(@"backup_img", kImageTypePNG) forState:UIControlStateNormal];
    rightBarButton.hidden = YES;
    
    self.headView.frame = CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth, 140);
    self.headView.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1];
    self.headSubView.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1];
    
    self.starName.backgroundColor = [UIColor clearColor];
    
    if (IS_IPHONE_4_SCREEN | IS_IPHONE_5_SCREEN){
        self.starIntrduce.frame = CGRectMake(0, 20, 200, 60);
        self.headSubView.frame = CGRectMake(120, 10, 204, 129);
        self.foldMarkTitle.frame = CGRectMake(130, 96, 31, 21);
        self.foldImg.frame = CGRectMake(164, 102, 12, 8);
        self.foldBtn.frame = CGRectMake(130, 93, 56, 28);
    }else if (IS_IPHONE_6_SCREEN){
        self.starIntrduce.frame = CGRectMake(0, 20, 240, 60);
        [self.starIntrduce setContentOffset:CGPointMake(0, 0) animated:YES];
        self.starIntrduce.bouncesZoom = NO;
        self.headSubView.frame = CGRectMake(120, 10, 244, 129);
        self.foldMarkTitle.frame = CGRectMake(170, 96, 31, 21);
        self.foldImg.frame = CGRectMake(204, 102, 12, 8);
        self.foldBtn.frame = CGRectMake(170, 93, 56, 28);
    }
    
    [self.headSubChannelView.layer setCornerRadius:8.0];
    self.starIntrduce.scrollEnabled = YES;
    
    UIView * maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleHeight - 180)];
    maskView.alpha = 0.4;
    maskView.userInteractionEnabled = YES;
    maskView.hidden = YES;
    maskView.tag = maskView_TAG;
    maskView.backgroundColor = [UIColor blackColor];
    [maskView bringSubviewToFront:self.starFilmListCtl.view];
    [maskView bringSubviewToFront:self.starTeleplayListCtl.view];
    [maskView bringSubviewToFront:self.starVarietyListCtl.view];
    [self.contentView addSubview:maskView];
    
    _segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"", @"", @""] withIdentifierType:@"starIdentifier"];
    __block RMStarDetailsViewController *blockSelf = self;
    
    [_segmentedControl setIndexChangeBlock:^(NSUInteger index) {
        [blockSelf.segmentedControl ChangeLabelTitleColor:index];
        switch (index) {
            case 0:{
                //默认进第一个
                if (! blockSelf.starFilmListCtl){
                    blockSelf.starFilmListCtl = [[RMStarFilmListViewController alloc] init];
                }
                blockSelf.starFilmListCtl.view.frame = CGRectMake(0, 40, [UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleHeight - 175);
                blockSelf.starFilmListCtl.starDetailsDelegate = blockSelf;
                [blockSelf.contentView insertSubview:blockSelf.starFilmListCtl.view belowSubview:maskView];
                break;
            }
            case 1:{
                if (! blockSelf.starTeleplayListCtl){
                    blockSelf.starTeleplayListCtl = [[RMStarTeleplayListViewController alloc] init];
                }
                blockSelf.starTeleplayListCtl.view.frame = CGRectMake(0, 40, [UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleHeight - 175);
                blockSelf.starTeleplayListCtl.starDetailsDelegate = blockSelf;
                [blockSelf.contentView insertSubview:blockSelf.starTeleplayListCtl.view belowSubview:maskView];
                break;
            }
            case 2:{
                if (! blockSelf.starVarietyListCtl){
                    blockSelf.starVarietyListCtl = [[RMStarVarietyListViewController alloc] init];
                }
                blockSelf.starVarietyListCtl.view.frame = CGRectMake(0, 40, [UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleHeight - 175);
                blockSelf.starVarietyListCtl.starDetailsDelegate = blockSelf;
                [blockSelf.contentView insertSubview:blockSelf.starVarietyListCtl.view belowSubview:maskView];
                break;
            }
                
            default:
                break;
        }
    }];
    _segmentedControl.frame = CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth, 40);
    [_segmentedControl setSelectedIndex:0];
    [_segmentedControl setBackgroundColor:[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1]];
    [_segmentedControl setTextColor:[UIColor clearColor]];
    [_segmentedControl setSelectionIndicatorColor:[UIColor clearColor]];
    [_segmentedControl setTag:3];
    [self.contentView addSubview:_segmentedControl];


}


#pragma mark - Base Method

- (void)navgationBarButtonClick:(UIBarButtonItem *)sender {
    switch (sender.tag) {
        case 1:{
            [self.navigationController popViewControllerAnimated:YES];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kAppearTabbar object:nil];
            break;
        }
        case 2:{
            
            break;
        }
            
        default:
            break;
    }
}

#pragma mark - buttonClick Method

- (IBAction)mbuttonClick:(UIButton *)sender {
    switch (sender.tag) {
        case 201:{
            NSLog(@"加入频道");

            break;
        }
        case 202:{
            if ([foldType isEqualToString:kFold_on]){
                //合上
                self.contentView.userInteractionEnabled = YES;
                ((UIView *)[self.view viewWithTag:maskView_TAG]).hidden = YES;
                [UIView animateWithDuration:0.3 animations:^{
                    if (IS_IPHONE_4_SCREEN | IS_IPHONE_5_SCREEN){
                        self.starIntrduce.frame = CGRectMake(0, 20, 200, 60);
                        self.headSubView.frame = CGRectMake(120, 10, 204, 129);
                        self.foldMarkTitle.frame = CGRectMake(130, 96, 31, 21);
                        self.foldImg.frame = CGRectMake(164, 102, 12, 8);
                        self.foldBtn.frame = CGRectMake(130, 93, 56, 28);
                    }else if (IS_IPHONE_6_SCREEN){
                        self.starIntrduce.frame = CGRectMake(0, 20, 240, 60);
                        self.headSubView.frame = CGRectMake(120, 10, 244, 129);
                        self.foldMarkTitle.frame = CGRectMake(170, 96, 31, 21);
                        self.foldImg.frame = CGRectMake(204, 102, 12, 8);
                        self.foldBtn.frame = CGRectMake(170, 93, 56, 28);
                    }
                } completion:^(BOOL finished) {
                    self.foldMarkTitle.text = @"展开";
                    self.foldImg.image = LOADIMAGE(@"mx_unfold",kImageTypePNG);
                    self.headSubChannelView.hidden = NO;
                }];
                foldType = kFold_off;
            }else if ([foldType isEqualToString:kFold_off]){
                //展开
                self.contentView.userInteractionEnabled = NO;
                self.headSubChannelView.hidden = YES;
                ((UIView *)[self.view viewWithTag:maskView_TAG]).hidden = NO;
                [((UIView *)[self.view viewWithTag:maskView_TAG]) bringSubviewToFront:self.view];
                [UIView animateWithDuration:0.3 animations:^{
                    if (IS_IPHONE_4_SCREEN | IS_IPHONE_5_SCREEN){
                        self.starIntrduce.frame = CGRectMake(0, 20, 200, [UtilityFunc shareInstance].globleHeight - 110);
                        self.headSubView.frame = CGRectMake(120, 10, 204, [UtilityFunc shareInstance].globleHeight - 54);
                        self.foldMarkTitle.frame = CGRectMake(130, [UtilityFunc shareInstance].globleHeight - 85, 31, 21);
                        self.foldImg.frame = CGRectMake(164, [UtilityFunc shareInstance].globleHeight - 78, 12, 8);
                        self.foldBtn.frame = CGRectMake(130, [UtilityFunc shareInstance].globleHeight - 85, 56, 28);
                    }else if (IS_IPHONE_6_SCREEN){
                        self.starIntrduce.frame = CGRectMake(0, 20, 240, [UtilityFunc shareInstance].globleHeight - 110);
                        self.headSubView.frame = CGRectMake(120, 10, 244, [UtilityFunc shareInstance].globleHeight - 54);
                        self.foldMarkTitle.frame = CGRectMake(170, [UtilityFunc shareInstance].globleHeight - 85, 31, 21);
                        self.foldImg.frame = CGRectMake(204, [UtilityFunc shareInstance].globleHeight - 78, 12, 8);
                        self.foldBtn.frame = CGRectMake(170, [UtilityFunc shareInstance].globleHeight - 85, 56, 28);
                    }
                } completion:^(BOOL finished) {
                    self.foldMarkTitle.text = @"收起";
                    self.foldImg.image = LOADIMAGE(@"mx_fold",kImageTypePNG);
                }];
                foldType = kFold_on;
            }
            break;
        }
  
        default:
            break;
    }
}

- (void)setStarID:(NSString *)star_id {
    self.star_id = [[NSMutableString alloc] initWithString:star_id];
    NSLog(@"传过来的明星tag_id:%@",self.star_id);
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
