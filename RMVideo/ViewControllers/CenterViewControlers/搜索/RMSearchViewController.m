//
//  RMSearchViewController.m
//  RMVideo
//
//  Created by runmobile on 14-10-13.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMSearchViewController.h"
#import "RMImageView.h"
#import "RMBaseTextField.h"
#import "RMSearchRecordsCell.h"
#import "RMSearchResultViewController.h"
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
#import "RMCustomNavViewController.h"
#import "RMCustomPresentNavViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "RMTagList.h"
#import "RMLastRecordsCell.h"

#define searchTextField_TAG             101
#define cancelBtn_TAG                   102
#define voiceBtn_TAG                    103

@interface RMSearchViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,IFlySpeechRecognizerDelegate,UIGestureRecognizerDelegate,RMAFNRequestManagerDelegate,UIAlertViewDelegate,SearchRecordsDelegate,LastRecordsDelegate,TagListDelegate>{
    NSMutableArray * recordsDataArr;
}
@property (nonatomic, strong) AMBlurView * blurView;
@property (nonatomic, strong) UITableView * searchTableView;

@property (nonatomic, strong) IFlySpeechRecognizer * iFlySpeechRecognizer;
@property (nonatomic)         BOOL                 isCanceled;          //语音搜索是否取消
@property (nonatomic, strong) NSString             * onResult;          //语音正在搜索的结果
@property (nonatomic, strong) NSString             * result;            //语音搜索结束的结果
@property (nonatomic, strong) RMAFNRequestManager * request;
@property (nonatomic, strong) NSArray * onVoiceImgArr;
@property (nonatomic, strong) RMImageView * voiceImage;
@property (nonatomic, strong) RMHistoricalRecordsView * historicalRecordsView;
@property (nonatomic, assign) BOOL isDisplayMoreRecords;               //是否显示 展开更多搜索记录

@property (nonatomic, strong) UIView * footView;                        //tableView 的 footView
@property (nonatomic, strong) RMTagList * tagList;                      //taglistView

@end

