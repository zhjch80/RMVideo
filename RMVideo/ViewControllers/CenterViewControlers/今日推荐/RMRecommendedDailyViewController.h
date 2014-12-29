//
//  RMRecommendedDailyViewController.h
//  RMVideo
//
//  Created by 润华联动 on 14-10-13.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMBaseViewController.h"
#import "RMRecommendedDailyTableViewCell.h"
#import "RefreshControl.h"

@interface RMRecommendedDailyViewController : RMBaseViewController<UITableViewDelegate,UITableViewDataSource,RecommendedDailyTableViewCellDelegate,RefreshControlDelegate>
{
    UITableView *mainTableVeiew;
    RefreshControl * refreshControl;
    NSMutableArray *dataArray;
    NSArray *cellHeadStringArray;
    NSMutableArray *CellScrollimageArray;
    NSArray *cellHeadImageArray;
}

@end
