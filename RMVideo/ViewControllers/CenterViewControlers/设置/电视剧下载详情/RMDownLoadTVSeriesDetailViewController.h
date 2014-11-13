//
//  RMDownLoadTVSeriesDetailViewController.h
//  RMVideo
//
//  Created by 润华联动 on 14-10-22.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMDownLoadBaseViewController.h"

@interface RMDownLoadTVSeriesDetailViewController : RMDownLoadBaseViewController{
    
}
@property (nonatomic, copy) NSString * modelID;
@property (nonatomic, copy) NSString * TVName;
@property (nonatomic, strong)NSMutableArray *dataArray;
- (IBAction)pauseOrStarAllBtnClick:(UIButton *)sender;
@end