@implementation RMSearchViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [Flurry logEvent:@"VIEW_Search" timed:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    //取消识别
    [_iFlySpeechRecognizer cancel];
    [_iFlySpeechRecognizer setDelegate: nil];
    [super viewWillDisappear:animated];
    [Flurry endTimedEvent:@"VIEW_Search" withParameters:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_iFlySpeechRecognizer setDelegate: self];
    self.onResult = @"";
    self.result = @"";
    
    CUSFileStorage *storage = [CUSFileStorageManager getFileStorage:CURRENTENCRYPTFILE];
    NSMutableArray * arr = [[NSMutableArray alloc] initWithArray:[storage objectForKey:UserSearchRecordData_KEY]];
    recordsDataArr = arr;
    if (recordsDataArr.count > 2){
        self.isDisplayMoreRecords = YES;
    }else{
        self.isDisplayMoreRecords = NO;
    }
    [self.searchTableView reloadData];
    [self refreshRecodsView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    recordsDataArr = [[NSMutableArray alloc] init];
    self.onVoiceImgArr = [NSArray arrayWithObjects:@"onVoice_1", @"onVoice_2", @"onVoice_3", @"onVoice_4", nil];

    [self setTitle:@"搜索"];
    leftBarButton.hidden = YES;
    rightBarButton.frame = CGRectMake(0, 0, 35, 20);
    [rightBarButton setBackgroundImage:LOADIMAGE(@"cancle_btn_image", kImageTypePNG) forState:UIControlStateNormal];
    
    self.result = @"";
    self.onResult = @"";
    
    _iFlySpeechRecognizer = [RecognizerFactory CreateRecognizer:self Domain:@"iat"];
    [_iFlySpeechRecognizer setParameter:@"0" forKey:@"asr_ptt"];
    
    [self loadCustom];
}

- (void)loadCustom {
    self.searchTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleAllHeight - 64) style:UITableViewStylePlain];
    self.searchTableView.tag = 201;
    self.searchTableView.delegate = self;
    self.searchTableView.dataSource = self;
    self.searchTableView.backgroundColor = [UIColor clearColor];
    self.searchTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.searchTableView];
    
    UIView * headView = [[UIView alloc] init];
    headView.backgroundColor = [UIColor whiteColor];
    headView.frame = CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth, 90);
    headView.userInteractionEnabled = YES;
    
    UIView *roundBgView =[[UIView alloc] initWithFrame:CGRectMake(10, 15, [UtilityFunc shareInstance].globleWidth - 20, 60)];
    [[roundBgView layer] setBorderWidth:2.0];//画线的宽度
    [[roundBgView layer] setBorderColor:[UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1].CGColor];//颜色
    roundBgView.userInteractionEnabled = YES;
    roundBgView.multipleTouchEnabled = YES;
    [[roundBgView layer]setCornerRadius:30.0];//圆角
    roundBgView.backgroundColor = [UIColor clearColor];
    [headView addSubview:roundBgView];
    
    RMBaseTextField * searchTextField = [[RMBaseTextField alloc] init];
    searchTextField.tag = searchTextField_TAG;
    searchTextField.delegate = self;
    [[RMBaseTextField appearance] setTintColor:[UIColor redColor]];
    searchTextField.returnKeyType = UIReturnKeySearch;
    searchTextField.textColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1];
    searchTextField.frame = CGRectMake(18, 20, [UtilityFunc shareInstance].globleWidth - 40, 50);
    searchTextField.placeholder = @"搜索你喜欢的电影或明星";
    searchTextField.font = [UIFont systemFontOfSize:20.0];
    searchTextField.backgroundColor = [UIColor clearColor];
    [searchTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [headView addSubview:searchTextField];

    RMImageView * searchImg = [[RMImageView alloc] init];
    searchImg.frame = CGRectMake([UtilityFunc shareInstance].globleWidth - 50, 33, 25, 24);
    searchImg.backgroundColor = [UIColor clearColor];
    searchImg.userInteractionEnabled = YES;
    [searchImg addTarget:self WithSelector:@selector(searchMethod)];
    searchImg.image = LOADIMAGE(@"ic_search", kImageTypePNG);
    [headView addSubview:searchImg];
    self.searchTableView.tableHeaderView = headView;
    
    self.footView = [[UIView alloc] init];
    self.footView.backgroundColor = [UIColor clearColor];
    self.footView.frame = CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth, 255); //176
    self.footView.userInteractionEnabled = YES;
    self.footView.multipleTouchEnabled = YES;
    
    UILabel * footTitle = [[UILabel alloc] init];
    footTitle.backgroundColor = [UIColor clearColor];
    footTitle.frame = CGRectMake(10, 10, 100, 30);
    footTitle.text = @"全网热榜";
    footTitle.textColor = [UIColor colorWithRed:0.22 green:0.22 blue:0.22 alpha:1];
    footTitle.font = [UIFont systemFontOfSize:20];
    [self.footView addSubview:footTitle];
    
    self.tagList = [[RMTagList alloc] initWithFrame:CGRectMake(10, 50.0f, [UtilityFunc shareInstance].globleWidth - 20, 176)];
    self.tagList.delegate = self;
    NSArray *array = [[NSArray alloc] initWithObjects:@"红高粱", @"变形金刚", @"致我们终将逝去的青春", @"空中求援", @"碟中谍", @"不能说的秘密", nil];
    [self.tagList setTags:array];
    [self.footView addSubview:self.tagList];
    self.searchTableView.tableFooterView = self.footView;
}

- (void)refreshRecodsView {
    if ([recordsDataArr count] == 0) {
        [self.historicalRecordsView updateDisplayTitle:@"没有历史记录"];
    }else{
        [self.historicalRecordsView updateDisplayTitle:@"清空历史记录"];
    }
}

- (void)searchMethod{
    //TODO: 开始搜索四
    [(RMBaseTextField *)[self.view viewWithTag:searchTextField_TAG] resignFirstResponder];
    NSString * text = ((RMBaseTextField *)[self.view viewWithTag:searchTextField_TAG]).text;
    
    if ([UtilityFunc isConnectionAvailable] == 0) {
        [SVProgressHUD showErrorWithStatus:kShowConnectionAvailableError duration:1.0];
    }else {
        [SVProgressHUD dismiss];
        [self updateUserSearchRecord:text];
        [self.searchTableView reloadData];
        [self startSearchRequest:text];
    }
}

#pragma mark - 更新用户查询记录  并持久化数据
/**
 * 更新用户查询记录  并持久化数据
 */
