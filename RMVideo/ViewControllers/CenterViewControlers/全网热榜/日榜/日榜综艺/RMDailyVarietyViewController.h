//
//  RMDailyVarietyViewController.h
//  RMVideo
//
//  Created by 润华联动 on 14-10-16.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMBaseViewController.h"

@protocol RMDailyVarietyViewControllerDelegate <NSObject>

- (void)selectVarietyTableViewCellWithIndex:(NSInteger)index;

@end

@interface RMDailyVarietyViewController : RMBaseViewController<UITableViewDelegate,UITableViewDataSource>{
    
}
@property (nonatomic,strong) NSMutableArray *dataArray;
@property (weak, nonatomic) IBOutlet UITableView *mainTableView;
@property (assign,nonatomic)id<RMDailyVarietyViewControllerDelegate> delegate;
@end
