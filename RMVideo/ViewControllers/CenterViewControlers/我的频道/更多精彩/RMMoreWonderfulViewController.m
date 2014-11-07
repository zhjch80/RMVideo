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
    requestReplace,
    requestCustom
}LoadType;

@interface RMMoreWonderfulViewController ()<UIScrollViewDelegate,UITextFieldDelegate,RMAFNRequestManagerDelegate,AOTagDelegate> {
    NSMutableArray * dataArr;
    RMAFNRequestManager * request;
    NSInteger pageCount;
    
    LoadType loadType;
    AOTagList *tagList;
}
@property (nonatomic, strong) UIScrollView * bgScrView;
@property (nonatomic, strong) NSMutableArray * tagArr;
@property (nonatomic, strong) NSMutableArray *randomTag;
@property (nonatomic, strong) UIButton * changeBtn;
@property (nonatomic, strong) UIButton * customBtn;

@end

@implementation RMMoreWonderfulViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    loadType = requestListType;

    dataArr = [[NSMutableArray alloc] init];
    pageCount = 1;
    
    [self setTitle:@"更多精彩"];
    [leftBarButton setBackgroundImage:LOADIMAGE(@"backup_img", kImageTypePNG) forState:UIControlStateNormal];
    rightBarButton.hidden = YES;
    
    self.bgScrView = [[UIScrollView alloc] init];
    self.bgScrView.backgroundColor = [UIColor clearColor];
    self.bgScrView.frame = CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleHeight - 44);
    self.bgScrView.userInteractionEnabled = YES;
    self.bgScrView.showsVerticalScrollIndicator = YES;
    self.bgScrView.showsHorizontalScrollIndicator = YES;
    self.bgScrView.delegate = self;
    self.bgScrView.backgroundColor = [UIColor clearColor];
    [self.bgScrView setContentSize:CGSizeMake([UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleHeight - 43)];
    [self.view addSubview:self.bgScrView];
    
    self.changeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.changeBtn.tag = 101;
    [self.changeBtn setBackgroundImage:LOADIMAGE(@"changeBtn_img", kImageTypePNG) forState:UIControlStateNormal];
    [self.changeBtn addTarget:self action:@selector(mbuttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.bgScrView addSubview:self.changeBtn];
    
    self.customBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.customBtn setBackgroundImage:LOADIMAGE(@"customBtn_img", kImageTypePNG) forState:UIControlStateNormal];
    [self.customBtn addTarget:self action:@selector(mbuttonClick:) forControlEvents:UIControlEventTouchUpInside];
    self.customBtn.tag = 102;
    [self.bgScrView addSubview:self.customBtn];

    [self loadTagList];
    
    request = [[RMAFNRequestManager alloc] init];
    [request getMoreWonderfulVideoListWithPage:[NSString stringWithFormat:@"%d",pageCount] count:@"15"];
    request.delegate = self;
}

- (void)resetRandomTagsName {
    [tagList removeAllTag];
    self.randomTag = [NSMutableArray arrayWithArray:
                      @[@{@"title": @"速度发生的"},
                        @{@"title": @"阿萨德是的"},
                        @{@"title": @"大师大师大"},
                        @{@"title": @"阿三打"},
                        @{@"title": @"撒旦"},
                        @{@"title": @"阿三达到阿达"},
                        @{@"title": @"阿三啊大大的撒上撒旦撒旦"},
                        @{@"title": @"就开工开广东省撒旦士大士大夫"},
                        @{@"title": @"的发生收到过时尚大方士大夫"},
                        @{@"title": @"速度发生的士大夫士大夫士大夫"},
                        @{@"title": @"士大夫士大夫"},
                        @{@"title": @"士大夫"},
                        @{@"title": @"士大发夫"},
                        @{@"title": @"第三方"},
                        @{@"title": @"士大夫"}]];
}

- (void)loadTagList {
    [self resetRandomTagsName];
    
    tagList = [[AOTagList alloc] initWithFrame:CGRectMake(10.0f, 10.0f, 300.0f, 100.0f)];
    tagList.backgroundColor = [UIColor clearColor];
    [tagList setDelegate:self];
    [tagList sizeToFit];
    [self.bgScrView addSubview:tagList];
    
    [self updataTagList];
}

- (void)updataTagList {
    [self resetRandomTagsName];
    [tagList addTags:self.randomTag];
    [self.randomTag removeAllObjects];
    
    self.changeBtn.frame = CGRectMake([UtilityFunc shareInstance].globleWidth - ([UtilityFunc shareInstance].globleWidth-25), tagList.frame.size.height+64, 117, 39);
    self.customBtn.frame = CGRectMake([UtilityFunc shareInstance].globleWidth-25-117, tagList.frame.size.height+64, 117, 39);
}

#pragma mark - 

- (void)mbuttonClick:(UIButton *)sender {
    switch (sender.tag) {
        case 101:{
            loadType = requestReplace;
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

#pragma mark - request RMAFNRequestManagerDelegate

- (void)requestFinishiDownLoadWith:(NSMutableArray *)data {
    if (loadType == requestListType){
        dataArr = data;
        [self updataTagList];
    }else if (loadType == requestReplace){
        dataArr = data;
        [self updataTagList];
    }else if (loadType == requestCustom){
        RMPublicModel *model = [data objectAtIndex:0];
        if ([model.code integerValue] == 4001) {
            NSLog(@"增加新的tag成功");
            //TODO:添加到 我的频道
        }
    }
}

- (void)requestError:(NSError *)error {
    NSLog(@"error;%@",error);
}

#pragma mark - Tag delegate

- (void)tagDidAddTag:(AOTag *)tag
{
    NSLog(@"Tag > %@ has been added", tag);
}

- (void)tagDidRemoveTag:(AOTag *)tag
{
    NSLog(@"Tag > %@ has been removed", tag);
}

- (void)tagDidSelectTag:(AOTag *)tag
{
    NSLog(@"Tag > %@ has been selected", tag);
}

#pragma mark - Tag delegate

- (void)tagDistantImageDidLoad:(AOTag *)tag
{
    NSLog(@"Distant image has been downloaded for tag > %@", tag);
}

- (void)tagDistantImageDidFailLoad:(AOTag *)tag withError:(NSError *)error
{
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
