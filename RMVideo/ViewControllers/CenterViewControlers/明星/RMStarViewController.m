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
#import "PullToRefreshTableView.h"
#import "RMSetupViewController.h"
#import "RMStarDetailsViewController.h"
#import "RMVideoPlaybackDetailsViewController.h"
#import "RMSearchRecordsCell.h"
#import "RMStarSearchResultViewController.h"
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
#import "RMLoginViewController.h"

typedef enum{
    requestStarListType = 1,
    requestAddStarMyChannelType,
    requestDeleteStarMyChannelType,
    requestSearchStarType
}LoadType;

#define searchTextField_TAG         101
#define cancelBtn_TAG               102
#define voiceBtn_TAG                103

@interface RMStarViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,StarCellDelegate,UIGestureRecognizerDelegate,IFlySpeechRecognizerDelegate,RMAFNRequestManagerDelegate> {
    NSMutableArray * dataArr;
    LoadType loadType;
    NSMutableArray * recordsDataArr;        //保存搜索记录的数组
    NSInteger pageCount;
    BOOL isRefresh;
    RMImageView * rmImage;                  //获取点击cell的图片

}

@property (nonatomic, strong) AMBlurView * blurView;
@property (nonatomic, strong) UITableView * recordsTableView;

@property (nonatomic, strong) UIImageView * voiceImg;
@property (nonatomic, strong) RMImageView * onVoiceImg;

@property (nonatomic, strong) NSArray * onVoiceImgArr;

//识别对象
@property (nonatomic, strong) IFlySpeechRecognizer * iFlySpeechRecognizer;
@property (nonatomic)         BOOL                 isCanceled;          //语音搜索是否取消
@property (nonatomic, strong) NSString             * onResult;          //语音正在搜索的结果
@property (nonatomic, strong) NSString             * result;            //语音搜索结束的结果
@property (nonatomic, strong) UIView               * coverView;         //遮挡textField 层
@property (nonatomic, strong) RMHistoricalRecordsView * historicalRecordsView;
@property (nonatomic, strong) UITapGestureRecognizer *historicalRecordsViewRecognizer;

@end

@implementation RMStarViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self loadDefaultHandInputSearchView];

    [_iFlySpeechRecognizer setDelegate: self];
    
    self.onResult = @"";
    self.result = @"";
    
    CUSFileStorage *storage = [CUSFileStorageManager getFileStorage:CURRENTENCRYPTFILE];
    NSMutableArray * arr = [[NSMutableArray alloc] initWithArray:[storage objectForKey:UserSearchStarRecordData_KEY]];
    recordsDataArr = arr;
    [self refreshStarRecodsView];
    [self.recordsTableView reloadData];
    
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
    recordsDataArr = [[NSMutableArray alloc] init];
    
    self.onResult = @"";
    self.result = @"";
    self.onVoiceImgArr = [NSArray arrayWithObjects:@"onVoice_1", @"onVoice_2", @"onVoice_3", @"onVoice_4", nil];
    _iFlySpeechRecognizer = [RecognizerFactory CreateRecognizer:self Domain:@"iat"];
    [_iFlySpeechRecognizer setParameter:@"0" forKey:@"asr_ptt"];

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
    
    PullToRefreshTableView * tableView = [[PullToRefreshTableView alloc] initWithFrame:CGRectMake(0, 45, [UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleHeight - 45 - 44 - 49)];
    tableView.tag = 201;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor = [UIColor clearColor];
    [tableView setIsCloseHeader:NO];
    [tableView setIsCloseFooter:NO];
    [self.view addSubview:tableView];
    
    pageCount = 1;
    isRefresh = YES;
    [self startRequest];
}

#pragma mark - 默认输入搜索界面

