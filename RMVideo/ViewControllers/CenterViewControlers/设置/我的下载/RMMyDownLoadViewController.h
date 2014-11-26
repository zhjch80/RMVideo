//
//  RMMyDownLoadViewController.h
//  RMVideo
//
//  Created by 润华联动 on 14-10-22.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMDownLoadBaseViewController.h"
#import "SUNSlideSwitchView.h"
#import "RMDownLoadingViewController.h"
#import "RMFinishDownViewController.h"

@interface RMMyDownLoadViewController : RMDownLoadBaseViewController<SUNSlideSwitchViewDelegate>
{
    SUNSlideSwitchView *sunSliderSwitchView;
    RMDownLoadingViewController *downLoadingViewContr;
    RMFinishDownViewController *finishDownViewContr;
    NSInteger selectViewControl; //标记当前显示的页面
}
//刷新导航right but 状态
- (void)setRightBarBtnItemState;
@end
