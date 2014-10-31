//
//  RMStarViewController.m
//  RMVideo
//
//  Created by runmobile on 14-10-13.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMStarViewController.h"
#import "RMStarCell.h"
#import "RMImageView.h"
#import "RMBaseTextField.h"

#import "RMSetupViewController.h"
#import "RMStarDetailsViewController.h"

#import "RMVideoPlaybackDetailsViewController.h"

//搜索
#import "AMBlurView.h"
#import "RMHistoricalRecordsView.h"

//语音
#import "iflyMSC/IFlySpeechRecognizerDelegate.h"
#import "iflyMSC/IFlySpeechUtility.h"
#import "iflyMSC/IFlySpeechRecognizer.h"
#import "iflyMSC/IFlySpeechConstant.h"
#import "iflyMSC/IFlyResourceUtil.h"
#import <QuartzCore/QuartzCore.h>
#import "RecognizerFactory.h"
#import "ISRDataHelper.h"

#import "RMAFNRequestManager.h"

typedef enum{
    requestStarListType = 1,
    requestAddStarMyChannelType,
}LoadType;



#define searchTextField_TAG         101
#define cancelBtn_TAG               102
#define voiceBtn_TAG                103

@interface RMStarViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,StarCellDelegate,UIGestureRecognizerDelegate,IFlySpeechRecognizerDelegate,RMAFNRequestManagerDelegate> {
    NSMutableArray * dataArr;
    LoadType loadType;
}

@property (nonatomic, strong) AMBlurView * blurView;
@property (nonatomic, strong) UITableView * searchTableView;

@property (nonatomic, strong) UIImageView * voiceImg;
@property (nonatomic, strong) UIImageView * onVoiceImg;

@property (nonatomic, strong) NSArray * onVoiceImgArr;

//识别对象
@property (nonatomic, strong) IFlySpeechRecognizer * iFlySpeechRecognizer;
@property (nonatomic)         BOOL                 isCanceled;          //语音搜索是否取消
@property (nonatomic, strong) NSString             * onResult;          //语音正在搜索的结果
@property (nonatomic, strong) NSString             * result;            //语音搜索结束的结果

@property (nonatomic, strong) UIView               * coverView;         //遮挡textField 层

@end

@implementation RMStarViewController

