//
//  RMNewStarDetailsViewController.h
//  RMVideo
//
//  Created by runmobile on 14-12-16.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RMBaseViewController.h"

@interface RMNewStarDetailsViewController : RMBaseViewController
@property (weak, nonatomic) IBOutlet UIView *upsideView;
@property (weak, nonatomic) IBOutlet UIView *belowView;

@property (nonatomic, copy) NSString * star_id;


@end