- (void)updateUserSearchRecord:(NSString *)SearchRecord {
    if (SearchRecord.length == 0) {
        return;
    }
    CUSFileStorage *storage = [CUSFileStorageManager getFileStorage:CURRENTENCRYPTFILE];
    [storage beginUpdates];
    NSString * userSearchRecord = [AESCrypt encrypt:SearchRecord password:PASSWORD];
    [recordsDataArr addObject:userSearchRecord];
    int i=0;
    int j=0;
    for(i=0; i<[recordsDataArr count]-1; i++){ //循环开始元素
        for(j=i+1;j <[recordsDataArr count]; j++){ //循环后续所有元素
            //如果相等，则重复
            if([[recordsDataArr objectAtIndex:i] isEqualToString:[recordsDataArr objectAtIndex:j]]){
                [recordsDataArr removeObjectAtIndex:i];
                i=0;
            }
        }
    }
    [storage setObject:recordsDataArr forKey:UserSearchRecordData_KEY];
    [storage endUpdates];
    [self refreshRecodsView];
}

#pragma mark - UIScrollViewDelegate UITextField Delegate TagListDelegate

- (void)startSearch {
    ((UIButton *)[self.view viewWithTag:cancelBtn_TAG]).hidden = NO;
}

- (void)cancelSearch {
    [(RMBaseTextField *)[self.view viewWithTag:searchTextField_TAG] resignFirstResponder];
    ((UIButton *)[self.view viewWithTag:cancelBtn_TAG]).hidden = YES;
    ((RMBaseTextField *)[self.view viewWithTag:searchTextField_TAG]).text = @"";
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self cancelSearch];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    //TODO: 开始搜索一
    if ([UtilityFunc isConnectionAvailable] == 0){
        [SVProgressHUD showErrorWithStatus:kShowConnectionAvailableError duration:1.0];
        return NO;
    }else{
        [SVProgressHUD dismiss];
        [SVProgressHUD showWithStatus:@"搜索中..." maskType:SVProgressHUDMaskTypeBlack];
        [self updateUserSearchRecord:textField.text];
        [self.searchTableView reloadData];
        [self startSearchRequest:textField.text];
    }
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self startSearch];
    return YES;
}

- (void)textFieldDidChange:(UITextField *)textField {
    if (textField.text.length > 20) {
        textField.text = [textField.text substringToIndex:20];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [(RMBaseTextField *)[self.view viewWithTag:searchTextField_TAG] resignFirstResponder];
}

- (void)clickTagWithValue:(int)value {
    NSLog(@"value:%d",value);
}

- (void)refreshTagListViewHeight:(float)height {
    [UIView animateWithDuration:0.2 animations:^{
        self.footView.frame = CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth, height + 85);
        self.searchTableView.tableFooterView = self.footView;
        self.tagList.frame = CGRectMake(10, 50.0f, [UtilityFunc shareInstance].globleWidth - 20, height + 20);
    }];
}

