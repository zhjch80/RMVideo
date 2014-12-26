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
#import "RMCustomNavViewController.h"
#import "RMCustomPresentNavViewController.h"
#import "RMTagList.h"
#import "RMLastRecordsCell.h"
#import "RefreshControl.h"
#import "CustomRefreshView.h"
#import "RMSearchResultCell.h"
#import "UIButton+EnlargeEdge.h"

//语音
#import "iflyMSC/IFlySpeechRecognizerDelegate.h"
#import "iflyMSC/IFlySpeechUtility.h"
#import "iflyMSC/IFlySpeechRecognizer.h"
#import "iflyMSC/IFlySpeechConstant.h"
#import "iflyMSC/IFlyResourceUtil.h"
#import <QuartzCore/QuartzCore.h>
#import "RecognizerFactory.h"
#import "ISRDataHelper.h"

#import <QuartzCore/QuartzCore.h>

#define kMaxLength 20

typedef enum{
    requestSearchType = 1,                  //搜索
    requestDynamicAssociativeSearchType     //动态联想搜索
}RequestManagerType;

@interface RMSearchViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,IFlySpeechRecognizerDelegate,UIGestureRecognizerDelegate,RMAFNRequestManagerDelegate,UIAlertViewDelegate,SearchRecordsDelegate,LastRecordsDelegate,TagListDelegate,RefreshControlDelegate,SearchResultDelegate>{
    NSMutableArray * recordsDataArr;            //搜索记录的Arr
    NSMutableArray * resultDataArr;             //搜索结果的Arr
    RequestManagerType requestManagerType;      //请求类型
    NSInteger pageCount;                        //分页
    BOOL isRefresh;                             //是否刷新
}
@property (nonatomic, strong) UITableView * searchTableView;                        //默认搜索的tableView
@property (nonatomic, strong) UITableView * displayResultTableView;                 //搜索结果的tableView
@property (nonatomic, strong) RMBaseTextField * searchTextField;

@property (nonatomic, strong) RefreshControl * refreshControl;
@property (nonatomic, strong) RMPublicModel * publicModel;

@property (nonatomic, strong) IFlySpeechRecognizer    * iFlySpeechRecognizer;
@property (nonatomic)         BOOL                      isCanceled;                 //语音搜索是否取消
@property (nonatomic, strong) NSString                * onResult;                   //语音正在搜索的结果
@property (nonatomic, strong) NSString                * result;                     //语音搜索结束的结果
@property (nonatomic, strong) RMAFNRequestManager     * requestManager;
@property (nonatomic)         BOOL                      isDisplayMoreRecords;       //是否显示 展开更多搜索记录

@property (nonatomic, strong) UIView                  * footView;                   //tableView 的 footView
@property (nonatomic, strong) RMTagList               * tagList;                    //全网热榜推荐list

@end

@implementation RMSearchViewController

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:@"UITextFieldTextDidChangeNotification"
                                                 object:self.searchTextField];
}

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
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;

    recordsDataArr = [[NSMutableArray alloc] init];
    resultDataArr = [[NSMutableArray alloc] init];
    self.result = @"";
    self.onResult = @"";
    pageCount = 1;
    isRefresh = YES;
    self.requestManager = [[RMAFNRequestManager alloc] init];

    leftBarButton.hidden = YES;
    rightBarButton.hidden = YES;
    
    _iFlySpeechRecognizer = [RecognizerFactory CreateRecognizer:self Domain:@"iat"];
    [_iFlySpeechRecognizer setParameter:@"0" forKey:@"asr_ptt"];
    
    [self loadCustomNav];
    [self loadDefaultView];
    [self loadResultView];
}

