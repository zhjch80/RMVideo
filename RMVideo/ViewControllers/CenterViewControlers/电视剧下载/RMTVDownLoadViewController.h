//
//  RMTVDownLoadViewController.h
//  RMVideo
//
//  Created by 润华联动 on 14-10-15.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMBaseViewController.h"

@interface RMTVDownLoadViewController : RMBaseViewController

@property (weak, nonatomic) IBOutlet UIScrollView *headScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;
@property (copy, nonatomic) NSString *TVseriesTitle;
@property (copy, nonatomic) NSString *modelID;
@property (copy, nonatomic) NSString *TVName;
@property (copy, nonatomic) NSString *TVHeadImage;
@property (strong, nonatomic) NSMutableArray *TVdataArray;

- (IBAction)downAllTVEpisode:(UIButton *)sender;
@end