#pragma mark - UITableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (recordsDataArr.count > 2){
        if (self.isDisplayMoreRecords){
            return 3;
        }else{
            return [recordsDataArr count];
        }
    }else{
        return [recordsDataArr count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isDisplayMoreRecords){
        if (indexPath.row == 2){
            static NSString * CellIdentifier = @"RMLastSearchCellIdentifier";
            RMLastRecordsCell * cell = (RMLastRecordsCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (! cell) {
                NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"RMLastRecordsCell" owner:self options:nil];
                cell = [array objectAtIndex:0];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                cell.backgroundColor = [UIColor whiteColor];
                cell.delegate = self;
            }
            return cell;
        }else{
            static NSString * CellIdentifier = @"RMSearchCellIdentifier";
            RMSearchRecordsCell * cell = (RMSearchRecordsCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (! cell) {
                NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"RMSearchRecordsCell" owner:self options:nil];
                cell = [array objectAtIndex:0];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                cell.backgroundColor = [UIColor whiteColor];
                cell.delegate = self;
            }
            cell.clickbtn.tag = indexPath.row;
            cell.recordsName.text = [NSString stringWithFormat:@"%@",[AESCrypt decrypt:[recordsDataArr objectAtIndex:indexPath.row] password:PASSWORD]];
            return cell;
        }
    }else{
        static NSString * CellIdentifier = @"RMSearchCellIdentifier";
        RMSearchRecordsCell * cell = (RMSearchRecordsCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (! cell) {
            NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"RMSearchRecordsCell" owner:self options:nil];
            cell = [array objectAtIndex:0];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            cell.backgroundColor = [UIColor whiteColor];
            cell.delegate = self;
        }
        cell.clickbtn.tag = indexPath.row;
        cell.recordsName.text = [NSString stringWithFormat:@"%@",[AESCrypt decrypt:[recordsDataArr objectAtIndex:indexPath.row] password:PASSWORD]];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //TODO:开始搜索二
    if ([UtilityFunc isConnectionAvailable] == 0){
        [SVProgressHUD showErrorWithStatus:kShowConnectionAvailableError duration:1.0];
        return ;
    }
    NSString * str = [NSString stringWithFormat:@"%@",[AESCrypt decrypt:[recordsDataArr objectAtIndex:indexPath.row] password:PASSWORD]];
    [SVProgressHUD dismiss];
    [SVProgressHUD showWithStatus:@"搜索中..." maskType:SVProgressHUDMaskTypeBlack];
    [self startSearchRequest:str];
}

/**
 *  删除单个搜索记录
 */
- (void)deleteSearchRecordsMethod:(int)value {
    [recordsDataArr removeObjectAtIndex:value];
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:value inSection:0];
    NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
    [self.searchTableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    CUSFileStorage *storage = [CUSFileStorageManager getFileStorage:CURRENTENCRYPTFILE];
    NSMutableArray * arr = [[NSMutableArray alloc] initWithArray:[storage objectForKey:UserSearchRecordData_KEY]];
    [arr removeObjectAtIndex:value];
    [storage beginUpdates];
    [storage setObject:arr forKey:UserSearchRecordData_KEY];
    [storage endUpdates];
    [self refreshRecodsView];
    [self.searchTableView reloadData];
}

/**
 *  多于两个搜索记录的时候，显示更多搜索记录
 */
- (void)moreRecordsMethod {
    self.isDisplayMoreRecords = NO;
    [self.searchTableView reloadData];
}

#pragma mark - requset RMAFNRequestManagerDelegate

- (void)startSearchRequest:(NSString *)key {
    [(RMBaseTextField *)[self.view viewWithTag:searchTextField_TAG] resignFirstResponder];
    [SVProgressHUD showWithStatus:@"正在搜索" maskType:SVProgressHUDMaskTypeBlack];
    self.request = [[RMAFNRequestManager alloc] init];
    [self.request getSearchVideoWithKeyword:[key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] Page:@"1" count:@"20"];
    self.request.delegate = self;
}

- (void)requestFinishiDownLoadWith:(NSMutableArray *)data {
    [SVProgressHUD dismiss];
    RMSearchResultViewController * searchResultCtl = [[RMSearchResultViewController alloc] init];
    searchResultCtl.resultData = data;
    RMCustomPresentNavViewController * searchResultNav = [[RMCustomPresentNavViewController alloc] initWithRootViewController:searchResultCtl];
    [self presentViewController:searchResultNav animated:YES completion:^{
    }];
}

- (void)requestError:(NSError *)error {
    NSLog(@"error:%@",error);
}

#pragma mark - Base Method

- (void)navgationBarButtonClick:(UIBarButtonItem *)sender {
    switch (sender.tag) {
        case 1:{
            break;
        }
        case 2:{
            [(RMBaseTextField *)[self.view viewWithTag:searchTextField_TAG] resignFirstResponder];
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
                [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];
            }
            [self dismissViewControllerAnimated:YES completion:^{
            }];
            [[NSNotificationCenter defaultCenter] postNotificationName:kAppearTabbar object:nil];
            break;
        }
            
        default:
            break;
    }
}

#pragma mark - IFlySpeechRecognizerDelegate

/*
 //设置为录音模式
 [_iFlySpeechRecognizer setParameter:IFLY_AUDIO_SOURCE_MIC forKey:@"audio_source"];
 bool ret = [_iFlySpeechRecognizer startListening];
 if (ret) {
 ((UIButton *)[self.view viewWithTag:voiceBtn_TAG]).enabled = NO;
 }else{
 NSLog(@"启动识别服务失败，请稍后重试");//可能是上次请求未结束，暂不支持多路并发
 [SVProgressHUD showErrorWithStatus:@"启动语音搜索服务失败" duration:0.44];
 }
 */