- (instancetype)init {
    self = [super init];
    if (!self){
        return nil;
    }
    self.onResult = @"";
    self.result = @"";
    self.onVoiceImgArr = [NSArray arrayWithObjects:@"onVoice_1", @"onVoice_2", @"onVoice_3", @"onVoice_4", nil];
    _iFlySpeechRecognizer = [RecognizerFactory CreateRecognizer:self Domain:@"iat"];
    [_iFlySpeechRecognizer setParameter:@"0" forKey:@"asr_ptt"];
    
    return self;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self loadDefaultHandInputSearchView];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    //取消识别
    [_iFlySpeechRecognizer cancel];
    [_iFlySpeechRecognizer setDelegate: nil];
    
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    loadType = requestStarListType;

    dataArr = [[NSMutableArray alloc] init];
    
    [self setTitle:@"明星"];
    [leftBarButton setImage:LOADIMAGE(@"setup", kImageTypePNG) forState:UIControlStateNormal];
    rightBarButton.hidden = YES;
    
    RMImageView * searchImg = [[RMImageView alloc] init];
    searchImg.frame = CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth, 45);
    searchImg.backgroundColor = [UIColor clearColor];
    searchImg.image = LOADIMAGE(@"mx_searchBar", kImageTypePNG);
    searchImg.userInteractionEnabled = YES;
    [self.view addSubview:searchImg];
    
    RMBaseTextField * searchTextField = [[RMBaseTextField alloc] init];
    searchTextField.tag = searchTextField_TAG;
    searchTextField.delegate = self;
    [[RMBaseTextField appearance] setTintColor:[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1]];
    searchTextField.returnKeyType = UIReturnKeySearch;
    searchTextField.textColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1];
    searchTextField.frame = CGRectMake(18, 8, [UtilityFunc shareInstance].globleWidth - 140, 30);
    searchTextField.placeholder = @"搜索你喜欢的明星";
    searchTextField.font = [UIFont systemFontOfSize:14.0];
    searchTextField.backgroundColor = [UIColor clearColor];
    [self.view addSubview:searchTextField];
    
    self.coverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth - 110, 45)];
    self.coverView.backgroundColor = [UIColor clearColor];
    self.coverView.userInteractionEnabled = NO;
    self.coverView.multipleTouchEnabled = NO;
    
    UIButton * cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame = CGRectMake([UtilityFunc shareInstance].globleWidth - 115, 8, 70, 30);
    cancelBtn.hidden = YES;
    [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(mbuttonClick:) forControlEvents:UIControlEventTouchUpInside];
    cancelBtn.tag = cancelBtn_TAG;
    [self.view addSubview:cancelBtn];
    
    UIButton * voiceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    voiceBtn.tag = voiceBtn_TAG;
    voiceBtn.backgroundColor = [UIColor clearColor];
    voiceBtn.frame = CGRectMake([UtilityFunc shareInstance].globleWidth - 40, 8, 30, 30);
    [voiceBtn setBackgroundImage:LOADIMAGE(@"mx_voiceBtn_img", kImageTypePNG) forState:UIControlStateNormal];
    [voiceBtn addTarget:self action:@selector(mbuttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:voiceBtn];
    
    UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 45, [UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleHeight - 45 - 44 - 49) style:UITableViewStylePlain];
    tableView.tag = 201;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:tableView];

    //TODO:上拉刷新， 下拉加载更多

    RMAFNRequestManager * requset = [[RMAFNRequestManager alloc] init];
    [requset getStarListWithPage:@"1" count:@"12"];
    requset.delegate = self;
}

#pragma mark - 默认输入搜索界面

- (void)loadDefaultHandInputSearchView {
    //初始化View
    self.blurView = [[AMBlurView alloc] init];
    self.blurView.frame = CGRectMake(0, 45, [UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleAllHeight - 64 - 45 - 49);
    [self.blurView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    self.blurView.userInteractionEnabled = YES;
    [self.view addSubview:self.blurView];
    self.blurView.hidden = YES;
    
    self.searchTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleAllHeight - 64 - 45 - 49) style:UITableViewStylePlain];
    self.searchTableView.tag = 202;
    self.searchTableView.delegate = self;
    self.searchTableView.dataSource = self;
    self.searchTableView.backgroundColor = [UIColor clearColor];
    self.searchTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.blurView addSubview:self.searchTableView];
    self.searchTableView.hidden = YES;
    
    //初始化 清空历史记录View
    RMHistoricalRecordsView * historicalRecordsView = [[RMHistoricalRecordsView alloc] init];
    historicalRecordsView.frame = CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth, 40);
    historicalRecordsView.userInteractionEnabled = YES;
    historicalRecordsView.backgroundColor = [UIColor clearColor];
    self.searchTableView.tableHeaderView = historicalRecordsView;
    
    UITapGestureRecognizer *historicalRecordsViewRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clearHistoryRecords:)];
    historicalRecordsViewRecognizer.numberOfTouchesRequired = 1;
    historicalRecordsViewRecognizer.numberOfTapsRequired = 1;
    historicalRecordsViewRecognizer.delegate = self;
    [historicalRecordsView addGestureRecognizer:historicalRecordsViewRecognizer];
}

- (void)loadAddCovertextField {
    ((RMBaseTextField *)[self.view viewWithTag:searchTextField_TAG]).enabled = NO;
    [self.view addSubview:self.coverView];
    [self.coverView bringSubviewToFront:self.view];
}

- (void)loadRemoveCovertextField {
    ((RMBaseTextField *)[self.view viewWithTag:searchTextField_TAG]).enabled = YES;
    [self.coverView removeFromSuperview];
}

