//
//  CustomSVProgressHUD.m
//  RMCustomPlay
//
//  Created by 润华联动 on 14-11-5.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "CustomSVProgressHUD.h"
#import <QuartzCore/QuartzCore.h>

@implementation CustomSVProgressHUD

- (void)showWithState:(BOOL)isFastForward andNowTime:(int)time{
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 8;
//    self.backgroundColor = [UIColor blackColor];
//    self.alpha = 0.5;
    if(!isFastForward){
        [self.headImage setImage:[UIImage imageNamed:@"fastforward"]];
    }
    else{
        [self.headImage setImage:[UIImage imageNamed:@"retreatquickly"]];
    }
    int minutes = time/60;
    int seconds = time%60;
    if (minutes<=0) {
        minutes = 0;
    }if (seconds<=0) {
        seconds = 0;
    }
    NSLog(@"---%@",self.totalTimeString);
    self.beginLable.text = [NSString stringWithFormat:@"%d:%d",minutes,seconds];
    self.totalLable.text = [NSString stringWithFormat:@"/%@",self.totalTimeString];
}

@end
