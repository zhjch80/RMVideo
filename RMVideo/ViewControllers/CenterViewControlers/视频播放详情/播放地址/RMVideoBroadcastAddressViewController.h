//
//  RMVideoBroadcastAddressViewController.h
//  RMVideo
//
//  Created by runmobile on 14-10-17.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMBaseViewController.h"

@interface RMVideoBroadcastAddressViewController : RMBaseViewController
@property (nonatomic, assign) id videoPlayDelegate;

- (void)updateBroadcastAddress:(RMPublicModel *)model;

@end
