//
//  RMSetupViewController.h
//  RMVideo
//
//  Created by runmobile on 14-10-13.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMBaseViewController.h"

@interface RMSetupViewController : RMBaseViewController<UITableViewDelegate,UITableViewDataSource>{
    
    __weak IBOutlet UITableView *mainTableView;
    NSMutableArray *dataArray;
}

@property (weak, nonatomic) IBOutlet UIView *headView;

-(IBAction)loginOrExitButtonClick:(UIButton *)sender;
@end
