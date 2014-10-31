//
//  RMMyChannelShouldSeeViewController.h
//  RMVideo
//
//  Created by runmobile on 14-10-20.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMBaseViewController.h"

@interface RMMyChannelShouldSeeViewController : RMBaseViewController

@property (nonatomic,copy)NSString *titleString;
@property (nonatomic,copy)NSString *downLoadID;

- (void)setTagId:(NSString *)tag_id;

@end
