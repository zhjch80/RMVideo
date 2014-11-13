//
//  RMWebViewPlayViewController.h
//  RMVideo
//
//  Created by 润华联动 on 14-11-13.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMBaseViewController.h"

@interface RMWebViewPlayViewController : RMBaseViewController

@property(nonatomic, copy) NSString *urlString;
@property (weak, nonatomic) IBOutlet UILabel *titleLable;
@property (weak, nonatomic) IBOutlet UIWebView *PlayWebView;
@property (weak, nonatomic) IBOutlet UIButton *navButton;


- (IBAction)customNavReturn:(UIButton *)sender;

@end
