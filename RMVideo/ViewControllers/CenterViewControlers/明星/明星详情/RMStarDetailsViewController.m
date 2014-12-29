//
//  RMNewStarDetailsViewController.m
//  RMVideo
//
//  Created by runmobile on 14-12-16.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMStarDetailsViewController.h"
#import "RMSegmentedControl.h"
#import "RMStarTeleplayListViewController.h"
#import "RMStarFilmListViewController.h"
#import "RMStarVarietyListViewController.h"
#import "RMLoginViewController.h"
#import "RMCustomNavViewController.h"
#import "RMCustomPresentNavViewController.h"

typedef enum{
    selectedOneCtlStateType = 1,
    selectedTwoCtlStateType,
    selectedThreeCtlStateType,
    selectedUnknownCtlStateType
}SelectedStateCtlType;

typedef enum{
    requestIntroType = 1,
    requestAddMyChannelType,
    requestDeleteMyChannelType,
    requestCheckStarPropertyYype
}LoadType;

@interface RMStarDetailsViewController ()<SwitchSelectedMethodDelegate,RMAFNRequestManagerDelegate>{
    NSMutableArray * introDataArr;              //明星相关的数据
    NSMutableArray * csArray;                   //starIntroduction 的约束Arr
    NSMutableArray * CheckArr;                  //检查明星下面的标签
    
    BOOL isStarIntroductionClose;               //明星介绍是否关闭
    BOOL isStarAttentionMyChannel;              //明星是否添加到我的频道
    RMAFNRequestManager * manager;
}
@property (nonatomic, copy) RMSegmentedControl *segmentedControl;
@property (nonatomic, assign) SelectedStateCtlType selectedCtlType;
@property (nonatomic, assign) LoadType loadType;

@property RMStarTeleplayListViewController * starTeleplayListCtl;
@property RMStarFilmListViewController * starFilmListCtl;
@property RMStarVarietyListViewController * starVarietyListCtl;

@end

