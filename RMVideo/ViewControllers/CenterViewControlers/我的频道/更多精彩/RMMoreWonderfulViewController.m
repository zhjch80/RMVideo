//
//  RMMoreWonderfulViewController.m
//  RMVideo
//
//  Created by runmobile on 14-10-14.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMMoreWonderfulViewController.h"
#import "RMAddRecommendView.h"
#import "ZYQSphereView.h"

/**
 *区分请求类型
 *requestListType:  默认进来请求列表
 *requestReplease:  点击换一批
 *requestCustom:    自定义tag
 */
typedef enum{
    requestListType = 1,
    requestReplace,
    requestCustom
}LoadType;

@interface RMMoreWonderfulViewController ()<UIScrollViewDelegate,AddRecommendDelegate,UITextFieldDelegate,RMAFNRequestManagerDelegate> {
    NSMutableArray * dataArr;
    RMAFNRequestManager * request;
    NSInteger pageCount;
    
    LoadType loadType;
    ZYQSphereView *sphereView;
}
@end

@implementation RMMoreWonderfulViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    loadType = requestListType;

    dataArr = [[NSMutableArray alloc] init];
    pageCount = 1;
    
    [self setTitle:@"我的频道"];
    [leftBarButton setBackgroundImage:LOADIMAGE(@"backup_img", kImageTypePNG) forState:UIControlStateNormal];
    rightBarButton.hidden = YES;
    
    UIScrollView * bgScrView = [[UIScrollView alloc] init];
    bgScrView.backgroundColor = [UIColor clearColor];
    bgScrView.frame = CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleHeight - 44);
    bgScrView.userInteractionEnabled = YES;
    bgScrView.showsVerticalScrollIndicator = YES;
    bgScrView.showsHorizontalScrollIndicator = YES;
    bgScrView.delegate = self;
    bgScrView.backgroundColor = [UIColor clearColor];
    [bgScrView setContentSize:CGSizeMake([UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleHeight - 43)];
    [self.view addSubview:bgScrView];
    
    sphereView = [[ZYQSphereView alloc] initWithFrame:CGRectMake(10, 60, 300, 300)];
    sphereView.center=CGPointMake(self.view.center.x, self.view.center.y-30);
    NSMutableArray *views = [[NSMutableArray alloc] init];
    for (int i = 0; i < 10; i++) {
        //		UIButton *subV = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        //		subV.backgroundColor = [UIColor colorWithRed:arc4random_uniform(100)/100. green:arc4random_uniform(100)/100. blue:arc4random_uniform(100)/100. alpha:1];
        //        [subV setTitle:[NSString stringWithFormat:@"天天开心天天开心%d",i] forState:UIControlStateNormal];
        //        subV.layer.masksToBounds=YES;
        //        subV.layer.cornerRadius=3;
        //        [subV addTarget:self action:@selector(subVClick:) forControlEvents:UIControlEventTouchUpInside];
        //        [views addObject:subV];
        //		[subV release];
        
        
        UILabel *subV = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 50)];
        subV.text = [NSString stringWithFormat:@"天天天天天天天天天天"];
        subV.numberOfLines = 2;
        subV.adjustsFontSizeToFitWidth = YES;
        subV.backgroundColor = [UIColor colorWithRed:arc4random_uniform(100)/100. green:arc4random_uniform(100)/100. blue:arc4random_uniform(100)/100. alpha:1];
        //        [subV setTitle:[NSString stringWithFormat:@"天天开心天天开心%d",i] forState:UIControlStateNormal];
        subV.layer.masksToBounds=YES;
        subV.layer.cornerRadius=3;
        //        [subV addTarget:self action:@selector(subVClick:) forControlEvents:UIControlEventTouchUpInside];
        [views addObject:subV];
    }

    [sphereView setItems:views];
    
    sphereView.isPanTimerStart=YES;
    
    [self.view addSubview:sphereView];
    [sphereView timerStart];
    

    
