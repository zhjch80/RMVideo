//
//  RMMyChannelShouldSeeViewController.m
//  RMVideo
//
//  Created by runmobile on 14-10-20.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMMyChannelShouldSeeViewController.h"
#import "RMAFNRequestManager.h"

@interface RMMyChannelShouldSeeViewController ()
@property (nonatomic, strong) NSString *tag_id;
@end

@implementation RMMyChannelShouldSeeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setTitle:@"tag必看"];
    
    [leftBarButton setBackgroundImage:LOADIMAGE(@"backup_img", kImageTypePNG) forState:UIControlStateNormal];
    rightBarButton.hidden = YES;
    
    
}

- (void)setTagId:(NSString *)tag_id {
    self.tag_id = tag_id;
}

#pragma mark - base Method

- (void)navgationBarButtonClick:(UIBarButtonItem *)sender {
    switch (sender.tag) {
        case 1:{
            [self.navigationController popViewControllerAnimated:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:kAppearTabbar object:nil];
            break;
        }
        case 2:{
            
            break;
        }
            
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
 
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