#pragma mark - 默认语音搜索界面

- (void)loadDefaultVoiceInputSearchView {
    self.blurView.hidden = NO;
    self.searchTableView.hidden = YES;
    self.voiceImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleAllHeight - 64 - 45 - 49)];
    self.voiceImg.userInteractionEnabled = YES;
    self.voiceImg.image = LOADIMAGE(@"mx_voice_img", kImageTypePNG);
    self.voiceImg.image = [self.voiceImg.image resizableImageWithCapInsets:UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0)];
    self.voiceImg.backgroundColor = [UIColor clearColor];
    [self.blurView addSubview:self.voiceImg];
    
    self.onVoiceImg = [[UIImageView alloc] initWithFrame:CGRectMake([UtilityFunc shareInstance].globleWidth/2 - 45, [UtilityFunc shareInstance].globleAllHeight/2 - 145, 90, 90)];
    self.onVoiceImg.userInteractionEnabled = YES;
    self.onVoiceImg.backgroundColor=  [UIColor clearColor];
    self.onVoiceImg.image = LOADIMAGE([self.onVoiceImgArr objectAtIndex:3], kImageTypePNG);
    [self.voiceImg addSubview:self.onVoiceImg];

    UITapGestureRecognizer *onVoiceRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(stopVoiceSearchRecognizer:)];
    onVoiceRecognizer.numberOfTouchesRequired = 1;
    onVoiceRecognizer.numberOfTapsRequired = 1;
    onVoiceRecognizer.delegate = self;
    [self.onVoiceImg addGestureRecognizer:onVoiceRecognizer];
}

#pragma mark - 取消 语音搜索 方法

- (void)mbuttonClick:(UIButton *)sender {
    switch (sender.tag) {
        case cancelBtn_TAG: {
            ((UIButton *)[self.view viewWithTag:cancelBtn_TAG]).hidden = YES;
            self.blurView.hidden = YES;
            self.searchTableView.hidden = YES;
            [_iFlySpeechRecognizer cancel];
            self.voiceImg.hidden = YES;
            [self cancelSearch];
            
            break;
        }
        case voiceBtn_TAG: {
            self.isCanceled = NO;

            [self loadAddCovertextField];
            [(RMBaseTextField *)[self.view viewWithTag:searchTextField_TAG] resignFirstResponder];
            [self loadDefaultVoiceInputSearchView];
            
            //设置为录音模式
            [_iFlySpeechRecognizer setParameter:IFLY_AUDIO_SOURCE_MIC forKey:@"audio_source"];
            bool ret = [_iFlySpeechRecognizer startListening];
            if (ret) {
                ((UIButton *)[self.view viewWithTag:voiceBtn_TAG]).enabled = NO;
            }else{
                NSLog(@"启动识别服务失败，请稍后重试");//可能是上次请求未结束，暂不支持多路并发
            }
            break;
        }
            
        default:
            break;
    }
}

#pragma mark - IFlySpeechRecognizerDelegate

/**
 * @fn      onVolumeChanged
 * @brief   音量变化回调
 *
 * @param   volume      -[in] 录音的音量，音量范围1~100
 * @see
 */
- (void) onVolumeChanged: (int)volume {
    if (self.isCanceled) {
        return;
    }
    if (volume>=0 && volume <=24){
        self.onVoiceImg.image = NULL;
        self.onVoiceImg.image = LOADIMAGE([self.onVoiceImgArr objectAtIndex:3], kImageTypePNG);
    }else if (volume >=25 && volume <=49){
        self.onVoiceImg.image = NULL;
        self.onVoiceImg.image = LOADIMAGE([self.onVoiceImgArr objectAtIndex:2], kImageTypePNG);
    }else if (volume >=50 && volume <=74){
        self.onVoiceImg.image = NULL;
        self.onVoiceImg.image = LOADIMAGE([self.onVoiceImgArr objectAtIndex:1], kImageTypePNG);
    }else if (volume >= 75 && volume <=100){
        self.onVoiceImg.image = NULL;
        self.onVoiceImg.image = LOADIMAGE([self.onVoiceImgArr objectAtIndex:0], kImageTypePNG);
    }
}