- (void)loadDefaultHandInputSearchView {
    //初始化View
    if (!self.blurView) {
        self.blurView = [[AMBlurView alloc] init];
    }
    self.blurView.frame = CGRectMake(0, 45, [UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleAllHeight - 64 - 45 - 49);
    [self.blurView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    self.blurView.userInteractionEnabled = YES;
    [self.view addSubview:self.blurView];
    
    if (!self.recordsTableView) {
        self.recordsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleAllHeight - 64 - 45 - 49) style:UITableViewStylePlain];
    }
    self.recordsTableView.tag = 202;
    self.recordsTableView.delegate = self;
    self.recordsTableView.dataSource = self;
    self.recordsTableView.backgroundColor = [UIColor clearColor];
    self.recordsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.blurView addSubview:self.recordsTableView];
    
    //初始化 清空历史记录View
    if (!self.historicalRecordsView) {
        self.historicalRecordsView = [[RMHistoricalRecordsView alloc] init];
    }
    self.historicalRecordsView .frame = CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth, 40);
    self.historicalRecordsView .userInteractionEnabled = YES;
    self.historicalRecordsView .backgroundColor = [UIColor clearColor];
    self.recordsTableView.tableHeaderView = self.historicalRecordsView ;
    
    if (!self.historicalRecordsViewRecognizer){
        self.historicalRecordsViewRecognizer = [[UITapGestureRecognizer alloc] init];
    }
    [self.historicalRecordsViewRecognizer addTarget:self action:@selector(clearHistoryRecords:)];
    self.historicalRecordsViewRecognizer.numberOfTouchesRequired = 1;
    self.historicalRecordsViewRecognizer.numberOfTapsRequired = 1;
    self.historicalRecordsViewRecognizer.delegate = self;
    [self.historicalRecordsView  addGestureRecognizer:self.historicalRecordsViewRecognizer];
    if (!self.onVoiceImg){
        self.onVoiceImg = [[RMImageView alloc] initWithFrame:CGRectMake([UtilityFunc shareInstance].globleWidth/2 - 45, [UtilityFunc shareInstance].globleAllHeight/2 - 145, 90, 90)];
    }
    self.onVoiceImg.userInteractionEnabled = YES;
    self.onVoiceImg.backgroundColor=  [UIColor clearColor];
    self.onVoiceImg.image = LOADIMAGE([self.onVoiceImgArr objectAtIndex:3], kImageTypePNG);
    [self.onVoiceImg addTarget:self WithSelector:@selector(stopVoiceSearchMethod)];
    [self.blurView addSubview:self.onVoiceImg];
    
    [self showStarVoiceView:NO WithShowVoiceImage:NO WithShowTableView:NO];
    [self cancelSatrSearch];
}

- (void)showStarVoiceView:(BOOL)searchHidden WithShowVoiceImage:(BOOL)voiceHiden WithShowTableView:(BOOL)tableHiden {
    self.blurView.hidden = !searchHidden;
    self.recordsTableView.hidden = !tableHiden;
    self.onVoiceImg.hidden = !voiceHiden;
}

- (void)refreshStarRecodsView {
    if ([recordsDataArr count] == 0) {
        [self.historicalRecordsView updateDisplayTitle:@"没有历史记录"];
    }else{
        [self.historicalRecordsView updateDisplayTitle:@"清空历史记录"];
    }
}

