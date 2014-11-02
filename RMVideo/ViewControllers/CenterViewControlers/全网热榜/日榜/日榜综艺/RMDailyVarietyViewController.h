//
//  RMDailyVarietyViewController.h
//  RMVideo
//
//  Created by 润华联动 on 14-10-16.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMBaseViewController.h"
#import "PullToRefreshTableView.h"

@protocol RMDailyVarietyViewControllerDelegate <NSObject>

- (void)selectVarietyTableViewCellWithIndex:(NSInteger)index andStringID:(NSString *)stringID;

@end

@interface RMDailyVarietyViewController : RMBaseViewController<UITableViewDelegate,UITableViewDataSource>{
    
}
@property (nonatomic,strong) NSMutableArray *dataArray;
@property (weak, nonatomic) IBOutlet PullToRefreshTableView *mainTableView;
@property (nonatomic,copy)NSString *downLoadTopType;
@property (assign,nonatomic)id<RMDailyVarietyViewControllerDelegate> delegate;
@end
