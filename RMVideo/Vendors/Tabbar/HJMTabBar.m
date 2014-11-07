//
//  HJMTabBar.m
//  HJMDrawer
//
//  Created by 华晋传媒 on 14-3-13.
//  Copyright (c) 2014年 HuaJinMedia. All rights reserved.
//

#import "HJMTabBar.h"
#import "UIViewController+MMDrawerController.h"
#import "CONST.h"
#import "UtilityFunc.h"

@interface HJMTabBar () {
    NSArray * m_selectedArr;
    NSArray * m_normalArray;
}

@end

@implementation HJMTabBar{
    NSInteger count;
    NSMutableArray * btnArray;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideTabBar:) name:kHideTabbar object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appearTabBar:) name:kAppearTabbar object:nil];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openOrCloseDefaultLeftMenu) name:@"openOrCloseDefaultLeftMenu" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openOrCloseDefaultRightMenu) name:@"openOrCloseDefaultRightMenu" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeMenu) name:@"closeMenu" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mTabSelectIndex:) name:@"mTabSelectIndex" object:nil];
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.tabBar.hidden = YES;
    
    btnArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    [self hideOriginalTab];
    
    self.tabBarView = [[UIView alloc]init];
    self.tabBarView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height-49, [UtilityFunc shareInstance].globleWidth, 49);
    self.tabBarView.backgroundColor = [UIColor colorWithRed:0.33 green:0.33 blue:0.33 alpha:1];
    [self.view addSubview:self.tabBarView];
}

- (void)backBtnClick:(NSNotification *)notif {
    [self.navigationController popViewControllerAnimated:YES];
}

//隐藏tabbar
- (void)hideTabBar:(NSNotification *)notif {
    [UIView animateWithDuration:0.2
                          delay:0.00
                        options:UIViewAnimationOptionTransitionCurlUp animations:^(void){
                            self.tabBarView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UtilityFunc shareInstance].globleWidth, 49);
                        }completion:nil];
    
}

//显示tabbar
- (void)appearTabBar:(NSNotification *)notif {
    [UIView animateWithDuration:0.2
                          delay:0.00
                        options:UIViewAnimationOptionTransitionCurlUp animations:^(void){
                            self.tabBarView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height-49, [UtilityFunc shareInstance].globleWidth, 49);
                        }completion:nil];
    
}

//给tabbar自定义按钮或其他控件
- (void)setTabWithArray:(NSArray *)tabArray NormalImageArray:(NSArray *)normalArray SelectedImageArray:(NSArray *)selectedArray {
    
    m_selectedArr = [NSArray arrayWithArray:selectedArray];
    m_normalArray = [NSArray arrayWithArray:normalArray];
    
    self.viewControllers = tabArray;
    count = [tabArray count];
    if (tabArray.count > 0) {
        
        for (int i = 0; i < [tabArray count]; i ++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.backgroundColor = [UIColor clearColor];
            [btn setBackgroundImage:[UIImage imageNamed:[normalArray objectAtIndex:i]] forState:UIControlStateNormal];
            [btn setAdjustsImageWhenHighlighted:NO];
            btn.tag = i ;
            if (btn.tag == 0){
                btn.selected = YES;
                [btn setBackgroundImage:LOADIMAGE(@"RecommendedDaily_red", kImageTypePNG) forState:UIControlStateNormal];
            }else {
                btn.selected = NO;
            }
            
            if (i == [tabArray count] - 1){
                btn.frame = CGRectMake([UtilityFunc shareInstance].globleWidth/[tabArray count]*i, 0, [UtilityFunc shareInstance].globleWidth/[tabArray count], 49);
            }else {
                btn.frame = CGRectMake([UtilityFunc shareInstance].globleWidth/[tabArray count]*i, 0, [UtilityFunc shareInstance].globleWidth/[tabArray count]-1, 49);
            }
            
            [btn addTarget:self action:@selector(selectTab:) forControlEvents:UIControlEventTouchUpInside];
            [self.tabBarView addSubview:btn];
            [btnArray addObject:btn];
        }
    }
}

- (void)selectTab:(UIButton *)selectBtn {    
     if(selectBtn.selected == NO) {
        NSInteger selectTag = selectBtn.tag;
        selectBtn.selected = YES;
        UIViewController *selectVC = [self.viewControllers objectAtIndex:selectTag];
        self.selectedViewController = selectVC;
        for(int i = 0; i < count; i++) {
            UIButton *btn = (UIButton *)[btnArray objectAtIndex:i];
            if (btn.tag != selectTag){
                btn.selected = NO;
                [btn setBackgroundImage:LOADIMAGE([m_normalArray objectAtIndex:i], kImageTypePNG) forState:UIControlStateNormal];
            } else {
                btn.selected = YES;
                [selectBtn setBackgroundImage:LOADIMAGE([m_selectedArr objectAtIndex:i], kImageTypePNG) forState:UIControlStateNormal];
            }
        }
    }
}

- (void)hideOriginalTab {
    NSArray *array = [self.view subviews];
    UIView *originalTabView = [array objectAtIndex:1];
    originalTabView.frame = CGRectMake(0,[UIScreen mainScreen].bounds.size.height, [UtilityFunc shareInstance].globleWidth, 49);
    originalTabView.backgroundColor = [UIColor clearColor];
    UIView *newTabView = [array objectAtIndex:0];
    newTabView.frame = CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth, [UIScreen mainScreen].bounds.size.height);
    newTabView.backgroundColor = [UIColor redColor];
    
}

#pragma mark - open or close Default Menu

- (void)openOrCloseDefaultLeftMenu {
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

- (void)openOrCloseDefaultRightMenu {
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideRight animated:YES completion:nil];
}

- (void)closeMenu {
    [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
    [self.mm_drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeNone];
}

#pragma mark -

- (void)mTabSelectIndex:(NSNotification *)notify {
    NSInteger value = [[notify.userInfo objectForKey:@"TabSelectIndex"] integerValue];
    UIViewController *selectVC = [self.viewControllers objectAtIndex:value];
    self.selectedViewController = selectVC;
    for(int i = 0; i < count; i++) {
        UIButton *btn = (UIButton *)[btnArray objectAtIndex:i];
        if (btn.tag != value)
            btn.selected = NO;
        else
            btn.selected = YES;
    }
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return UIDeviceOrientationIsLandscape(toInterfaceOrientation);
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
