//
//  RMDailyMovieViewController.h
//  RMVideo
//
//  Created by 润华联动 on 14-10-16.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMBaseViewController.h"
#import "RefreshControl.h"

@protocol RMDailyMovieViewControllerDelegate <NSObject>

- (void)selectMovieTableViewWithIndex:(NSInteger)index andStringID:(NSString *)stringID;
- (void)playMovieWithModel:(RMPublicModel *)model;

@end
@interface RMDailyMovieViewController : RMBaseViewController<UITableViewDelegate,UITableViewDataSource,RefreshControlDelegate>{
   
}
@property (nonatomic,strong) NSMutableArray *dataArray;
@property (weak, nonatomic) IBOutlet UITableView *mainTableView;
@property (nonatomic,strong)RefreshControl * refreshControl;
@property (nonatomic,copy)NSString *downLoadTopType;
@property (nonatomic, assign) id<RMDailyMovieViewControllerDelegate> delegate;

- (void) requestData;
@end
