//
//  RMDownLoadBaseViewController.h
//  RMVideo
//
//  Created by 润华联动 on 14-10-22.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMBaseViewController.h"

@interface RMDownLoadBaseViewController : RMBaseViewController<UITableViewDelegate,UITableViewDataSource>{
    UILabel *showMemoryLable;
    UIView *btnView;
    BOOL isEditing;
    NSMutableArray *cellEditingImageArray;
    NSMutableArray *selectCellArray;
    BOOL isSeleltAllCell;//是否全选 默认为YES
}

@property (weak, nonatomic) IBOutlet UITableView *mainTableView;
@property (strong ,nonatomic)NSMutableArray *dataArray;

- (void)EditingViewBtnClick:(UIButton *)sender;
- (void)setRightBarBtnItemImageWith:(BOOL)state;


@end