- (void)loadCustomNav {
    UIView * CustomNav = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth, 64)];
    CustomNav.backgroundColor = [UIColor colorWithRed:0.8 green:0.03 blue:0.12 alpha:1];
    [self.view addSubview:CustomNav];
    
    UIView *roundBgView =[[UIView alloc] initWithFrame:CGRectMake(10, 24, [UtilityFunc shareInstance].globleWidth - 20 - 40, 32)];
    [[roundBgView layer] setBorderWidth:2.0];//画线的宽度
    [[roundBgView layer] setBorderColor:[UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1].CGColor];//颜色
    roundBgView.userInteractionEnabled = YES;
    roundBgView.multipleTouchEnabled = YES;
    [[roundBgView layer]setCornerRadius:16.0];//圆角
    roundBgView.backgroundColor = [UIColor clearColor];
    [CustomNav addSubview:roundBgView];
    
    self.searchTextField = [[RMBaseTextField alloc] init];
    self.searchTextField.delegate = self;
    [[RMBaseTextField appearance] setTintColor:[UIColor whiteColor]];
    self.searchTextField.returnKeyType = UIReturnKeySearch;
    self.searchTextField.textColor = [UIColor whiteColor];
    self.searchTextField.frame = CGRectMake(18, 16, [UtilityFunc shareInstance].globleWidth - 40 - 30, 50);
    self.searchTextField.placeholder = @"搜索你喜欢的电影或明星";
    [self.searchTextField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    self.searchTextField.font = [UIFont systemFontOfSize:16.0];
    self.searchTextField.backgroundColor = [UIColor clearColor];
    [CustomNav addSubview:self.searchTextField];
    
    RMImageView * searchImg = [[RMImageView alloc] init];
    searchImg.frame = CGRectMake([UtilityFunc shareInstance].globleWidth - 50 - 30, 30, 19, 19);
    searchImg.backgroundColor = [UIColor clearColor];
    searchImg.userInteractionEnabled = YES;
    [searchImg addTarget:self WithSelector:@selector(searchMethod)];
    searchImg.image = LOADIMAGE(@"ic_search", kImageTypePNG);
    [CustomNav addSubview:searchImg];
    
    UIButton * backupBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backupBtn.frame = CGRectMake([UtilityFunc shareInstance].globleWidth - 45, 32, 34, 20);
    [backupBtn setEnlargeEdgeWithTop:10 right:10 bottom:10 left:10];
    [backupBtn addTarget:self action:@selector(backupMethod) forControlEvents:UIControlEventTouchUpInside];
    [backupBtn setBackgroundImage:LOADIMAGE(@"cancle_btn_image", kImageTypePNG) forState:UIControlStateNormal];
    [CustomNav addSubview:backupBtn];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFiledEditChanged:)
                                                name:@"UITextFieldTextDidChangeNotification"
                                              object:self.searchTextField];
}

/**
 *  限制输入长度 kMaxLength ＝ 20
 */
- (void)textFiledEditChanged:(NSNotification *)obj {
    UITextField *textField = (UITextField *)obj.object;
    NSString *toBeString = textField.text;
    NSString *lang = [[UITextInputMode currentInputMode] primaryLanguage]; // 键盘输入模式
    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [textField markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            if (toBeString.length > kMaxLength) {
                textField.text = [toBeString substringToIndex:kMaxLength];
            }
        }
        // 有高亮选择的字符串，则暂不对文字进行统计和限制
        else{
            
        }
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
        if (toBeString.length > kMaxLength) {
            textField.text = [toBeString substringToIndex:kMaxLength];
        }
    }
    
    NSLog(@"toBeString:%d   toBeString:%@",toBeString.length,toBeString);
    if (toBeString.length == 0){ //显示默认搜索界面
        self.searchTableView.hidden = NO;
        self.displayResultTableView.hidden = YES;
    }else{ //显示搜索结果界面 启动联想搜索接口
        [self startDynamicAssociativeSearchRequest:textField.text];
    }
}

/**
 *  返回上一级
 */
- (void)backupMethod {
    [self.searchTextField resignFirstResponder];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];
    }
    [self dismissViewControllerAnimated:YES completion:^{
    }];
    [[NSNotificationCenter defaultCenter] postNotificationName:kAppearTabbar object:nil];
}

- (void)loadResultView {
    self.displayResultTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, [UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleAllHeight - 64) style:UITableViewStylePlain];
    self.displayResultTableView.hidden = YES;
    self.displayResultTableView.delegate = self;
    self.displayResultTableView.dataSource = self;
    self.displayResultTableView.backgroundColor = [UIColor clearColor];
    self.displayResultTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.displayResultTableView];
    
    self.refreshControl=[[RefreshControl alloc] initWithScrollView:self.displayResultTableView delegate:self];
    self.refreshControl.topEnabled=YES;
    self.refreshControl.bottomEnabled=YES;
    [self.refreshControl registerClassForTopView:[CustomRefreshView class]];
}

#pragma mark 刷新代理

- (void)refreshControl:(RefreshControl *)refreshControl didEngageRefreshDirection:(RefreshDirection)direction {
    if (direction == RefreshDirectionTop) { //下拉刷新
        isRefresh = YES;
        pageCount = 1;
        [self startSearchRequest:self.searchTextField.text];
    }else if(direction == RefreshDirectionBottom) { //上拉加载
        isRefresh = NO;
        pageCount ++;
        [self startSearchRequest:self.searchTextField.text];
    }
}

