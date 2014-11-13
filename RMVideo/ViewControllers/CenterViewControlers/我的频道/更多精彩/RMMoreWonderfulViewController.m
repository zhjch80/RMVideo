//
//  RMMoreWonderfulViewController.m
//  RMVideo
//
//  Created by runmobile on 14-10-14.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMMoreWonderfulViewController.h"
#import "AOTagList.h"

/**
 *区分请求类型
 *requestListType:  默认进来请求列表
 *requestReplease:  点击换一批
 *requestCustom:    自定义tag
 */
typedef enum{
    requestListType = 1,
    requestReplaceType,
    requestCustomType,
    requestAddTagToMyChannelType
}LoadType;

@interface RMMoreWonderfulViewController ()<UIScrollViewDelegate,UITextFieldDelegate,RMAFNRequestManagerDelegate,AOTagDelegate,TagListViewHeightDelegate> {
    NSMutableArray * dataArr;
    RMAFNRequestManager * request;
    NSInteger pageCount;
    
    LoadType loadType;
    AOTagList *tagList;
    AOTag * AOView;
}
@property (nonatomic, strong) UIScrollView * bgScrView;
@property (nonatomic, strong) NSMutableArray * tagArr;
@property (nonatomic, strong) NSMutableArray *randomTag;
@property (nonatomic, strong) UIButton * changeBtn;
@property (nonatomic, strong) UIButton * customBtn;
@property (nonatomic, assign) NSInteger willAddMyChannelTag_id;
@property (nonatomic, strong) NSString * BarButtonDirection;

@end