/**
 * @fn      onVolumeChanged
 * @brief   音量变化回调
 *
 * @param   volume      -[in] 录音的音量，音量范围1~100
 * @see
 */
- (void)onVolumeChanged: (int)volume {
    if (self.isCanceled) {
        return;
    }
    if (volume>=0 && volume <=5){
        self.voiceImage.image = NULL;
        self.voiceImage.image = LOADIMAGE([self.onVoiceImgArr objectAtIndex:3], kImageTypePNG);
    }else if (volume >=6 && volume <=10){
        self.voiceImage.image = NULL;
        self.voiceImage.image = LOADIMAGE([self.onVoiceImgArr objectAtIndex:2], kImageTypePNG);
    }else if (volume >=11 && volume <=15){
        self.voiceImage.image = NULL;
        self.voiceImage.image = LOADIMAGE([self.onVoiceImgArr objectAtIndex:1], kImageTypePNG);
    }else if (volume >= 16 && volume <=100){
        self.voiceImage.image = NULL;
        self.voiceImage.image = LOADIMAGE([self.onVoiceImgArr objectAtIndex:0], kImageTypePNG);
    }

    NSString * vol = [NSString stringWithFormat:@"音量：%d",volume];
    NSLog(@"%@",vol);
}

/**
 * @fn      onBeginOfSpeech
 * @brief   开始识别回调
 *
 * @see
 */
- (void)onBeginOfSpeech {
    NSLog(@"正在录音");
    [SVProgressHUD showSuccessWithStatus:@"开始语音搜索" duration:0.44];
}

/**
 * @fn      onEndOfSpeech
 * @brief   停止录音回调
 *
 * @see
 */
- (void)onEndOfSpeech {
    NSLog(@"停止录音");
}

/**
 * @fn      onError
 * @brief   识别结束回调
 *
 * @param   errorCode   -[out] 错误类，具体用法见IFlySpeechError
 */
- (void)onError:(IFlySpeechError *) error {
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
    }
    ((UIButton *)[self.view viewWithTag:voiceBtn_TAG]).enabled = YES;
}

/**
 * @fn      onResults
 * @brief   识别结果回调
 *
 * @param   result      -[out] 识别结果，NSArray的第一个元素为NSDictionary，NSDictionary的key为识别结果，value为置信度
 * @see
 */
- (void)onResults:(NSArray *) results isLast:(BOOL)isLast {
    [SVProgressHUD show];
    NSMutableString *resultString = [[NSMutableString alloc] init];
    
    NSDictionary *dic = results[0];
    
    for (NSString *key in dic) {
        [resultString appendFormat:@"%@",key];
    }
    self.result =[NSString stringWithFormat:@"%@%@", self.onResult,resultString];
    
    NSString * resultFromJson =  [[ISRDataHelper shareInstance] getResultFromJson:resultString];
    
    self.onResult = [NSString stringWithFormat:@"%@%@", self.onResult,resultFromJson];
    
    if (isLast) {
        NSLog(@"听写结果(json)：%@测试",  self.result);
        //TODO:搜索三
        ((RMBaseTextField *)[self.view viewWithTag:searchTextField_TAG]).text = self.result;
        [SVProgressHUD dismiss];
        [self performSelector:@selector(willStartJumpSearchResult) withObject:nil afterDelay:1.0];
    }
}

- (void)willStartJumpSearchResult {
    [self updateUserSearchRecord:self.result];
    [self.searchTableView reloadData];
    [self startSearchRequest:self.result];
    ((RMBaseTextField *)[self.view viewWithTag:searchTextField_TAG]).enabled = YES;
}

/**
 * @fn      onCancel
 * @brief   取消识别回调
 * 当调用了`cancel`函数之后，会回调此函数，在调用了cancel函数和回调onError之前会有一个短暂时间，您可以在此函数中实现对这段时间的界面显示。
 * @param
 * @see
 */
- (void)onCancel {
    NSLog(@"识别取消");
    [SVProgressHUD showSuccessWithStatus:@"取消语音搜索" duration:0.3];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
