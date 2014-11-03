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
#import "RMSearchCell.h"
#import "RMSearchRecordsCell.h"

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

#define searchTextField_TAG             101
#define cancelBtn_TAG                   102
#define voiceBtn_TAG                    103

@interface RMSearchViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,SearchCellDelegate,IFlySpeechRecognizerDelegate,UIGestureRecognizerDelegate,RMAFNRequestManagerDelegate>{
    NSMutableArray * recordsDataArr;
}
@property (nonatomic, strong) AMBlurView * blurView;
@property (nonatomic, strong) UITableView * searchTableView;

@property (nonatomic, strong) IFlySpeechRecognizer * iFlySpeechRecognizer;
@property (nonatomic)         BOOL                 isCanceled;          //语音搜索是否取消
@property (nonatomic, strong) NSString             * onResult;          //语音正在搜索的结果
@property (nonatomic, strong) NSString             * result;            //语音搜索结束的结果
@property (nonatomic, strong) RMAFNRequestManager * request;

@end

@implementation RMSearchViewController
static id _instance;
/*
 永远只分配一块内存来创建对象
 提供一个类方法，返回内部唯一的一个变量
 最好保证init方法也只初创化一次
 */

//构造方法
- (id)init {
    static id obj=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ((obj=[super init]) != nil) {
            self.result = @"";
            self.onResult = @"";
        
            _iFlySpeechRecognizer = [RecognizerFactory CreateRecognizer:self Domain:@"iat"];
            [_iFlySpeechRecognizer setParameter:@"0" forKey:@"asr_ptt"];
            
            [self loadCustom];
        }
    });
    self=obj;
    
    return self;
}

+ (id)alloc {
    return [super alloc];
}

//重写该方法，控制内存的分配，永远只分配一次存储空间
+ (id)allocWithZone:(struct _NSZone *)zone {
    //里面的代码只会执行一次
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance=[super allocWithZone:zone];
    });
    return _instance;
}

//类方法 里面的代码永远都只执行一次
+ (instancetype)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance=[[self alloc]init];
    });
    return _instance;
}

+ (id)copyWithZone:(struct _NSZone *)zone {
    return _instance;
}

- (void)viewWillDisappear:(BOOL)animated {
    //取消识别
    [_iFlySpeechRecognizer cancel];
    [_iFlySpeechRecognizer setDelegate: nil];
    
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    recordsDataArr = [[NSMutableArray alloc] init];
    CUSFileStorage *storage = [CUSFileStorageManager getFileStorage:CURRENTENCRYPTFILE];
    recordsDataArr = [storage objectForKey:@"userSearchRecordData_KEY"];
    NSLog(@"记录条数count:%d",[recordsDataArr count]);
    [self.searchTableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    [self setTitle:@"搜索"];
    leftBarButton.hidden = YES;
    rightBarButton.frame = CGRectMake(0, 0, 35, 20);
    [rightBarButton setBackgroundImage:LOADIMAGE(@"cancle_btn_image", kImageTypePNG) forState:UIControlStateNormal];
}

- (void)loadCustom {
    RMImageView * searchImg = [[RMImageView alloc] init];
    searchImg.frame = CGRectMake(0, 64, [UtilityFunc shareInstance].globleWidth, 45);
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
    searchTextField.frame = CGRectMake(18, 72, 180, 30);
    searchTextField.placeholder = @"搜索你感兴趣的影片";
    searchTextField.font = [UIFont systemFontOfSize:14.0];
    searchTextField.backgroundColor = [UIColor clearColor];
    [self.view addSubview:searchTextField];
    
    UIButton * cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    if (IS_IPHONE_4_SCREEN | IS_IPHONE_5_SCREEN) {
        cancelBtn.frame = CGRectMake(210, 72, 70, 30);
    }else if (IS_IPHONE_6_SCREEN){
        cancelBtn.frame = CGRectMake(255, 72, 70, 30);
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
        voiceBtn.frame = CGRectMake(280, 72, 30, 30);
    }else if (IS_IPHONE_6_SCREEN){
        voiceBtn.frame = CGRectMake(330, 72, 30, 30);
    }
    [voiceBtn setBackgroundImage:LOADIMAGE(@"mx_voiceBtn_img", kImageTypePNG) forState:UIControlStateNormal];
    [voiceBtn addTarget:self action:@selector(mbuttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:voiceBtn];
    
    [self loadDefaultSearchView];
}

#pragma mark - 默认搜索界面

- (void)loadDefaultSearchView {
    self.searchTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64 + 45, [UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleAllHeight - 45 - 64) style:UITableViewStylePlain];
    self.searchTableView.tag = 201;
    self.searchTableView.delegate = self;
    self.searchTableView.dataSource = self;
    self.searchTableView.backgroundColor = [UIColor clearColor];
    self.searchTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.searchTableView];
    
    //初始化 清空历史记录View
    RMHistoricalRecordsView * historicalRecordsView = [[RMHistoricalRecordsView alloc] init];
    historicalRecordsView.frame = CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth, 40);
    historicalRecordsView.userInteractionEnabled = YES;
    historicalRecordsView.backgroundColor = [UIColor clearColor];
    self.searchTableView.tableHeaderView = historicalRecordsView;
    
    UITapGestureRecognizer *historicalRecordsViewRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clearHistoryRecords:)];
    historicalRecordsViewRecognizer.numberOfTouchesRequired = 1; //手指数
    historicalRecordsViewRecognizer.numberOfTapsRequired = 1; //tap次数
    historicalRecordsViewRecognizer.delegate = self;
    [historicalRecordsView addGestureRecognizer:historicalRecordsViewRecognizer];
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