/**
 * @fn      onBeginOfSpeech
 * @brief   开始识别回调
 *
 * @see
 */
- (void) onBeginOfSpeech {
    NSLog(@"正在录音");
    [self loadAddCovertextField];
}

/**
 * @fn      onEndOfSpeech
 * @brief   停止录音回调
 *
 * @see
 */
- (void) onEndOfSpeech {
    NSLog(@"停止录音");
}

/**
 * @fn      onError
 * @brief   识别结束回调
 *
 * @param   errorCode   -[out] 错误类，具体用法见IFlySpeechError
 */
- (void) onError:(IFlySpeechError *) error {
    NSString *text ;
    
    if (self.isCanceled) {
        text = @"识别取消";
    }
    else if (error.errorCode ==0 ) {
        
        if (_result.length==0) {
            
            text = @"无识别结果";
        }else{
            text = @"识别成功";
        }
    }else{
        text = [NSString stringWithFormat:@"发生错误：%d %@",error.errorCode,error.errorDesc];
        
        NSLog(@"%@",text);
    }
    ((UIButton *)[self.view viewWithTag:voiceBtn_TAG]).enabled = YES;
    [self loadRemoveCovertextField];
}

/**
 * @fn      onResults
 * @brief   识别结果回调
 *
 * @param   result      -[out] 识别结果，NSArray的第一个元素为NSDictionary，NSDictionary的key为识别结果，value为置信度
 * @see
 */
- (void) onResults:(NSArray *) results isLast:(BOOL)isLast {
    NSMutableString *resultString = [[NSMutableString alloc] init];
    
    NSDictionary *dic = results[0];
    
    for (NSString *key in dic) {
        [resultString appendFormat:@"%@",key];
    }

    self.result =[NSString stringWithFormat:@"%@%@", self.onResult,resultString];
    
    NSString * resultFromJson =  [[ISRDataHelper shareInstance] getResultFromJson:resultString];
    
    self.onResult = [NSString stringWithFormat:@"%@%@", self.onResult,resultFromJson];
    
    if (isLast) {
        NSLog(@"听写结果(json)：%@测试",self.result);
    }
    
    if (self.result.length == 0){
        NSLog(@"没有搜索词");
        ((UIButton *)[self.view viewWithTag:cancelBtn_TAG]).hidden = YES;
        self.blurView.hidden = YES;
        self.voiceImg.hidden = YES;

    }else{
        NSLog(@"有搜索词");
        ((UIButton *)[self.view viewWithTag:cancelBtn_TAG]).hidden = NO;
        ((RMBaseTextField *)[self.view viewWithTag:searchTextField_TAG]).text = self.onResult;
        self.voiceImg.hidden = YES;
        self.blurView.hidden = NO;
        self.searchTableView.hidden = NO;
        
        //TODO:给textField.text 赋值，并开始搜索三

    }
    [self loadRemoveCovertextField];
}

/**
 * @fn      onCancel
 * @brief   取消识别回调
 * 当调用了`cancel`函数之后，会回调此函数，在调用了cancel函数和回调onError之前会有一个短暂时间，您可以在此函数中实现对这段时间的界面显示。
 * @param
 * @see
 */
- (void) onCancel {
    NSLog(@"识别取消");
}

#pragma mark - 更新用户查询记录  并持久化数据