- (void)loadDefaultView {
    self.searchTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, [UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleAllHeight - 64) style:UITableViewStylePlain];
    self.searchTableView.delegate = self;
    self.searchTableView.dataSource = self;
    self.searchTableView.backgroundColor = [UIColor clearColor];
    self.searchTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.searchTableView];
    
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

/**
 *  点击输入框右边的搜索按钮进行搜索
 */
- (void)searchMethod{
    [self.searchTextField resignFirstResponder];
    if ([UtilityFunc isConnectionAvailable] == 0) {
        [SVProgressHUD showErrorWithStatus:kShowConnectionAvailableError duration:1.0];
        return ;
    }else {
        [SVProgressHUD dismiss];
        if (self.searchTextField.text.length == 0){
            [SVProgressHUD showErrorWithStatus:@"输入内容为空" duration:1.0];
            return ;
        }
        [SVProgressHUD showWithStatus:@"搜索中..." maskType:SVProgressHUDMaskTypeBlack];
        [self updateUserSearchRecord:self.searchTextField.text];
        [self.searchTableView reloadData];
        [self startSearchRequest:self.searchTextField.text];
    }
}

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
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.searchTextField resignFirstResponder];
}

/**
 *  点击键盘上的搜索按钮开始搜索
 */
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([UtilityFunc isConnectionAvailable] == 0){
        [SVProgressHUD showErrorWithStatus:kShowConnectionAvailableError duration:1.0];
        return NO;
    }else{
        [SVProgressHUD dismiss];
        if (self.searchTextField.text.length == 0){
            [SVProgressHUD showErrorWithStatus:@"输入内容为空" duration:1.0];
            return NO;
        }
        [SVProgressHUD showWithStatus:@"搜索中..." maskType:SVProgressHUDMaskTypeBlack];
        [self updateUserSearchRecord:textField.text];
        [self.searchTableView reloadData];
        [self startSearchRequest:textField.text];
    }
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.searchTextField resignFirstResponder];
}

/**
 *  点击全网热榜推荐标签的事件
 */
- (void)clickTagWithValue:(int)value {
    NSLog(@"value:%d",value);
}

/**
 *  根据标签刷新全网热榜界面的高度
 */
- (void)refreshTagListViewHeight:(float)height {
    [UIView animateWithDuration:0.2 animations:^{
        self.footView.frame = CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth, height + 85);
        self.searchTableView.tableFooterView = self.footView;
        self.tagList.frame = CGRectMake(10, 50.0f, [UtilityFunc shareInstance].globleWidth - 20, height + 20);
    }];
}