#pragma mark - UIGestureRecognizerDelegate-清空历史记录 UITextField Delegate

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
}

- (void)cancelSearch {
    [(RMBaseTextField *)[self.view viewWithTag:searchTextField_TAG] resignFirstResponder];
    ((UIButton *)[self.view viewWithTag:cancelBtn_TAG]).hidden = YES;
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
    NSLog(@"开始搜索");
    
    NSLog(@"obj:%@",textField.text);
    
    CUSFileStorage *storage = [CUSFileStorageManager getFileStorage:CURRENTENCRYPTFILE];
    [storage beginUpdates];
    NSString * userSearchRecord = [AESCrypt encrypt:textField.text password:PASSWORD];
    
    NSLog(@"userSearchRecord:%@",userSearchRecord);
    
    [recordsDataArr addObject:userSearchRecord];
    [storage setObject:recordsDataArr forKey:@"userSearchRecordData_KEY"];
    [storage endUpdates];
    
    NSLog(@"保存后count:%d",recordsDataArr.count);
    
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
   
    cell.recordsName.text = [AESCrypt decrypt:[recordsDataArr objectAtIndex:indexPath.row] password:PASSWORD];
    
    
//    [cell.searchFirstRateView setImagesDeselected:@"mx_rateEmpty_img" partlySelected:@"mx_rateEmpty_img" fullSelected:@"mx_rateFull_img" andDelegate:nil];
//    [cell.searchFirstRateView displayRating:3];
//    
//    [cell.searchSecondRateView setImagesDeselected:@"mx_rateEmpty_img" partlySelected:@"mx_rateEmpty_img" fullSelected:@"mx_rateFull_img" andDelegate:nil];
//    [cell.searchSecondRateView displayRating:4];
//    
//    [cell.searchThirdRateView setImagesDeselected:@"mx_rateEmpty_img" partlySelected:@"mx_rateEmpty_img" fullSelected:@"mx_rateFull_img" andDelegate:nil];
//    [cell.searchThirdRateView displayRating:3];
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
    NSLog(@"搜索");
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self cancelSearch];
}

- (void)startCellDidSelectWithIndex:(NSInteger)index {
    NSLog(@"搜索 click");
}

#pragma mark - Base Method

- (void)navgationBarButtonClick:(UIBarButtonItem *)sender {
    switch (sender.tag) {
        case 1:{
            break;
        }
        case 2:{
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
            NSLog(@"语音搜索");
            [(RMBaseTextField *)[self.view viewWithTag:searchTextField_TAG] resignFirstResponder];
            
            //设置为录音模式
            [_iFlySpeechRecognizer setParameter:IFLY_AUDIO_SOURCE_MIC forKey:@"audio_source"];
            bool ret = [_iFlySpeechRecognizer startListening];
            if (ret) {
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
    }
}

/**
 * @fn      onResults
 * @brief   识别结果回调
 *
 * @param   result      -[out] 识别结果，NSArray的第一个元素为NSDictionary，NSDictionary的key为识别结果，value为置信度
 * @see
 */
- (void) onResults:(NSArray *) results isLast:(BOOL)isLast
{
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
        //TODO:给textField.text 赋值，并开始搜索

    }
}

/**
 * @fn      onCancel
 * @brief   取消识别回调
 * 当调用了`cancel`函数之后，会回调此函数，在调用了cancel函数和回调onError之前会有一个短暂时间，您可以在此函数中实现对这段时间的界面显示。
 * @param
 * @see
 */
- (void) onCancel
{
    NSLog(@"识别取消");
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
