//
//  RMMyChannelViewController.h
//  RMVideo
//
//  Created by runmobile on 14-10-13.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMBaseViewController.h"
#import "RMImageView.h"

@interface RMMyChannelViewController : RMBaseViewController

@property (weak, nonatomic) IBOutlet RMImageView *moreWonderfulImg;
@property (weak, nonatomic) IBOutlet UILabel *moreTitle;

@property (weak, nonatomic) IBOutlet UIImageView *moreBgImg;


@property (weak, nonatomic) IBOutlet UIButton *moreBtn;


- (IBAction)mbuttonClick:(UIButton *)sender;

@end