//    NSInteger value = 1001;
//    for (int i=0; i<3; i++) {
//        for (int j=0; j<3; j++) {
//            RMAddRecommendView * addRecommendView = [[RMAddRecommendView alloc] initWithFrame:CGRectMake(15 + i*100, 15 + j*60, 90, 30)];
//            addRecommendView.delegate = self;
//            addRecommendView.tag = value;
//            addRecommendView.userInteractionEnabled = YES;
//            [bgScrView addSubview:addRecommendView];
//            value ++;
//        }
//    }

    
    UILabel * changeTitle = [[UILabel alloc] init];
    changeTitle.frame = CGRectMake(15, 400, 90, 30);
    changeTitle.userInteractionEnabled = YES;
    changeTitle.text = @"换一批";
    changeTitle.font = [UIFont systemFontOfSize:12.0];
    changeTitle.textColor = [UIColor colorWithRed:0.8 green:0.08 blue:0.13 alpha:1];
    changeTitle.textAlignment = NSTextAlignmentCenter;
    changeTitle.backgroundColor = [UIColor clearColor];
    [bgScrView addSubview:changeTitle];
    
    UIButton * changeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    changeBtn.tag = 101;
    changeBtn.frame = CGRectMake(15, 400, 90, 30);
    [changeBtn setBackgroundImage:LOADIMAGE(@"re_redFrame", kImageTypePNG) forState:UIControlStateNormal];
    [changeBtn addTarget:self action:@selector(mbuttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [bgScrView addSubview:changeBtn];
    
    UIButton * customBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    customBtn.frame = CGRectMake(120, 400, 90, 30);
    [customBtn setBackgroundImage:LOADIMAGE(@"re_redFrame", kImageTypePNG) forState:UIControlStateNormal];
    [customBtn addTarget:self action:@selector(mbuttonClick:) forControlEvents:UIControlEventTouchUpInside];
    customBtn.tag = 102;
    [bgScrView addSubview:customBtn];

    
    request = [[RMAFNRequestManager alloc] init];
    [request getMoreWonderfulVideoListWithPage:[NSString stringWithFormat:@"%d",pageCount] count:@"9"];
    request.delegate = self;
    
}

-(void)subVClick:(UIButton*)sender{
    NSLog(@"%@",sender.titleLabel.text);
    
    BOOL isStart=[sphereView isTimerStart];
    
    [sphereView timerStop];
    
    [UIView animateWithDuration:0.3 animations:^{
        sender.transform=CGAffineTransformMakeScale(1.5, 1.5);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            sender.transform=CGAffineTransformMakeScale(1, 1);
            if (isStart) {
                [sphereView timerStart];
            }
        }];
    }];
}

#pragma mark - 

- (void)mbuttonClick:(UIButton *)sender {
    switch (sender.tag) {
        case 101:{
            loadType = requestReplace;
            pageCount ++;
            [request getMoreWonderfulVideoListWithPage:[NSString stringWithFormat:@"%d",pageCount] count:@"9"];
            break;
        }
        case 102:{
            UIAlertView *addAlertView = [[UIAlertView alloc] initWithTitle:@"添加属于自己的标签"
                                                                   message:nil
                                                                  delegate:self
                                                         cancelButtonTitle:@"取消"
                                                         otherButtonTitles:@"添加", nil];
            [addAlertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
            
            UITextField *textField = [addAlertView textFieldAtIndex:0];
            [textField setPlaceholder:@"标签"];
            [addAlertView show];
            break;
        }

        default:
            break;
    }
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex) {
        if (buttonIndex == 1) {
            //添加
            loadType = requestCustom;
            NSString *str = [alertView textFieldAtIndex:0].text;
            CUSFileStorage *storage = [CUSFileStorageManager getFileStorage:CURRENTENCRYPTFILE];
            NSDictionary *dict = [storage objectForKey:UserLoginInformation_KEY];
            [request getCustomTagWithToken:[NSString stringWithFormat:@"%@",[dict objectForKey:@"token"]] tagName:str];
        }else{
        }
    }
}

- (void)searchHotTaglibWithKeyWord:(NSString *)keyWords {
    NSLog(@"keyWords:%@",keyWords);
}

#pragma mark - AddRecommendDelegate

- (void)startAddDidSelectWithIndex:(NSInteger)index {
    NSLog(@"我的频道 添加%d",index);
}

#pragma mark - Base Method

-(void)navgationBarButtonClick:(UIBarButtonItem *)sender {
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

- (void)refreshTagList {
    for (int i=1001; i<=1009; i++) {    
        RMPublicModel *model = [dataArr objectAtIndex:i-1001];
        RMAddRecommendView * addRecomendView = (RMAddRecommendView *)[self.view viewWithTag:i];
        addRecomendView.tagTitle.text = model.name;
        addRecomendView.tagBtn.tag = model.tag_id.integerValue;
        [addRecomendView.tagTitle sizeToFit];
    }
}

#pragma mark - request RMAFNRequestManagerDelegate

- (void)requestFinishiDownLoadWith:(NSMutableArray *)data {
    if (loadType == requestListType){
        dataArr = data;
        [self refreshTagList];
    }else if (loadType == requestReplace){
        dataArr = data;
        [self refreshTagList];
    }else if (loadType == requestCustom){
        RMPublicModel *model = [data objectAtIndex:0];
        if ([model.code integerValue] == 4001) {
            NSLog(@"增加新的tag成功");
            //TODO:添加到 我的频道
        }
    }
}

- (void)requestError:(NSError *)error {
    NSLog(@"更多精彩：error;%@",error);
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
