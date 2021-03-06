//
//  RMTVDownLoadViewController.m
//  RMVideo
//
//  Created by 润华联动 on 14-10-15.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMTVDownLoadViewController.h"
#import "RMTVDownView.h"
#import "RMDownLoadingViewController.h"

@interface RMTVDownLoadViewController ()<RMAFNRequestManagerDelegate>

@end

@implementation RMTVDownLoadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    /*
     //传值的时候，self.title必须是电视剧名称。
     //self.dataArray 里面装的是RMPublicModel 其中publicModel.name 和下载是的名称要一致，即**第*集   model.downLoadURL为下载地址
     //tv_downing  正在下载的
     //tv_down_succes 下载成功的
     */
    self.TVdataArray = [[NSMutableArray alloc] init];
    self.title = @"选择要下载的分集";
    [leftBarButton setImage:[UIImage imageNamed:@"backup_img"] forState:UIControlStateNormal];
    rightBarButton.hidden = YES;

    [SVProgressHUD showWithStatus:@"下载中" maskType:SVProgressHUDMaskTypeClear];
    RMAFNRequestManager *requestManager = [[RMAFNRequestManager alloc] init];
    requestManager.delegate = self;
    [requestManager getDownloadDiversityWithID:self.modelID];
}

//添加集数的按钮
- (void)headScrollviewAddBtnWithImage:(UIImage *)image andBtnWidth:(CGFloat)width{
    [Flurry logEvent:@"Click_VideoDownloadViewAddEpisode_Btn"];

    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:13];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    NSString *titelStr = [NSString stringWithFormat:@"1-%d集",self.TVdataArray.count];
    [button setTitle:titelStr forState:UIControlStateNormal];
    button.frame = CGRectMake(17, (self.headScrollView.frame.size.height-30)/2, width, 30);
    [self.headScrollView addSubview:button];
    
}

