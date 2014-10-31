//
//  HJMTabBar.h
//  HJMDrawer
//
//  Created by 华晋传媒 on 14-3-13.
//  Copyright (c) 2014年 HuaJinMedia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HJMTabBar : UITabBarController
@property (strong, nonatomic) UIView * tabBarView;

-(void)setTabWithArray:(NSArray *)tabArray NormalImageArray:(NSArray *)normalArray SelectedImageArray:(NSArray *)selectedArray;


@end