- (void)updateUserSearchRecord:(NSString *)SearchRecord {
    /*
    NSUserDefaults *UserAttentionArrDefault = [NSUserDefaults standardUserDefaults];
    NSMutableArray * attentionArr = [[NSMutableArray alloc]initWithArray:[UserAttentionArrDefault objectForKey:@"UserAttentionArrDefault"]];
    [attentionArr addObject:SearchRecord];
    int i=0;
    int j=0;
    for(i=0; i<[attentionArr count]-1; i++){ //循环开始元素
        for(j=i+1;j <[attentionArr count]; j++){ //循环后续所有元素
            //如果相等，则重复
            if([[attentionArr objectAtIndex:i] isEqualToString:[attentionArr objectAtIndex:j]]){
                [attentionArr removeObjectAtIndex:i];
                i=0;
            }
            
        }
    }
    SearchRecordsArr = attentionArr;
    [UserAttentionArrDefault setObject:attentionArr forKey:@"UserAttentionArrDefault"];
    [UserAttentionArrDefault synchronize];  //保存到disk
     */
}

#pragma mark - UIGestureRecognizerDelegate-清空历史记录    UITextField Delegate

- (void)stopVoiceSearchRecognizer:(id)sender {
    [_iFlySpeechRecognizer stopListening];
}

- (void)clearHistoryRecords:(id)sender {
    NSLog(@"清空历史记录");
    /*
    NSUserDefaults *UserAttentionArrDefault = [NSUserDefaults standardUserDefaults];
    NSMutableArray * attentionArr = [[NSMutableArray alloc]initWithArray:[UserAttentionArrDefault objectForKey:@"UserAttentionArrDefault"]];
    [attentionArr removeAllObjects];
    [UserAttentionArrDefault setObject:attentionArr forKey:@"UserAttentionArrDefault"];
    [UserAttentionArrDefault synchronize];  //保存到disk
    
    [SearchRecordsArr removeAllObjects];
    UITableView * DefaultTableView = (UITableView *)[self.view viewWithTag:DefaultTableView_TAG];
    [DefaultTableView reloadData];
    DefaultTableView.tableFooterView = nil;
    */
}

- (void)startSearch {
    ((UIButton *)[self.view viewWithTag:cancelBtn_TAG]).hidden = NO;
    self.blurView.hidden = NO;
    self.searchTableView.hidden = NO;
}

- (void)cancelSearch {
    [(RMBaseTextField *)[self.view viewWithTag:searchTextField_TAG] resignFirstResponder];
    ((RMBaseTextField *)[self.view viewWithTag:searchTextField_TAG]).text = @"";
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self cancelSearch];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    //TODO:搜索一
    NSLog(@"开始搜索");
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self startSearch];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [self cancelSearch];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (range.location >= 11){
        return NO;
    }else{
        return YES;
    }
}

