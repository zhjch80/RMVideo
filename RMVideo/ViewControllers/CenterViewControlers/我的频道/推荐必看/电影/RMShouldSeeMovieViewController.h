//
//  RMShouldSeeMovieViewController.h
//  RMVideo
//
//  Created by 润华联动 on 14-10-31.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMBaseViewController.h"
#import "RMStarDetailsCell.h"
#import "RefreshControl.h"

@interface RMShouldSeeMovieViewController : RMBaseViewController<StarDetailsCellDelegate,RefreshControlDelegate>
@property (nonatomic,strong) NSMutableArray *dataArray;
@property (weak, nonatomic) IBOutlet UITableView *mainTableView;
@property (nonatomic,copy)NSString *downLoadID;
@property (nonatomic,strong)RefreshControl * refreshControl;

@property (nonatomic, assign) id myChannelShouldDelegate;
- (void)requestData;
@end