@implementation RMStarDetailsViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self startCheckStarProperty];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [leftBarButton setBackgroundImage:LOADIMAGE(@"backup_img", kImageTypePNG) forState:UIControlStateNormal];
    rightBarButton.hidden = YES;
    
    CheckArr = [[NSMutableArray alloc] init];
    introDataArr = [[NSMutableArray alloc] init];
    csArray = [[NSMutableArray alloc] init];
    isStarIntroductionClose = YES;
    
    self.aboveView = [[UIView alloc] init];
    self.aboveView.frame = CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth, 150);
    self.aboveView.backgroundColor = [UIColor clearColor];
    self.aboveView.userInteractionEnabled = YES;
    [self.view addSubview:self.aboveView];
    
    self.blackView = [[UIView alloc] init];
    self.blackView.frame = CGRectMake(120, 45, [UtilityFunc shareInstance].globleWidth - 130, 30);
    self.blackView.backgroundColor = [UIColor colorWithRed:0.15 green:0.15 blue:0.15 alpha:1];
    self.blackView.userInteractionEnabled = YES;
    [self.aboveView addSubview:self.blackView];
    
    self.starIntroduction = [[RMBaseTextView alloc] init];
    self.starIntroduction.frame = CGRectMake(120, 45, [UtilityFunc shareInstance].globleWidth - 130, 50);
    self.starIntroduction.editable = NO;
    self.starIntroduction.textColor = [UIColor whiteColor];
    self.starIntroduction.backgroundColor = [UIColor colorWithRed:0.15 green:0.15 blue:0.15 alpha:1];
    [self.aboveView addSubview:self.starIntroduction];

    self.addOrDeleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.addOrDeleteBtn.frame = CGRectMake(120, 105, 100, 30);
    [self.addOrDeleteBtn addTarget:self action:@selector(upsideButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    self.addOrDeleteBtn.tag = 101;
    [self.addOrDeleteBtn setBackgroundImage:LOADIMAGE(@"mx_join", kImageTypePNG) forState:UIControlStateNormal];
    [self.aboveView addSubview:self.addOrDeleteBtn];
    
    self.openOrCloseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.openOrCloseBtn.frame = CGRectMake([UtilityFunc shareInstance].globleWidth - 71, 112, 51, 16);
    [self.openOrCloseBtn addTarget:self action:@selector(upsideButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    self.openOrCloseBtn.tag = 102;
    [self.openOrCloseBtn setBackgroundImage:LOADIMAGE(@"mx_open", kImageTypePNG) forState:UIControlStateNormal];
    [self.aboveView addSubview:self.openOrCloseBtn];
    
    self.selectedCtlType = selectedUnknownCtlStateType;
    
}

/**
 *  判断明星标签下的属性   如果传入arr 为空 会有问题
 */
- (void)loadSegmentedWithArr:(NSMutableArray *)arr {
    _segmentedControl = [[RMSegmentedControl alloc] initWithSectionTitles:@[[arr objectAtIndex:0], [arr objectAtIndex:1], [arr objectAtIndex:2]] withIdentifierType:@"starIdentifier"];
    _segmentedControl.delegate = self;
    _segmentedControl.frame = CGRectMake(0, 150, [UIScreen mainScreen].bounds.size.width, 40);
    [_segmentedControl setSelectedIndex:0];
    [_segmentedControl setBackgroundColor:[UIColor colorWithRed:0.15 green:0.15 blue:0.15 alpha:1]];
    [_segmentedControl setTextColor:[UIColor clearColor]];
    [_segmentedControl setSelectionIndicatorColor:[UIColor clearColor]];
    [_segmentedControl setTag:3];
    [self.upsideView addSubview:_segmentedControl];
}

- (void)switchSelectedMethodWithValue:(int)value withTitle:(NSString *)title{
    switch (value) {
        case 0:{
            if ([title isEqualToString:@"电影"]){
                if (! self.starFilmListCtl){
                    self.starFilmListCtl = [[RMStarFilmListViewController alloc] init];
                }
                self.starFilmListCtl.starDetailsDelegate = self;
                [self.belowView addSubview:self.starFilmListCtl.view];
                self.starFilmListCtl.star_id = self.star_id;
            }else if ([title isEqualToString:@"电视剧"]){
                if (! self.starTeleplayListCtl){
                    self.starTeleplayListCtl = [[RMStarTeleplayListViewController alloc] init];
                }
                
                self.starTeleplayListCtl.starDetailsDelegate = self;
                [self.belowView addSubview:self.starTeleplayListCtl.view];
                self.starTeleplayListCtl.star_id = self.star_id;
            }else{
                if (! self.starVarietyListCtl){
                    self.starVarietyListCtl = [[RMStarVarietyListViewController alloc] init];
                }
                self.starVarietyListCtl.starDetailsDelegate = self;
                [self.belowView addSubview:self.starVarietyListCtl.view];
                self.starVarietyListCtl.star_id = self.star_id;
            }

            break;
        }
        case 1:{
            if ([title isEqualToString:@"电视剧"]){
                if (! self.starTeleplayListCtl){
                    self.starTeleplayListCtl = [[RMStarTeleplayListViewController alloc] init];
                }
                
                self.starTeleplayListCtl.starDetailsDelegate = self;
                [self.belowView addSubview:self.starTeleplayListCtl.view];
                self.starTeleplayListCtl.star_id = self.star_id;
            }else if ([title isEqualToString:@"综艺"]){
                if (! self.starVarietyListCtl){
                    self.starVarietyListCtl = [[RMStarVarietyListViewController alloc] init];
                }
                self.starVarietyListCtl.starDetailsDelegate = self;
                [self.belowView addSubview:self.starVarietyListCtl.view];
                self.starVarietyListCtl.star_id = self.star_id;
            }
    
            break;
        }
        case 2:{
            if (! self.starVarietyListCtl){
                self.starVarietyListCtl = [[RMStarVarietyListViewController alloc] init];
            }
            self.starVarietyListCtl.starDetailsDelegate = self;
            [self.belowView addSubview:self.starVarietyListCtl.view];
            self.starVarietyListCtl.star_id = self.star_id;
            break;
        }
            
        default:
            break;
    }
}

#pragma mark -刷新界面

- (void)refreshUI{
    RMPublicModel * model = [introDataArr objectAtIndex:0];
    [self setTitle:model.name];
    [self.starHeadImg sd_setImageWithURL:[NSURL URLWithString:model.pic_url] placeholderImage:LOADIMAGE(@"Default90_119", kImageTypePNG)];
    self.starName.text = model.name;
    self.starIntroduction.text = model.detail;
    
    if ([model.is_follow integerValue] == 1){
        [self.addOrDeleteBtn setBackgroundImage:LOADIMAGE(@"mx_exist", kImageTypePNG) forState:UIControlStateNormal];
        isStarAttentionMyChannel = YES;
    }else{
        [self.addOrDeleteBtn setBackgroundImage:LOADIMAGE(@"mx_join", kImageTypePNG) forState:UIControlStateNormal];
        isStarAttentionMyChannel = NO;
    }
    
    //刷新第一个标签下的内容
    NSMutableArray * arr = [NSMutableArray arrayWithArray:CheckArr];
    for (int i=0; i<[arr count]; i++){
        if ([[arr objectAtIndex:i] isEqualToString:@""]){
            [arr removeObjectAtIndex:i];
        }
    }
    [self switchSelectedMethodWithValue:0 withTitle:[arr objectAtIndex:0]];
}

#pragma mark - request 


/**
 *  判断明星标签下 电影 电视剧 综艺 是否有数据
 */
- (void)startCheckStarProperty {
    manager = [[RMAFNRequestManager alloc] init];
    self.loadType = requestCheckStarPropertyYype;
    [manager getCheckStarPropertyWithStar_id:self.star_id];
    manager.delegate = self;
}

/**
 *  请求明星相关数据
 */
- (void)startRequestStarData {
    CUSFileStorage *storage = [CUSFileStorageManager getFileStorage:CURRENTENCRYPTFILE];
    NSDictionary *dict = [storage objectForKey:UserLoginInformation_KEY];
    manager = [[RMAFNRequestManager alloc] init];
    self.loadType = requestIntroType;
    [manager getStartDetailWithID:self.star_id WithToken:[NSString stringWithFormat:@"%@",[dict objectForKey:@"token"]]];
    manager.delegate = self;
}

- (void)requestFinishiDownLoadWith:(NSMutableArray *)data {
    if (self.loadType == requestIntroType) {
        introDataArr = data;
        [self refreshUI];
    }else if (self.loadType == requestAddMyChannelType){
        [self.addOrDeleteBtn setBackgroundImage:LOADIMAGE(@"mx_exist", kImageTypePNG) forState:UIControlStateNormal];
        isStarAttentionMyChannel = 1;
        
    }else if (self.loadType == requestDeleteMyChannelType){
        [self.addOrDeleteBtn setBackgroundImage:LOADIMAGE(@"mx_join", kImageTypePNG) forState:UIControlStateNormal];
        isStarAttentionMyChannel = 0;
    }else {
        NSLog(@"data:%@",data);
        if ([[[data objectAtIndex:0] objectForKey:@"vod_num"] integerValue] != 0){ //电影
            [CheckArr addObject:@"电影"];
        }else{
            [CheckArr addObject:@""];
        }
        
        if ([[[data objectAtIndex:0] objectForKey:@"tv_num"] integerValue] != 0){ //电视剧
            [CheckArr addObject:@"电视剧"];
        }else{
            [CheckArr addObject:@""];
        }
        
        if ([[[data objectAtIndex:0] objectForKey:@"variety_num"] integerValue] != 0){ //综艺
            [CheckArr addObject:@"综艺"];
        }else{
            [CheckArr addObject:@""];
        }
        
        [self loadSegmentedWithArr:CheckArr];
        
        [self startRequestStarData];
    }
}

- (void)requestError:(NSError *)error {
    NSLog(@"error:%@",error);
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

- (void)upsideButtonClick:(UIButton *)sender {
    switch (sender.tag) {
        case 101:{
            //TODO:添加到我的频道 或者 从我的频道中删除
            CUSFileStorage *storage = [CUSFileStorageManager getFileStorage:CURRENTENCRYPTFILE];
            if (![[AESCrypt decrypt:[storage objectForKey:LoginStatus_KEY] password:PASSWORD] isEqualToString:@"islogin"]){
                RMLoginViewController * loginCtl = [[RMLoginViewController alloc] init];
                RMCustomPresentNavViewController * loginNav = [[RMCustomPresentNavViewController alloc] initWithRootViewController:loginCtl];
                [self presentViewController:loginNav animated:YES completion:^{
                }];
                return;
            }
            if (isStarAttentionMyChannel){
                self.loadType = requestDeleteMyChannelType;
                RMPublicModel * model = [introDataArr objectAtIndex:0];
                CUSFileStorage *storage = [CUSFileStorageManager getFileStorage:CURRENTENCRYPTFILE];
                NSDictionary *dict = [storage objectForKey:UserLoginInformation_KEY];
                [manager getDeleteMyChannelWithTag:model.tag_id WithToken:[NSString stringWithFormat:@"%@",[dict objectForKey:@"token"]]];
                manager.delegate = self;
            }else{
                self.loadType = requestAddMyChannelType;
                RMPublicModel * model = [introDataArr objectAtIndex:0];
                CUSFileStorage *storage = [CUSFileStorageManager getFileStorage:CURRENTENCRYPTFILE];
                NSDictionary *dict = [storage objectForKey:UserLoginInformation_KEY];
                [manager getJoinMyChannelWithToken:[NSString stringWithFormat:@"%@",[dict objectForKey:@"token"]] andID:model.tag_id];
                manager.delegate = self;
            }
            break;
        }
        case 102:{
            if (isStarIntroductionClose){
                [self openStarIntroductionAnimations];
            }else{
                [self closeStarIntroductionAnimations];
            }
 
            break;
        }

        default:
            break;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!isStarIntroductionClose){
        [self closeStarIntroductionAnimations];
    }
}

/**
 打开明星介绍页面
 */
- (void)openStarIntroductionAnimations {
    self.addOrDeleteBtn.hidden = YES;
    [self.openOrCloseBtn setBackgroundImage:LOADIMAGE(@"mx_close", kImageTypePNG) forState:UIControlStateNormal];
    [UIView animateWithDuration:0.4 animations:^{
        self.aboveView.frame = CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleAllHeight - 64);
        self.starIntroduction.frame = CGRectMake(120, 45, [UtilityFunc shareInstance].globleWidth - 130, [UtilityFunc shareInstance].globleAllHeight - 150);
        self.openOrCloseBtn.frame = CGRectMake([UtilityFunc shareInstance].globleWidth - 71, [UtilityFunc shareInstance].globleAllHeight - 95, 51, 16);
        self.blackView.frame = CGRectMake(120, [UtilityFunc shareInstance].globleAllHeight - 150, [UtilityFunc shareInstance].globleWidth - 130, 150);
    } completion:^(BOOL finished) {
        isStarIntroductionClose = NO;
    }];
}

/**
 合上明星介绍页面
 */
- (void)closeStarIntroductionAnimations {
    [self.openOrCloseBtn setBackgroundImage:LOADIMAGE(@"mx_open", kImageTypePNG) forState:UIControlStateNormal];
    [UIView animateWithDuration:0.4 animations:^{
        self.aboveView.frame = CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth, 150);
        self.starIntroduction.frame = CGRectMake(120, 45, [UtilityFunc shareInstance].globleWidth - 130, 50);
        self.openOrCloseBtn.frame = CGRectMake([UtilityFunc shareInstance].globleWidth - 71, 112, 51, 16);
        self.blackView.frame = CGRectMake(120, 45, [UtilityFunc shareInstance].globleWidth - 130, 30);
    } completion:^(BOOL finished) {
        isStarIntroductionClose = YES;
        self.addOrDeleteBtn.hidden = NO;
    }];
}

@end
