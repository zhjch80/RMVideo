//
//  RMStarVarietyListViewController.h
//  RMVideo
//
//  Created by runmobile on 14-10-14.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RMBaseViewController.h"

@interface RMStarVarietyListViewController : RMBaseViewController
@property (nonatomic, assign) id starDetailsDelegate;
@property (nonatomic, copy) NSString * star_id;

- (void)startRequest;

@end
