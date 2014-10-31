//
//  RMDownLoadingViewController.h
//  RMVideo
//
//  Created by 润华联动 on 14-10-17.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMBaseViewController.h"

@interface RMDownLoadingViewController : RMBaseViewController
{
    NSMutableArray *selectCellArray;
    NSMutableArray *cellEditingImageArray;
    void (^selectIndex)(NSInteger index);
    BOOL isBeginEditing;
    BOOL isPauseAllDownLoadAssignment;//是否暂停所有下载任务
}
@property (weak, nonatomic) IBOutlet UITableView *mainTableView;
@property (weak, nonatomic) IBOutlet UIButton *showDownLoadState;
@property (weak, nonatomic) IBOutlet UIButton *pauseOrStarBtn;
@property (strong, nonatomic) NSMutableArray *dataArray;
- (IBAction)pauseOrStarAllBtnClick:(UIButton *)sender;

- (void)selectTableViewCellWithIndex:(void(^)(NSInteger index))selectBlock;

+(instancetype)shared;

//全选
- (void)selectAllTableViewCellWithState:(BOOL)state;

//删除
- (void)deleteAllTableViewCell;
@end
