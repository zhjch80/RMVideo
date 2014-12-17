//
//  RMNewStarDetailsViewController.h
//  RMVideo
//
//  Created by runmobile on 14-12-16.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RMBaseViewController.h"
#import "RMBaseTextView.h"

@interface RMStarDetailsViewController : RMBaseViewController
@property (weak, nonatomic) IBOutlet UIView *upsideView;//上视图的View
@property (weak, nonatomic) IBOutlet UIView *belowView;//下视图的View
@property (nonatomic, strong) UIView * aboveView;
@property (nonatomic, strong) UIView * blackView;

@property (weak, nonatomic) IBOutlet UIImageView *starHeadImg;//明星头像
@property (weak, nonatomic) IBOutlet UILabel *starName;//明星名字
@property (strong, nonatomic) RMBaseTextView *starIntroduction;//明星介绍
@property (weak, nonatomic) UIButton *addOrDeleteBtn;//添加或者删除
@property (weak, nonatomic) UIButton *openOrCloseBtn;//打开或者合上

@property (nonatomic, copy) NSString * star_id;//明星id

@end