#pragma mark - UITableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (tableView.tag) {
        case 201:{
            if ([dataArr count]/3 == 0){
                return [dataArr count]/3;
            }else if ([dataArr count]/3 == 1){
                return ([dataArr count] + 2) / 3;
            }else {
                return ([dataArr count] + 1) / 3;
            }
            break;
        }
        case 202:{
            return 15;
            break;
        }
            
        default:
            return 0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag == 201){
        static NSString * CellIdentifier = @"RMStarCellIdentifier";
        RMStarCell * cell = (RMStarCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (! cell) {
            /*
             cell = [[RMStarCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
             [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
             cell.backgroundColor = [UIColor clearColor];
             */
            
            NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"RMStarCell" owner:self options:nil];
            cell = [array objectAtIndex:0];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            cell.backgroundColor = [UIColor clearColor];
            cell.delegate = self;
        }
        
        RMPublicModel *model_left = [dataArr objectAtIndex:indexPath.row*3];
        RMPublicModel *model_center = [dataArr objectAtIndex:indexPath.row*3 + 1];
        RMPublicModel *model_right = [dataArr objectAtIndex:indexPath.row*3 + 2];
        
        cell.leftTitle.text = model_left.name;
        [cell.starLeftImg setImageWithURL:[NSURL URLWithString:model_left.pic_url] placeholderImage:nil];
        
        cell.centerTitle.text = model_center.name;
        [cell.starCenterImg setImageWithURL:[NSURL URLWithString:model_center.pic_url] placeholderImage:nil];
        
        cell.rightTitle.text = model_right.name;
        [cell.starRightImg setImageWithURL:[NSURL URLWithString:model_right.pic_url] placeholderImage:nil];
 
        cell.starLeftImg.identifierString = model_left.tag_id;
        cell.starCenterImg.identifierString = model_center.tag_id;
        cell.starRightImg.identifierString = model_right.tag_id;

        cell.starAddLeftImg.identifierString = model_left.tag_id;
        cell.starAddCenterImg.identifierString = model_center.tag_id;
        cell.starAddRightImg.identifierString = model_right.tag_id;
        
        return cell;
    }else {
        static NSString * CellIdentifier = @"RMStarSearchCellIdentifier";
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (! cell) {
             cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
             [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
             cell.backgroundColor = [UIColor clearColor];
            
            /*

            NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"RMStarCell" owner:self options:nil];
            cell = [array objectAtIndex:0];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            cell.backgroundColor = [UIColor clearColor];
            cell.delegate = self;
             */

        }
        cell.textLabel.text = @"搜索";
        return cell;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (tableView.tag) {
        case 201:{
            NSInteger value = 0;
            if ([dataArr count]/3 == 0){
                value = [dataArr count]/3;
            }else if ([dataArr count]/3 == 1){
                value = ([dataArr count] + 2) / 3;
            }else {
                value = ([dataArr count] + 1) / 3;
            }
            
            if (indexPath.row == value - 1){
                return 135;
            }else{
                return 125;
            }

            break;
        }
        case 202:{
            return 40;

            break;
        }

        default:
            return 0;
            break;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (tableView.tag) {
        case 201:{
            
            break;
        }
        case 202:{
            //TODO:搜索二
            NSLog(@"开始搜索");
            
            break;
        }
            
        default:
            break;
    }
}

#pragma mark - 进入明星详情页面

- (void)clickVideoImageViewMehtod:(RMImageView *)imageView {
    if (imageView.identifierString) {
        RMStarDetailsViewController * starDetailsCtl = [[RMStarDetailsViewController alloc] init];
        [self.navigationController pushViewController:starDetailsCtl animated:YES];
        [starDetailsCtl setStarID:imageView.identifierString];
        [[NSNotificationCenter defaultCenter] postNotificationName:kHideTabbar object:nil];
    }
}

#pragma mark - 添加明星到我的频道

- (void)clickAddMyChannelMethod:(RMImageView *)imageView {
    if (imageView.identifierString){
        loadType = requestAddStarMyChannelType;
        RMAFNRequestManager * requset = [[RMAFNRequestManager alloc] init];
        [requset getJoinMyChannelWithToken:testToken andID:imageView.identifierString];
        requset.delegate = self;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    switch (scrollView.tag) {
        case 201:{
            [self cancelSearch];
            break;
        }
        case 202:{
            [(RMBaseTextField *)[self.view viewWithTag:searchTextField_TAG] resignFirstResponder];

            break;
        }
            
        default:
            break;
    }
}

#pragma mark - Base Method

- (void)navgationBarButtonClick:(UIBarButtonItem *)sender {
    switch (sender.tag) {
        case 1:{
            RMSetupViewController * setupCtl = [[RMSetupViewController alloc] init];
            [self presentViewController:[[UINavigationController alloc] initWithRootViewController:setupCtl] animated:YES completion:^{
                
            }];
            [[NSNotificationCenter defaultCenter] postNotificationName:kHideTabbar object:nil];
            break;
        }
        case 2:{
            
            break;
        }

        default:
            break;
    }
}

#pragma mark - request RMAFNRequestManagerDelegate

- (void)requestFinishiDownLoadWith:(NSMutableArray *)data {
    if (loadType == requestStarListType){
        dataArr = data;
        [(UITableView *)[self.view viewWithTag:201] reloadData];
    }else if (loadType == requestAddStarMyChannelType){
        
    }
}

- (void)requestError:(NSError *)error {
    
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
