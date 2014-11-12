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

#define searchTextField_TAG             101
#define cancelBtn_TAG                   102
#define voiceBtn_TAG                    103

@interface RMSearchViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,IFlySpeechRecognizerDelegate,UIGestureRecognizerDelegate,RMAFNRequestManagerDelegate,UIAlertViewDelegate>{
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
    //默认隐藏 调用语音时显示
    [self loadDefaultVoiceSearchView];
}

- (void)loadCustom {
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
    searchTextField.frame = CGRectMake(18, 72 - 64, 180, 30);
    searchTextField.placeholder = @"搜索你感兴趣的影片";
    searchTextField.font = [UIFont systemFontOfSize:14.0];
    searchTextField.backgroundColor = [UIColor clearColor];
    [self.view addSubview:searchTextField];
    
    UIButton * cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    if (IS_IPHONE_4_SCREEN | IS_IPHONE_5_SCREEN) {
        cancelBtn.frame = CGRectMake(210, 72-64, 70, 30);
    }else if (IS_IPHONE_6_SCREEN){
        cancelBtn.frame = CGRectMake(255, 72-64, 70, 30);
    }
    cancelBtn.hidden = YES;
    [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(mbuttonClick:) forControlEvents:UIControlEventTouchUpInside];
    cancelBtn.tag = cancelBtn_TAG;
    [self.view addSubview:cancelBtn];
    
    UIButton * voiceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    voiceBtn.tag = voiceBtn_TAG;
    voiceBtn.backgroundColor = [UIColor clearColor];
    if (IS_IPHONE_4_SCREEN | IS_IPHONE_5_SCREEN){
        voiceBtn.frame = CGRectMake(280, 72-64, 30, 30);
    }else if (IS_IPHONE_6_SCREEN){
        voiceBtn.frame = CGRectMake(330, 72-64, 30, 30);
    }
    [voiceBtn setBackgroundImage:LOADIMAGE(@"mx_voiceBtn_img", kImageTypePNG) forState:UIControlStateNormal];
    [voiceBtn addTarget:self action:@selector(mbuttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:voiceBtn];
    
    [self loadDefaultSearchView];
}

#pragma mark - 默认搜索界面

- (void)loadDefaultSearchView {
    self.searchTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, [UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleAllHeight - 44 - 64) style:UITableViewStylePlain];
    self.searchTableView.tag = 201;
    self.searchTableView.delegate = self;
    self.searchTableView.dataSource = self;
    self.searchTableView.backgroundColor = [UIColor clearColor];
    self.searchTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.searchTableView];
    
    //初始化 清空历史记录View
    self.historicalRecordsView = [[RMHistoricalRecordsView alloc] init];
    self.historicalRecordsView.frame = CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth, 40);
    self.historicalRecordsView.userInteractionEnabled = YES;
    self.historicalRecordsView.backgroundColor = [UIColor clearColor];
    self.searchTableView.tableHeaderView = self.historicalRecordsView;
    
    UITapGestureRecognizer *historicalRecordsViewRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clearHistoryRecords:)];
    historicalRecordsViewRecognizer.numberOfTouchesRequired = 1; //手指数
    historicalRecordsViewRecognizer.numberOfTapsRequired = 1; //tap次数
    historicalRecordsViewRecognizer.delegate = self;
    [self.historicalRecordsView addGestureRecognizer:historicalRecordsViewRecognizer];
}

- (void)refreshRecodsView {
    if ([recordsDataArr count] == 0) {
        [self.historicalRecordsView updateDisplayTitle:@"没有历史记录"];
    }else{
        [self.historicalRecordsView updateDisplayTitle:@"清空历史记录"];
    }
}

#pragma mark - 默认语音搜索界面

