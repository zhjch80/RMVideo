//
//  RMDailyTVViewController.h
//  RMVideo
//
//  Created by 润华联动 on 14-10-16.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMBaseViewController.h"

@protocol RMDailyTVViewControllerDelegate <NSObject>

- (void)selectTVTableViewCellWithIndex:(NSInteger)index;

@end
@interface RMDailyTVViewController : RMBaseViewController<UITableViewDelegate,UITableViewDataSource>{
    
}
@property (nonatomic,strong) NSMutableArray *dataArray;
@property (weak, nonatomic) IBOutlet UITableView *mainTableView;
@property (assign,nonatomic)id<RMDailyTVViewControllerDelegate> delegate;
- (void)reloadTableViewWithDataArray:(NSMutableArray *)array;
@end
