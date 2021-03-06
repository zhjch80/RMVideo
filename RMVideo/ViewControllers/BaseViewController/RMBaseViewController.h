//
//  RMBaseViewController.h
//  RMVideo
//
//  Created by runmobile on 14-9-29.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CONST.h"
#import "UtilityFunc.h"
#import "AFNetworking.h"
#import "UIImageView+WebCache.h"
//storage
#import "CUSFileStorage.h"
#import "CUSSerializer.h"
//AES
#import "AESCrypt.h"

#import "RMAFNRequestManager.h"
#import "RMPublicModel.h"
#import "SVProgressHUD.h"
#import "Database.h"
#import "Flurry.h"

#define PLAYHISTORYLISTNAME @"PlayHistoryListname"
#define DOWNLOADLISTNAME @"DownLoadListname"

@interface RMBaseViewController : UIViewController<RMAFNRequestManagerDelegate>{
    UIButton *leftBarButton;
    UIButton *rightBarButton;
}

- (void)setTitle:(NSString *)title;
- (void)navgationBarButtonClick:(UIBarButtonItem *)sender;
- (void)setExtraCellLineHidden: (UITableView *)tableView;

- (void)showEmptyViewWithImage:(UIImage *)image WithTitle:(NSString *)title;
- (void)isShouldSetHiddenEmptyView:(BOOL)isShould;

- (void)showUnderEmptyViewWithImage:(UIImage *)image WithTitle:(NSString *)title WithHeight:(CGFloat)height;
- (void)isShouldSetHiddenUnderEmptyView:(BOOL)isShould;

@end