- (void)loadDefaultVoiceSearchView {
    self.blurView = [[AMBlurView alloc] initWithFrame:CGRectMake(0, 44, [UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleHeight - 44)];
    [self.view addSubview:self.blurView];
    
    self.voiceImage = [[RMImageView alloc] initWithFrame:CGRectMake([UtilityFunc shareInstance].globleWidth/2 - 45, [UtilityFunc shareInstance].globleHeight/2 - 45 - 44, 90, 90)];
    self.voiceImage.backgroundColor = [UIColor clearColor];
    self.voiceImage.userInteractionEnabled = YES;
    self.voiceImage.image = LOADIMAGE([self.onVoiceImgArr objectAtIndex:3], kImageTypePNG);
    [self.voiceImage addTarget:self WithSelector:@selector(clickVoiceImageMethod)];
    [self.blurView addSubview:self.voiceImage];
    [self showVoiceView:NO];
}

- (void)showVoiceView:(BOOL)hidden {
    self.blurView.hidden = !hidden;
    self.voiceImage.hidden = !hidden;
}

- (void)clickVoiceImageMethod {
    [_iFlySpeechRecognizer cancel];
    [self showVoiceView:NO];
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

#pragma mark - UIGestureRecognizerDelegate-清空历史记录 UITextField Delegate

/**
 * 清空历史记录 并刷新界面
 */
- (void)judgeUserClearRecord {
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确定要清空搜索记录么？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:{
            
            break;
        }
        case 1:{
            CUSFileStorage *storage = [CUSFileStorageManager getFileStorage:CURRENTENCRYPTFILE];
            NSMutableArray * arr = [[NSMutableArray alloc] initWithArray:[storage objectForKey:UserSearchRecordData_KEY]];
            [arr removeAllObjects];
            [recordsDataArr removeAllObjects];
            [storage beginUpdates];
            [storage setObject:arr forKey:UserSearchRecordData_KEY];
            [storage endUpdates];
            [self refreshRecodsView];
            [self.searchTableView reloadData];
            break;
        }
            
        default:
            break;
    }
}

- (void)clearHistoryRecords:(id)sender {
    if ([recordsDataArr count] == 0){
        return;
    }
    [self judgeUserClearRecord];
}

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

- (void)textFieldDidBeginEditing:(UITextField *)textField {
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    //TODO: 开始搜索一
    if ([UtilityFunc isConnectionAvailable] == 0) {
        [SVProgressHUD showWithStatus:kShowConnectionAvailableError maskType:SVProgressHUDMaskTypeBlack];
    }else {
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

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [self cancelSearch];
    return YES;
}

#pragma mark - UITableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [recordsDataArr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * CellIdentifier = @"RMSearchCellIdentifier";
    RMSearchRecordsCell * cell = (RMSearchRecordsCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (! cell) {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"RMSearchRecordsCell" owner:self options:nil];
        cell = [array objectAtIndex:0];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.backgroundColor = [UIColor clearColor];
    }
    cell.recordsName.text = [NSString stringWithFormat:@"%@",[AESCrypt decrypt:[recordsDataArr objectAtIndex:indexPath.row] password:PASSWORD]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == [recordsDataArr count] - 1){
        return 44;
    }else {
        return 50;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //TODO:开始搜索二
    if ([UtilityFunc isConnectionAvailable] == 0){
        [SVProgressHUD showWithStatus:kShowConnectionAvailableError maskType:SVProgressHUDMaskTypeBlack];
        return;
    }
    [self startSearchRequest:[NSString stringWithFormat:@"%@",[AESCrypt decrypt:[recordsDataArr objectAtIndex:indexPath.row] password:PASSWORD]]];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self cancelSearch];
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
        [self showVoiceView:NO];
    }];
}

- (void)requestError:(NSError *)error {
    [SVProgressHUD showErrorWithStatus:@"搜索失败,请重新尝试"];
}

#pragma mark - Base Method

- (void)navgationBarButtonClick:(UIBarButtonItem *)sender {
    switch (sender.tag) {
        case 1:{
            break;
        }
        case 2:{
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

#pragma mark - 

- (void)mbuttonClick:(UIButton *)sender {
    switch (sender.tag) {
        case cancelBtn_TAG:{
            [self cancelSearch];
            break;
        }
        case voiceBtn_TAG:{
            if ([UtilityFunc isConnectionAvailable] == 0){
                [SVProgressHUD showWithStatus:kShowConnectionAvailableError maskType:SVProgressHUDMaskTypeBlack];
                return;
            }
            self.isCanceled = NO;
            ((RMBaseTextField *)[self.view viewWithTag:searchTextField_TAG]).text = @"";
            [(RMBaseTextField *)[self.view viewWithTag:searchTextField_TAG] resignFirstResponder];
            
            //设置为录音模式
            [_iFlySpeechRecognizer setParameter:IFLY_AUDIO_SOURCE_MIC forKey:@"audio_source"];
            bool ret = [_iFlySpeechRecognizer startListening];
            if (ret) {
                ((UIButton *)[self.view viewWithTag:voiceBtn_TAG]).enabled = NO;
            }else{
                NSLog(@"启动识别服务失败，请稍后重试");//可能是上次请求未结束，暂不支持多路并发
                [SVProgressHUD showErrorWithStatus:@"启动语音搜索服务失败" duration:0.44];
            }
            [self showVoiceView:YES];

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
- (void) onBeginOfSpeech {
    NSLog(@"正在录音");
    [SVProgressHUD showSuccessWithStatus:@"开始语音搜索" duration:0.44];
}

/**
 * @fn      onEndOfSpeech
 * @brief   停止录音回调
 *
 * @see
 */
- (void) onEndOfSpeech {
    NSLog(@"停止录音");
    [self showVoiceView:NO];
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
    }
    ((UIButton *)[self.view viewWithTag:voiceBtn_TAG]).enabled = YES;
    [self showVoiceView:NO];
}

/**
 * @fn      onResults
 * @brief   识别结果回调
 *
 * @param   result      -[out] 识别结果，NSArray的第一个元素为NSDictionary，NSDictionary的key为识别结果，value为置信度
 * @see
 */
- (void) onResults:(NSArray *) results isLast:(BOOL)isLast {
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
        [self updateUserSearchRecord:self.result];
        [self.searchTableView reloadData];
        [self startSearchRequest:self.result];
        ((RMBaseTextField *)[self.view viewWithTag:searchTextField_TAG]).enabled = YES;
    }
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
    [SVProgressHUD showSuccessWithStatus:@"取消语音搜索" duration:0.3];
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