#pragma mark - UITableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.searchTableView){
        if (recordsDataArr.count > 2){
            if (self.isDisplayMoreRecords){
                return 3;
            }else{
                return [recordsDataArr count];
            }
        }else{
            return [recordsDataArr count];
        }
    }else{
        return [resultDataArr count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.searchTableView){//默认搜索界面
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

    }else{//显示搜索结果   或者  显示动态搜索结果
        if (requestManagerType == requestSearchType){
            static NSString * CellIdentifier = @"RMSearchResultCellIdentifier";
            RMSearchResultCell * cell = (RMSearchResultCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (! cell) {
                NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"RMSearchResultCell" owner:self options:nil];
                cell = [array objectAtIndex:0];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                cell.backgroundColor = [UIColor clearColor];
                cell.delegate = self;
            }
            cell.DirectBroadcastBtn.tag = indexPath.row;
            [cell.headImg sd_setImageWithURL:[NSURL URLWithString:[[resultDataArr objectAtIndex:indexPath.row] objectForKey:@"pic"]] placeholderImage:LOADIMAGE(@"Default85_135", kImageTypePNG)];
            cell.name.text = [[resultDataArr objectAtIndex:indexPath.row] objectForKey:@"name"];
            [cell.searchFirstRateView setImagesDeselected:@"mx_rateEmpty_img" partlySelected:@"mx_rateEmpty_img" fullSelected:@"mx_rateFull_img" andDelegate:nil];
            [cell.searchFirstRateView displayRating:[[[resultDataArr objectAtIndex:indexPath.row] objectForKey:@"gold"] integerValue]];
            cell.hits.text = [NSString stringWithFormat:@"播放:%@次",[[resultDataArr objectAtIndex:indexPath.row] objectForKey:@"hits"]];
            return cell;
        }else{
            static NSString * CellIdentifier = @"RMDynamicAssociativeCellIdentifier";
            UITableViewCell * cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (! cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                cell.backgroundColor = [UIColor clearColor];
            }
            cell.textLabel.text = [[resultDataArr objectAtIndex:indexPath.row] objectForKey:@"name"];
            return cell;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.searchTableView){
        return 44;
    }else{
        if (requestManagerType == requestSearchType){
            return 155;
        }else{
            return 30;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.searchTableView){
        if ([UtilityFunc isConnectionAvailable] == 0){
            [SVProgressHUD showErrorWithStatus:kShowConnectionAvailableError duration:1.0];
            return ;
        }
        NSString * str = [NSString stringWithFormat:@"%@",[AESCrypt decrypt:[recordsDataArr objectAtIndex:indexPath.row] password:PASSWORD]];
        [SVProgressHUD dismiss];
        [SVProgressHUD showWithStatus:@"搜索中..." maskType:SVProgressHUDMaskTypeBlack];
        self.searchTextField.text = str;
        [self startSearchRequest:str];
    }else{
        if (requestManagerType == requestSearchType){ //目标搜索
            NSLog(@"SearchResult:%d",indexPath.row);
        }else{ //联想搜索
            NSLog(@"DynamicAssociative:%@",[[resultDataArr objectAtIndex:indexPath.row] objectForKey:@"name"]);
        }
    }
}

/**
 *  直接播放 事件
 */
- (void)DirectBroadcastMethodWithValue:(NSInteger)value {
    NSLog(@"value:%d",value);
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

/**
 *  动态联想搜索
 */
- (void)startDynamicAssociativeSearchRequest:(NSString *)key {
    requestManagerType = requestDynamicAssociativeSearchType;
    [self.requestManager getDynamicAssociativeSearchWithKeyWord:[key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    self.requestManager.delegate = self;
}

/**
 *  目标搜索
 */
- (void)startSearchRequest:(NSString *)key {
    [self.searchTextField resignFirstResponder];
    [SVProgressHUD showWithStatus:@"正在搜索" maskType:SVProgressHUDMaskTypeBlack];
    requestManagerType = requestSearchType;
    [self.requestManager getSearchVideoWithKeyword:[key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] Page:[NSString stringWithFormat:@"%d",pageCount] count:@"20"];
    self.requestManager.delegate = self;
}

- (void)requestFinishiDownLoadWith:(NSMutableArray *)data {
    if (requestManagerType == requestSearchType){ //目标搜索
        [SVProgressHUD dismiss];
        self.refreshControl.topEnabled = YES;
        self.refreshControl.bottomEnabled = YES;
        self.searchTableView.hidden = YES;
        self.displayResultTableView.hidden = NO;
        self.publicModel = [data objectAtIndex:0];

        if (self.publicModel.video_list.count == 0){
            [SVProgressHUD showErrorWithStatus:@"没有获取到你想要的内容" duration:1.0];
        }
            
        if (isRefresh){
            [resultDataArr removeAllObjects];
            resultDataArr = [NSMutableArray arrayWithArray:self.publicModel.video_list];
            [self.displayResultTableView reloadData];
            [self.refreshControl finishRefreshingDirection:RefreshDirectionTop];
        }else{
            for (int i=0; i<self.publicModel.video_list.count; i++) {
                [resultDataArr addObject:[self.publicModel.video_list objectAtIndex:i]];
            }
            [self.displayResultTableView reloadData];
            [self.refreshControl finishRefreshingDirection:RefreshDirectionBottom];
        }
    }else{ //联想搜索
        self.refreshControl.topEnabled = NO;
        self.refreshControl.bottomEnabled = NO;
        self.searchTableView.hidden = YES;
        self.displayResultTableView.hidden = NO;
        self.publicModel = [data objectAtIndex:0];
        NSLog(@"self.publicModel.DynamicAssociativeArr:%@",self.publicModel.DynamicAssociativeArr);
        resultDataArr = [NSMutableArray arrayWithArray:self.publicModel.DynamicAssociativeArr];
        [self.displayResultTableView reloadData];
    }
}

- (void)requestError:(NSError *)error {
    NSLog(@"error:%@",error);
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
        ((RMBaseTextField *)[self.view viewWithTag:101]).text = self.result;
        [SVProgressHUD dismiss];
        [self performSelector:@selector(willStartJumpSearchResult) withObject:nil afterDelay:1.0];
    }
}

- (void)willStartJumpSearchResult {
    [self updateUserSearchRecord:self.result];
    [self.searchTableView reloadData];
    [self startSearchRequest:self.result];
    ((RMBaseTextField *)[self.view viewWithTag:101]).enabled = YES;
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

@end
