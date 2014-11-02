//
//  RMDailyMovieViewController.h
//  RMVideo
//
//  Created by 润华联动 on 14-10-16.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMBaseViewController.h"

@protocol RMDailyMovieViewControllerDelegate <NSObject>

- (void)selectMovieTableViewWithIndex:(NSInteger)index andStringID:(NSString *)stringID;

@end
@interface RMDailyMovieViewController : RMBaseViewController<UITableViewDelegate,UITableViewDataSource>{
   
}
@property (nonatomic,strong) NSMutableArray *dataArray;
@property (weak, nonatomic) IBOutlet UITableView *mainTableView;
@property (nonatomic, assign) id<RMDailyMovieViewControllerDelegate> delegate;
@end
