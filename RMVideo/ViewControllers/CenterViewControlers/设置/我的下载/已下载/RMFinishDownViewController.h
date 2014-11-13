//
//  RMFinishDownViewController.h
//  RMVideo
//
//  Created by 润华联动 on 14-10-17.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMBaseViewController.h"

@interface RMFinishDownViewController : RMBaseViewController{
    NSMutableArray *selectCellArray;
    NSMutableArray *cellEditingImageArray;
    void(^selectIndex)(NSString *movieName);
    void(^selectArray)(NSMutableArray *array);
    BOOL isBegingEditing;
}
@property (nonatomic, assign) id myDownLoadDelegate;

@property (weak, nonatomic) IBOutlet UITableView *maiTableView;
@property (nonatomic ,strong) NSMutableArray *dataArray;

- (void) selectTableViewCellWithIndex:(void(^)(NSString *movieString))block;

- (void)delectCellArray:(void(^)(NSMutableArray *array))block;

//全选
- (void)selectAllTableViewCellWithState:(BOOL)state;

//删除
- (void)deleteAllTableViewCell;

@end