- (void)stopVoiceSearchMethod {
    [_iFlySpeechRecognizer cancel];
    [self showStarVoiceView:NO WithShowVoiceImage:NO WithShowTableView:NO];
    ((UIButton *)[self.view viewWithTag:cancelBtn_TAG]).hidden = YES;
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

#pragma mark - 取消 语音搜索 方法

- (void)mbuttonClick:(UIButton *)sender {
    switch (sender.tag) {
        case cancelBtn_TAG: {
            [self showStarVoiceView:NO WithShowVoiceImage:NO WithShowTableView:NO];
            [_iFlySpeechRecognizer cancel];
            [self cancelSatrSearch];
            break;
        }
        case voiceBtn_TAG: {
            if ([UtilityFunc isConnectionAvailable] == 0){
                [SVProgressHUD showWithStatus:kShowConnectionAvailableError maskType:SVProgressHUDMaskTypeBlack];
                return;
            }
            self.isCanceled = NO;
            [self showStarVoiceView:YES WithShowVoiceImage:YES WithShowTableView:NO];
            [self loadAddCovertextField];
            [(RMBaseTextField *)[self.view viewWithTag:searchTextField_TAG] resignFirstResponder];
            ((UIButton *)[self.view viewWithTag:cancelBtn_TAG]).hidden = NO;

            //设置为录音模式
            [_iFlySpeechRecognizer setParameter:IFLY_AUDIO_SOURCE_MIC forKey:@"audio_source"];
            bool ret = [_iFlySpeechRecognizer startListening];
            if (ret) {
                ((UIButton *)[self.view viewWithTag:voiceBtn_TAG]).enabled = NO;
            }else{
                NSLog(@"启动识别服务失败，请稍后重试");//可能是上次请求未结束，暂不支持多路并发
                [SVProgressHUD showErrorWithStatus:@"启动语音搜索服务失败" duration:0.44];
            }
            break;
        }
            
        default:
            break;
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
    [storage setObject:recordsDataArr forKey:UserSearchStarRecordData_KEY];
    [storage endUpdates];
    [self refreshStarRecodsView];
}

/**
 * 清空历史记录 并刷新界面
 */
- (void)judgeUserStarClearRecord {
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
            NSMutableArray * arr = [[NSMutableArray alloc] initWithArray:[storage objectForKey:UserSearchStarRecordData_KEY]];
            [arr removeAllObjects];
            [recordsDataArr removeAllObjects];
            [storage beginUpdates];
            [storage setObject:arr forKey:UserSearchStarRecordData_KEY];
            [storage endUpdates];
            [self refreshStarRecodsView];
            [self.recordsTableView reloadData];
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
    [self judgeUserStarClearRecord];
}

- (void)startStarSearch {
    ((UIButton *)[self.view viewWithTag:cancelBtn_TAG]).hidden = NO;
    [self showStarVoiceView:YES WithShowVoiceImage:NO WithShowTableView:YES];
}

- (void)cancelSatrSearch {
    ((UIButton *)[self.view viewWithTag:cancelBtn_TAG]).hidden = YES;
    [(RMBaseTextField *)[self.view viewWithTag:searchTextField_TAG] resignFirstResponder];
    ((RMBaseTextField *)[self.view viewWithTag:searchTextField_TAG]).text = @"";
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    //TODO:搜索一
    if ([UtilityFunc isConnectionAvailable] == 0) {
        [SVProgressHUD showWithStatus:kShowConnectionAvailableError maskType:SVProgressHUDMaskTypeBlack];
    }else {
        [self updateUserSearchRecord:textField.text];
        [self.recordsTableView reloadData];
        [self startStarSearchRequest:textField.text];
    }
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self startStarSearch];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [self cancelSatrSearch];
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
            if ([dataArr count]%3 == 0){
                return [dataArr count] / 3;
            }else if ([dataArr count]%3 == 1){
                return ([dataArr count] + 2) / 3;
            }else {
                return ([dataArr count] + 1) / 3;
            }
            break;
        }
        case 202:{
            return [recordsDataArr count];
            break;
        }
            
        default:
            return 0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag == 201){
        NSString * CellIdentifier = [NSString stringWithFormat:@"RMStarCellIdentifier%d",indexPath.row];
        RMStarCell * cell = (RMStarCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (! cell) {
            NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"RMStarCell" owner:self options:nil];
            cell = [array objectAtIndex:0];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            cell.backgroundColor = [UIColor clearColor];
            cell.delegate = self;
        }
        RMPublicModel *model_left;
        RMPublicModel *model_center;
        RMPublicModel *model_right;
        
        model_left = [dataArr objectAtIndex:indexPath.row*3];
        [cell.leftTitle loadTextViewWithString:model_left.name WithTextFont:[UIFont systemFontOfSize:14.0] WithTextColor:[UIColor blackColor] WithTextAlignment:NSTextAlignmentCenter WithSetupLabelCenterPoint:YES WithTextOffset:6];
        [cell.leftTitle startScrolling];
        [cell.starLeftImg sd_setImageWithURL:[NSURL URLWithString:model_left.pic_url] placeholderImage:LOADIMAGE(@"rb_loadingImg", kImageTypePNG)];
        cell.starLeftImg.identifierString = model_left.tag_id;
        cell.starAddLeftImg.identifierString = model_left.tag_id;
        cell.starAddLeftImg.indexPath = indexPath;
        if ([model_left.is_follow integerValue] == 0){
            cell.starAddLeftImg.image = LOADIMAGE(@"mx_add_img", kImageTypePNG);
            cell.starAddLeftImg.isAttentionStarState = 0;
        }else{
            cell.starAddLeftImg.image = LOADIMAGE(@"mx_add_success_img", kImageTypePNG);
            cell.starAddLeftImg.isAttentionStarState = 1;
        }
        
        if (indexPath.row * 3 + 1 >= [dataArr count]){
            cell.starAddCenterImg.hidden = YES;
        }else{
            model_center = [dataArr objectAtIndex:indexPath.row*3 + 1];
            [cell.centerTitle loadTextViewWithString:model_center.name WithTextFont:[UIFont systemFontOfSize:14.0] WithTextColor:[UIColor blackColor] WithTextAlignment:NSTextAlignmentCenter WithSetupLabelCenterPoint:YES WithTextOffset:6];
            [cell.centerTitle startScrolling];            
            [cell.starCenterImg sd_setImageWithURL:[NSURL URLWithString:model_center.pic_url] placeholderImage:LOADIMAGE(@"rb_loadingImg", kImageTypePNG)];
            cell.starCenterImg.identifierString = model_center.tag_id;
            cell.starAddCenterImg.identifierString = model_center.tag_id;
            cell.starAddCenterImg.indexPath = indexPath;
            if ([model_center.is_follow integerValue] == 0){
                cell.starAddCenterImg.image = LOADIMAGE(@"mx_add_img", kImageTypePNG);
                cell.starAddCenterImg.isAttentionStarState = 0;
            }else{
                cell.starAddCenterImg.image = LOADIMAGE(@"mx_add_success_img", kImageTypePNG);
                cell.starAddCenterImg.isAttentionStarState = 1;
            }
        }
        
        if (indexPath.row * 3 + 2 >= [dataArr count]){
            cell.starAddRightImg.hidden = YES;
        }else{
            model_right = [dataArr objectAtIndex:indexPath.row*3 + 2];
            [cell.rightTitle loadTextViewWithString:model_right.name WithTextFont:[UIFont systemFontOfSize:14.0] WithTextColor:[UIColor blackColor] WithTextAlignment:NSTextAlignmentCenter WithSetupLabelCenterPoint:YES WithTextOffset:6];
            [cell.rightTitle startScrolling];
            [cell.starRightImg sd_setImageWithURL:[NSURL URLWithString:model_right.pic_url] placeholderImage:LOADIMAGE(@"rb_loadingImg", kImageTypePNG)];
            cell.starRightImg.identifierString = model_right.tag_id;
            cell.starAddRightImg.identifierString = model_right.tag_id;
            cell.starAddRightImg.indexPath = indexPath;
            if ([model_right.is_follow integerValue] == 0){
                cell.starAddRightImg.image = LOADIMAGE(@"mx_add_img", kImageTypePNG);
                cell.starAddRightImg.isAttentionStarState = 0;
            }else{
                cell.starAddRightImg.image = LOADIMAGE(@"mx_add_success_img", kImageTypePNG);
                cell.starAddRightImg.isAttentionStarState = 1;
            }
        }
        return cell;
    }else {
        static NSString * CellIdentifier = @"RMStarSearchCellIdentifier";
        RMSearchRecordsCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (! cell) {
            NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"RMSearchRecordsCell" owner:self options:nil];
            cell = [array objectAtIndex:0];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            cell.backgroundColor = [UIColor clearColor];
        }
        cell.recordsName.text = [NSString stringWithFormat:@"%@",[AESCrypt decrypt:[recordsDataArr objectAtIndex:indexPath.row] password:PASSWORD]];
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (tableView.tag) {
        case 201:{
            NSInteger value = 0;
            
            if ([dataArr count]%3 == 0){
                value = [dataArr count]/3;
            }else if ([dataArr count]%3 == 1){
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
            if ([UtilityFunc isConnectionAvailable] == 0){
                [SVProgressHUD showWithStatus:kShowConnectionAvailableError maskType:SVProgressHUDMaskTypeBlack];
                return;
            }
            [self startStarSearchRequest:[NSString stringWithFormat:@"%@",[AESCrypt decrypt:[recordsDataArr objectAtIndex:indexPath.row] password:PASSWORD]]];
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

#pragma mark - 添加或者删除 明星 在我的频道里

- (void)clickAddMyChannelMethod:(RMImageView *)imageView {
    CUSFileStorage *storage = [CUSFileStorageManager getFileStorage:CURRENTENCRYPTFILE];
    if (![[AESCrypt decrypt:[storage objectForKey:LoginStatus_KEY] password:PASSWORD] isEqualToString:@"islogin"]){
        RMLoginViewController * loginCtl = [[RMLoginViewController alloc] init];
        UINavigationController * loginNav = [[UINavigationController alloc] initWithRootViewController:loginCtl];
        [self presentViewController:loginNav animated:YES completion:^{
        }];
        return;
    }
    if (imageView.identifierString){
        if (imageView.isAttentionStarState == 0){
            loadType = requestAddStarMyChannelType;
            RMAFNRequestManager * requset = [[RMAFNRequestManager alloc] init];
            CUSFileStorage *storage = [CUSFileStorageManager getFileStorage:CURRENTENCRYPTFILE];
            NSDictionary *dict = [storage objectForKey:UserLoginInformation_KEY];
            [requset getJoinMyChannelWithToken:[NSString stringWithFormat:@"%@",[dict objectForKey:@"token"]] andID:imageView.identifierString];
            requset.delegate = self;
            rmImage = imageView;
        }else{
            loadType = requestDeleteStarMyChannelType;
            RMAFNRequestManager * requset = [[RMAFNRequestManager alloc] init];
            CUSFileStorage *storage = [CUSFileStorageManager getFileStorage:CURRENTENCRYPTFILE];
            NSDictionary *dict = [storage objectForKey:UserLoginInformation_KEY];
            [requset getDeleteMyChannelWithTag:imageView.identifierString WithToken:[NSString stringWithFormat:@"%@",[dict objectForKey:@"token"]]];
            requset.delegate = self;
            rmImage = imageView;
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    switch (scrollView.tag) {
        case 201:{
            [(PullToRefreshTableView *)[self.view viewWithTag:201] tableViewDidDragging];
            [self cancelSatrSearch];
            break;
        }
        case 202:{
            [(RMBaseTextField *)[self.view viewWithTag:searchTextField_TAG] resignFirstResponder];
            ((UIButton *)[self.view viewWithTag:cancelBtn_TAG]).hidden = NO;

            break;
        }
            
        default:
            break;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    NSInteger returnKey = [(PullToRefreshTableView *)[self.view viewWithTag:201] tableViewDidEndDragging];
    //  returnKey用来判断执行的拖动是下拉还是上拖
    //  如果数据正在加载，则回返DO_NOTHING
    //  如果是下拉，则返回k_RETURN_REFRESH
    //  如果是上拖，则返回k_RETURN_LOADMORE
    //  相应的Key宏定义也封装在PullToRefreshTableView中
    //  根据返回的值，您可以自己写您的数据改变方式
    
    if (returnKey != k_RETURN_DO_NOTHING) {
        //  这里执行方法
        NSString * key = [NSString stringWithFormat:@"%lu", (long)returnKey];
        [NSThread detachNewThreadSelector:@selector(updateThread:) toTarget:self withObject:key];
    }
}

- (void)updateThread:(id)sender {
    int index = [sender intValue];
    switch (index) {
        case k_RETURN_DO_NOTHING://不执行操作
        {
            break;
        }
        case k_RETURN_REFRESH://刷新
        {
            pageCount = 1;
            isRefresh = YES;
            [self startRequest];
            break;
        }
        case k_RETURN_LOADMORE://加载更多
        {
            pageCount ++;
            isRefresh = NO;
            [self startRequest];
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
        self.onVoiceImg.image = NULL;
        self.onVoiceImg.image = LOADIMAGE([self.onVoiceImgArr objectAtIndex:3], kImageTypePNG);
    }else if (volume >=6 && volume <=10){
        self.onVoiceImg.image = NULL;
        self.onVoiceImg.image = LOADIMAGE([self.onVoiceImgArr objectAtIndex:2], kImageTypePNG);
    }else if (volume >=11 && volume <=15){
        self.onVoiceImg.image = NULL;
        self.onVoiceImg.image = LOADIMAGE([self.onVoiceImgArr objectAtIndex:1], kImageTypePNG);
    }else if (volume >= 16 && volume <=100){
        self.onVoiceImg.image = NULL;
        self.onVoiceImg.image = LOADIMAGE([self.onVoiceImgArr objectAtIndex:0], kImageTypePNG);
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
        if (self.result.length == 0){
            ((UIButton *)[self.view viewWithTag:cancelBtn_TAG]).hidden = YES;
        }else{
            ((RMBaseTextField *)[self.view viewWithTag:searchTextField_TAG]).text = self.result;
            [self updateUserSearchRecord:self.result];
            [self.recordsTableView reloadData];
            [self startStarSearchRequest:self.result];
            
            ((UIButton *)[self.view viewWithTag:cancelBtn_TAG]).hidden = NO;
        }
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

#pragma mark - request RMAFNRequestManagerDelegate

- (void)startStarSearchRequest:(NSString *)key {
    loadType = requestSearchStarType;
    [(RMBaseTextField *)[self.view viewWithTag:searchTextField_TAG] resignFirstResponder];
    [SVProgressHUD showWithStatus:@"正在搜索" maskType:SVProgressHUDMaskTypeBlack];
    RMAFNRequestManager * request = [[RMAFNRequestManager alloc] init];
    [request getSearchStartWithName:[key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] page:@"1" count:@"20"];
    request.delegate = self;
}

- (void)startRequest {
    CUSFileStorage *storage = [CUSFileStorageManager getFileStorage:CURRENTENCRYPTFILE];
    NSDictionary *dict = [storage objectForKey:UserLoginInformation_KEY];
    RMAFNRequestManager * requset = [[RMAFNRequestManager alloc] init];
    [requset getStarListWithPage:[NSString stringWithFormat:@"%d",pageCount] count:@"12" WithToken:[NSString stringWithFormat:@"%@",[dict objectForKey:@"token"]]];
    requset.delegate = self;
}

- (void)requestFinishiDownLoadWith:(NSMutableArray *)data {
    if (loadType == requestStarListType){
        if (isRefresh){
            dataArr = data;
        }else{
            for (int i=0; i<data.count; i++) {
                RMPublicModel * model = [data objectAtIndex:i];
                [dataArr addObject:model];
            }
        }
        [(UITableView *)[self.view viewWithTag:201] reloadData];
        [(PullToRefreshTableView *)[self.view viewWithTag:201] reloadData:NO];
    }else if (loadType == requestAddStarMyChannelType){
        RMStarCell * cell = (RMStarCell *)[(PullToRefreshTableView *)[self.view viewWithTag:201] cellForRowAtIndexPath:rmImage.indexPath];
        UIImage * image = [[UIImage alloc] init];
        image = [UIImage imageNamed:@"mx_add_success_img"];
        [cell setImageWithImage:image IdentifierString:rmImage.identifierString AddMyChannel:YES];
    }else if (loadType == requestDeleteStarMyChannelType){
        RMStarCell * cell = (RMStarCell *)[(PullToRefreshTableView *)[self.view viewWithTag:201] cellForRowAtIndexPath:rmImage.indexPath];
        UIImage * image = [[UIImage alloc] init];
        image = [UIImage imageNamed:@"mx_add_img"];
        [cell setImageWithImage:image IdentifierString:rmImage.identifierString AddMyChannel:NO];
    }else if (loadType == requestSearchStarType){
        [SVProgressHUD dismiss];
        RMStarSearchResultViewController * starSearchResultCtl = [[RMStarSearchResultViewController alloc] init];
        starSearchResultCtl.resultData = data;
        UINavigationController * searchResultNav = [[UINavigationController alloc] initWithRootViewController:starSearchResultCtl];
        [self presentViewController:searchResultNav animated:YES completion:^{
            [self showStarVoiceView:NO WithShowVoiceImage:NO WithShowTableView:NO];
            ((UIButton *)[self.view viewWithTag:cancelBtn_TAG]).hidden = YES;
        }];
    }
}

- (void)requestError:(NSError *)error {
    if (loadType == requestSearchStarType){
        [SVProgressHUD showErrorWithStatus:@"搜索失败,请重新尝试"];
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
