//
//  RMShouldSeeTVViewController.h
//  RMVideo
//
//  Created by 润华联动 on 14-10-31.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMBaseViewController.h"
#import "RMStarDetailsCell.h"
#import "PullToRefreshTableView.h"

@interface RMShouldSeeTVViewController : RMBaseViewController<StarDetailsCellDelegate>
@property (nonatomic,strong) NSMutableArray *dataArray;
@property (weak, nonatomic) IBOutlet PullToRefreshTableView *mainTableView;
@property (nonatomic,copy)NSString *downLoadID;
@property (nonatomic, assign) id myChannelShouldDelegate;
@end