@implementation RMMoreWonderfulViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [Flurry logEvent:@"VIEW_MyChannel_MoreWonderful" timed:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [Flurry endTimedEvent:@"VIEW_MyChannel_MoreWonderful" withParameters:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([self.BarButtonDirection isEqualToString:@"left"]){
        [self setTitle:@"更多精彩"];
        leftBarButton.frame = CGRectMake(0, 0, 22, 22);
        [leftBarButton setBackgroundImage:LOADIMAGE(@"backup_img", kImageTypePNG) forState:UIControlStateNormal];
        rightBarButton.hidden = YES;
    }else{
        self.BarButtonDirection = @"right";
        [self setTitle:@"您可能喜欢的内容"];
        leftBarButton.hidden = YES;
        rightBarButton.frame = CGRectMake(0, 0, 35, 20);
        [rightBarButton setBackgroundImage:LOADIMAGE(@"complete_btn_image", kImageTypePNG) forState:UIControlStateNormal];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    loadType = requestListType;

    dataArr = [[NSMutableArray alloc] init];
    pageCount = 1;
    
    self.bgScrView = [[UIScrollView alloc] init];
    self.bgScrView.frame = CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleHeight - 130);
    self.bgScrView.userInteractionEnabled = YES;
    self.bgScrView.showsVerticalScrollIndicator = YES;
    self.bgScrView.showsHorizontalScrollIndicator = YES;
    self.bgScrView.delegate = self;
    self.bgScrView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.bgScrView];
    
    self.changeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.changeBtn.tag = 101;
    self.changeBtn.frame = CGRectMake([UtilityFunc shareInstance].globleWidth - ([UtilityFunc shareInstance].globleWidth-25), [UtilityFunc shareInstance].globleAllHeight-69-64, 117, 39);
    [self.changeBtn setBackgroundImage:LOADIMAGE(@"changeBtn_img", kImageTypePNG) forState:UIControlStateNormal];
    [self.changeBtn addTarget:self action:@selector(mbuttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.changeBtn];
    
    self.customBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.customBtn.frame = CGRectMake([UtilityFunc shareInstance].globleWidth-25-117, [UtilityFunc shareInstance].globleAllHeight-69-64, 117, 39);
    [self.customBtn setBackgroundImage:LOADIMAGE(@"customBtn_img", kImageTypePNG) forState:UIControlStateNormal];
    [self.customBtn addTarget:self action:@selector(mbuttonClick:) forControlEvents:UIControlEventTouchUpInside];
    self.customBtn.tag = 102;
    [self.view addSubview:self.customBtn];

    [self loadTagList];
    
    request = [[RMAFNRequestManager alloc] init];
    [request getMoreWonderfulVideoListWithPage:[NSString stringWithFormat:@"%d",pageCount] count:@"15"];
    request.delegate = self;
}

- (void)setupNavTitle:(NSString *)title SwitchingBarButtonDirection:(NSString *)direction {
    self.BarButtonDirection = direction;
}

- (void)resetRandomTagsName {
    [tagList removeAllTag];
    if (dataArr.count == 0){
        return ;
    }else if (dataArr.count < 15){
        return;
    }
    self.randomTag = [NSMutableArray arrayWithArray:
                      @[@{@"title": ((RMPublicModel *)[dataArr objectAtIndex:0]).name},
                        @{@"title": ((RMPublicModel *)[dataArr objectAtIndex:1]).name},
                        @{@"title": ((RMPublicModel *)[dataArr objectAtIndex:2]).name},
                        @{@"title": ((RMPublicModel *)[dataArr objectAtIndex:3]).name},
                        @{@"title": ((RMPublicModel *)[dataArr objectAtIndex:4]).name},
                        @{@"title": ((RMPublicModel *)[dataArr objectAtIndex:5]).name},
                        @{@"title": ((RMPublicModel *)[dataArr objectAtIndex:6]).name},
                        @{@"title": ((RMPublicModel *)[dataArr objectAtIndex:7]).name},
                        @{@"title": ((RMPublicModel *)[dataArr objectAtIndex:8]).name},
                        @{@"title": ((RMPublicModel *)[dataArr objectAtIndex:9]).name},
                        @{@"title": ((RMPublicModel *)[dataArr objectAtIndex:10]).name},
                        @{@"title": ((RMPublicModel *)[dataArr objectAtIndex:11]).name},
                        @{@"title": ((RMPublicModel *)[dataArr objectAtIndex:12]).name},
                        @{@"title": ((RMPublicModel *)[dataArr objectAtIndex:13]).name},
                        @{@"title": ((RMPublicModel *)[dataArr objectAtIndex:14]).name}]];
}

- (void)loadTagList {
    if (!tagList){
        tagList = [[AOTagList alloc] init];
    }
    tagList.frame = CGRectMake(-10.0f, 20.0f, 330.0f, 100.0f);
    tagList.heightDelegate = self;
    tagList.backgroundColor = [UIColor clearColor];
    [tagList setDelegate:self];
    [self.bgScrView addSubview:tagList];
    
}

- (void)clickChangeBtnWithTagListHeight:(float)height {
    [self.bgScrView setContentSize:CGSizeMake([UtilityFunc shareInstance].globleWidth, height + 20)];
}

- (void)updataTagList {
    [self resetRandomTagsName];
    [tagList addTags:self.randomTag];
    [tagList sizeToFit];
    [self.randomTag removeAllObjects];
}

- (NSInteger)getTagIdFromTag:(NSString *)str {
    for (int i=0; i<dataArr.count; i++){
        if ([((RMPublicModel *)[dataArr objectAtIndex:i]).name isEqualToString:str]){
            NSLog(@"%@",((RMPublicModel *)[dataArr objectAtIndex:i]).tag_id);
            return [((RMPublicModel *)[dataArr objectAtIndex:i]).tag_id integerValue];
            break;
        }
    }
    return 0;
}

#pragma mark - 

- (void)mbuttonClick:(UIButton *)sender {
    switch (sender.tag) {
        case 101:{
            loadType = requestReplaceType;
            pageCount ++;
            [request getMoreWonderfulVideoListWithPage:[NSString stringWithFormat:@"%d",pageCount] count:@"15"];
            break;
        }
        case 102:{
            UIAlertView *addAlertView = [[UIAlertView alloc] initWithTitle:@"添加属于自己的标签"
                                                                   message:nil
                                                                  delegate:self
                                                         cancelButtonTitle:@"取消"
                                                         otherButtonTitles:@"添加", nil];
            [addAlertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
            addAlertView.tag = 201;
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
    switch (alertView.tag) {
        case 201:{
            if (buttonIndex != alertView.cancelButtonIndex) {
                if (buttonIndex == 1) {
                    //添加
                    loadType = requestCustomType;
                    NSString *str = [alertView textFieldAtIndex:0].text;
                    CUSFileStorage *storage = [CUSFileStorageManager getFileStorage:CURRENTENCRYPTFILE];
                    NSDictionary *dict = [storage objectForKey:UserLoginInformation_KEY];
                    [request getCustomTagWithToken:[NSString stringWithFormat:@"%@",[dict objectForKey:@"token"]] tagName:[str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                }else{
                }
            }
            break;
        }
        case 202:{
            if (buttonIndex != alertView.cancelButtonIndex) {
                if (buttonIndex == 1) {
                    //添加
                    loadType = requestAddTagToMyChannelType;
                    CUSFileStorage *storage = [CUSFileStorageManager getFileStorage:CURRENTENCRYPTFILE];
                    NSDictionary *dict = [storage objectForKey:UserLoginInformation_KEY];
                    [request getJoinMyChannelWithToken:[NSString stringWithFormat:@"%@",[dict objectForKey:@"token"]] andID:[NSString stringWithFormat:@"%d",self.willAddMyChannelTag_id]];
                }else{
                }
            }

            break;
        }
            
        default:
            break;
    }
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
            [self dismissViewControllerAnimated:YES completion:^{
            }];
            break;
        }
            
        default:
            break;
    }
}

#pragma mark - request RMAFNRequestManagerDelegate

- (void)requestFinishiDownLoadWith:(NSMutableArray *)data {
    if (loadType == requestListType){
        dataArr = data;
        [self updataTagList];
    }else if (loadType == requestReplaceType){
        dataArr = data;
        [self updataTagList];
    }else if (loadType == requestCustomType){
        RMPublicModel *model = [data objectAtIndex:0];
        if ([model.code integerValue] == 4001) {
            NSLog(@"增加新的tag成功");
            //TODO:添加到 我的频道
        }
    }else if (loadType == requestAddTagToMyChannelType){
        
    }
}

- (void)requestError:(NSError *)error {
    NSLog(@"error;%@",error);
}

#pragma mark - Tag delegate

- (void)tagDidAddTag:(AOTag *)tag {
    NSLog(@"Tag > %@ has been added", tag);
}

- (void)tagDidRemoveTag:(AOTag *)tag {
    NSLog(@"Tag > %@ has been removed", tag);
}

- (void)tagDidSelectTag:(AOTag *)tag {
    self.willAddMyChannelTag_id = [self getTagIdFromTag:tag.tTitle];
    UIAlertView *addAlertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"亲，确定要添加 %@ 到我的频道么？",tag.tTitle]
                                                           message:nil
                                                          delegate:self
                                                 cancelButtonTitle:@"取消"
                                                 otherButtonTitles:@"添加", nil];
    addAlertView.tag = 202;
    [addAlertView show];
}

#pragma mark - Tag delegate

- (void)tagDistantImageDidLoad:(AOTag *)tag {
    NSLog(@"Distant image has been downloaded for tag > %@", tag);
}

- (void)tagDistantImageDidFailLoad:(AOTag *)tag withError:(NSError *)error {
    NSLog(@"Distant image has failed to download > %@ for tag > %@", error, tag);
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
