//
//  RMDailyTVViewController.h
//  RMVideo
//
//  Created by 润华联动 on 14-10-16.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMBaseViewController.h"
#import "PullToRefreshTableView.h"

@protocol RMDailyTVViewControllerDelegate <NSObject>

- (void)selectTVTableViewCellWithIndex:(NSInteger)index andStringID:(NSString *)stringID;

@end
@interface RMDailyTVViewController : RMBaseViewController<UITableViewDelegate,UITableViewDataSource>{
    
}
@property (nonatomic,strong) NSMutableArray *dataArray;
@property (weak, nonatomic) IBOutlet PullToRefreshTableView *mainTableView;
@property (nonatomic,copy)NSString *downLoadTopType;
@property (assign,nonatomic)id<RMDailyTVViewControllerDelegate> delegate;

- (void) requestData;

@end