- (void)addTVDetailEveryEpisodeViewFromArray:(NSArray *)dataArray andEveryTVViewWidth:(CGFloat)width andEveryRowHaveTVViewCount:(int)count{
    
    float column = 0;
    if(dataArray.count%count==0)
        column = dataArray.count/count;
    else
        column = dataArray.count/count+1;
    float spacing = ([UtilityFunc shareInstance].globleWidth-count*width)/(count+1);
    
    if ((column*width+(column+1)*spacing)>self.contentScrollView.frame.size.height) {
        self.contentScrollView.contentSize = CGSizeMake([UtilityFunc shareInstance].globleWidth, (column*width+(column+1)*spacing));
    }
    RMDownLoadingViewController *downLoad = [RMDownLoadingViewController shared];
    for(int i=0;i<dataArray.count;i++){
        RMTVDownView *downView = [[[NSBundle mainBundle] loadNibNamed:@"RMTVDownView" owner:self options:nil] lastObject];
        downView.frame = CGRectMake((i%count+1)*spacing+i%count*width, (i/count+1)*spacing+i/count*width, width, width);
        downView.TVEpisodeButton.tag = i+1;
        downView.tag = i+1000;
        [downView.TVEpisodeButton setTitle:[NSString stringWithFormat:@"%d",i+1] forState:UIControlStateNormal];
        RMPublicModel *model = [self.TVdataArray objectAtIndex:i];
        
        NSString *tvString = [NSString stringWithFormat:@"电视剧_%@_%@",self.TVName,model.topNum];
        
        //判断改电视剧是否已经下载成功
        if([[Database sharedDatabase] isDownLoadMovieWithModelName:tvString]){
            downView.TVStateImageView.image = [UIImage imageNamed:@"tv_down_succes"];
        }
        else if([self isContainsModel:downLoad.dataArray modelName:tvString]){
            downView.TVStateImageView.image = [UIImage imageNamed:@"tv_downing"];
        }
        [downView.TVEpisodeButton addTarget:self action:@selector(TVEpisodeButtonCLick:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentScrollView addSubview:downView];
    }
}

//点击下载某一个集
- (void)TVEpisodeButtonCLick:(UIButton*)sender{
    
    RMPublicModel *model = [self.TVdataArray objectAtIndex:sender.tag-1];
    RMDownLoadingViewController *rmDownLoading = [RMDownLoadingViewController shared];
    NSString *tvString = [NSString stringWithFormat:@"电视剧_%@_%@",self.TVName,model.topNum];

    //判断改电视剧是否已经下载成功
    if([[Database sharedDatabase] isDownLoadMovieWithModelName:tvString]){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"已经下载成功了" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    else if([self isContainsModel:rmDownLoading.dataArray modelName:tvString]){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"已在下载队列中" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    RMTVDownView *downView = (RMTVDownView *)[self.contentScrollView viewWithTag:sender.tag-1+1000];
    downView.TVStateImageView.image = [UIImage imageNamed:@"tv_downing"];
    model.downLoadURL = model.downLoadURL;
    model.name = [NSString stringWithFormat:@"电视剧_%@_%@",self.TVName,model.topNum];
    model.downLoadState = @"等待缓存";
    model.totalMemory = @"0M";
    model.alreadyCasheMemory = @"0M";
    model.cacheProgress = @"0.0";
    model.pic = self.TVHeadImage;
    model.video_id = self.modelID;
    [rmDownLoading.dataArray addObject:model];
    [rmDownLoading.downLoadIDArray addObject:model];
    [rmDownLoading BeginDownLoad];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//下载所有的电视剧
- (IBAction)downAllTVEpisode:(UIButton *)sender {
    [Flurry logEvent:@"Click_VideoDownloadViewAllEpisode_Btn"];

    RMDownLoadingViewController *rmDownLoading = [RMDownLoadingViewController shared];
    for (int i=0;i<self.TVdataArray.count;i++){
        RMPublicModel *model = [self.TVdataArray objectAtIndex:i];
        if([[Database sharedDatabase] isDownLoadMovieWith:model]){
            
        }
        else if([rmDownLoading.dataArray containsObject:model]){
            
        }else{
            RMTVDownView *downView = (RMTVDownView *)[self.contentScrollView viewWithTag:i+1000];
            downView.TVStateImageView.image = [UIImage imageNamed:@"tv_downing"];
            model.name = [NSString stringWithFormat:@"电视剧_%@_%@",self.TVName,model.topNum];
            model.downLoadState = @"等待缓存";
            model.totalMemory = @"0M";
            model.alreadyCasheMemory = @"0M";
            model.cacheProgress = @"0.0";
            model.pic = self.TVHeadImage;
            model.video_id = self.modelID;
            [rmDownLoading.dataArray addObject:model];
            [rmDownLoading.downLoadIDArray addObject:model];
        }
    }
    [rmDownLoading BeginDownLoad];
}

#pragma mark - Base Method

- (void)navgationBarButtonClick:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
//    [[NSNotificationCenter defaultCenter] postNotificationName:kHideTabbar object:nil];
}

#pragma request finish
- (void)requestFinishiDownLoadWith:(NSMutableArray *)data{
    if(data.count>0){
        [SVProgressHUD dismiss];
        
        self.TVdataArray = data;
        [self headScrollviewAddBtnWithImage:[UIImage imageNamed:@"tv_download"] andBtnWidth:60];
        int count = 5,width = 50;
        if(IS_IPHONE_6_SCREEN||IS_IPHONE_6p_SCREEN){
            count = 6; width = 50;
        }
        [self addTVDetailEveryEpisodeViewFromArray:self.TVdataArray andEveryTVViewWidth:width andEveryRowHaveTVViewCount:count];
    }
    else{
        [SVProgressHUD showErrorWithStatus:@"下载失败"];
    }

}
- (void)requestError:(NSError *)error{
    NSLog(@"error:%@",error);
}

- (BOOL)isContainsModel:(NSMutableArray *)dataArray modelName:(NSString *)string{
    for(RMPublicModel *tmpModel in dataArray){
        if([tmpModel.name isEqualToString:string]){
            return YES;
        }
    }
    return NO;
}
@end
