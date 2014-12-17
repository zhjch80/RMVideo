//
//  RMNewStarDetailsViewController.m
//  RMVideo
//
//  Created by runmobile on 14-12-16.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMNewStarDetailsViewController.h"
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
    requestDeleteMyChannelType
}LoadType;

@interface RMNewStarDetailsViewController ()<SwitchSelectedMethodDelegate,RMAFNRequestManagerDelegate>{
    NSMutableArray * introDataArr;

}
@property (nonatomic, copy) RMSegmentedControl *segmentedControl;
@property (nonatomic, assign) SelectedStateCtlType selectedCtlType;
@property (nonatomic, assign) LoadType loadType;

@property RMStarTeleplayListViewController * starTeleplayListCtl;
@property RMStarFilmListViewController * starFilmListCtl;
@property RMStarVarietyListViewController * starVarietyListCtl;
@end

@implementation RMNewStarDetailsViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    CUSFileStorage *storage = [CUSFileStorageManager getFileStorage:CURRENTENCRYPTFILE];
    NSDictionary *dict = [storage objectForKey:UserLoginInformation_KEY];
    RMAFNRequestManager * manager = [[RMAFNRequestManager alloc] init];
    self.loadType = requestIntroType;
    [manager getStartDetailWithID:self.star_id WithToken:[NSString stringWithFormat:@"%@",[dict objectForKey:@"token"]]];
    manager.delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    introDataArr = [[NSMutableArray alloc] init];
    
    [leftBarButton setBackgroundImage:LOADIMAGE(@"backup_img", kImageTypePNG) forState:UIControlStateNormal];
    rightBarButton.hidden = YES;
    
    self.selectedCtlType = selectedUnknownCtlStateType;
    
    _segmentedControl = [[RMSegmentedControl alloc] initWithSectionTitles:@[@"电影", @"电视剧", @"综艺"] withIdentifierType:@"starIdentifier"];
    _segmentedControl.delegate = self;
    _segmentedControl.frame = CGRectMake(0, 150, [UIScreen mainScreen].bounds.size.width, 40);
    [_segmentedControl setSelectedIndex:0];
    [_segmentedControl setBackgroundColor:[UIColor colorWithRed:0.15 green:0.15 blue:0.15 alpha:1]];
    [_segmentedControl setTextColor:[UIColor clearColor]];
    [_segmentedControl setSelectionIndicatorColor:[UIColor clearColor]];
    [_segmentedControl setTag:3];
    [self.upsideView addSubview:_segmentedControl];
    
}

- (void)switchSelectedMethodWithValue:(int)value {
    
    NSLog(@"value:%d",value);
}

#pragma mark - request 

- (void)requestFinishiDownLoadWith:(NSMutableArray *)data {
    if (self.loadType == requestIntroType) {
        introDataArr = data;
    }
    NSLog(@"introDataArr:%@",introDataArr);
}

- (void)requestError:(NSError *)error {
    
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

@end
