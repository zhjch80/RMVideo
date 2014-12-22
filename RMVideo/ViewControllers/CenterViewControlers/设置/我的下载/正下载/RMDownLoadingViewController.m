//
//  RMDownLoadingViewController.m
//  RMVideo
//
//  Created by 润华联动 on 14-10-17.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMDownLoadingViewController.h"
#import "RMDownLoadingTableViewCell.h"
#import "Reachability.h"
#import "RMMyDownLoadViewController.h"

@interface RMDownLoadingViewController ()<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate>{
    Reachability * reach;
}

@end

@implementation RMDownLoadingViewController
static id _instance;

+ (id) alloc{
    return [super alloc];
}
+ (id) allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

+(id)copyWithZone:(struct _NSZone *)zone{
    return _instance;
}

- (id)init {
    static id obj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if((obj=[super init]) != nil){
            if(self.dataArray==nil){
                self.dataArray = [[NSMutableArray alloc] init];
                self.downLoadIDArray = [[NSMutableArray alloc] init];
                self.pauseLoadingArray = [[NSMutableArray alloc] init];
            }
        }
    });
    self = obj;
    return self;
}
+(instancetype)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    
    });
    return _instance;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    isCLickPauseCell = YES;
    [Flurry logEvent:@"VIEW_Setup_Downloading" timed:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    isCLickPauseCell = NO;
    [Flurry endTimedEvent:@"VIEW_Setup_Downloading" withParameters:nil];
    [reach stopNotifier];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSData * data = [[NSUserDefaults standardUserDefaults] objectForKey:DownLoadDataArray_KEY];
//    downLoadIndex = 0;
    [self showEmptyViewWithImage:[UIImage imageNamed:@"no_cashe_video"] WithTitle:@"您没有缓存记录"];
    NSArray * SavedownLoad = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    if(SavedownLoad==nil){
        if(self.dataArray.count==0){
            [self isShouldSetHiddenEmptyView:NO];
        }else{
            [self isShouldSetHiddenEmptyView:YES];
        }
    }else{
        for(RMPublicModel *model in SavedownLoad){
            [self.dataArray addObject:model];
        }
        [self isShouldSetHiddenEmptyView:YES];
    }
    [self.mainTableView reloadData];
    [self.pauseOrStarBtn setBackgroundImage:[UIImage imageNamed:@"start_all_downLoad_image"] forState:UIControlStateNormal];
    [self.showDownLoadState setTitle:@"全部开始" forState:UIControlStateNormal];
    self.isDownLoadNow = NO;
    [self setExtraCellLineHidden:self.mainTableView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beginAnimation) name:kDownLoadingControStartEditing object:nil];
    [[NSNotificationCenter defaultCenter ] addObserver:self selector:@selector(endAnimation) name:kDownLoadingControEndEditing object:nil];
    selectCellArray = [[NSMutableArray alloc] init];
    if(cellEditingImageArray==nil)
        cellEditingImageArray = [[NSMutableArray alloc] init];
    isPauseAllDownLoadAssignment = NO;
    for (int i=0; i<self.dataArray.count; i++) {
        [cellEditingImageArray addObject:@"no-select_cellImage"];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name: kReachabilityChangedNotification_One object:nil];
    // 获取访问指定站点的Reachability对象
    reach = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    // 让Reachability对象开启被监听状态
    [reach startNotifier];

}

- (void)reachabilityChanged:(NSNotification *)note {
    
    // 通过通知对象获取被监听的Reachability对象
    Reachability *curReach = [note object];
    // 获取Reachability对象的网络状态
    NetworkStatus status = [curReach currentReachabilityStatus];
    if (status == NotReachable&&self.downLoadIDArray.count>0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"没有网络连接" delegate:nil cancelButtonTitle:@"YES" otherButtonTitles:nil];
        [alert show];
    }
    else if(status != ReachableViaWiFi&&self.downLoadIDArray.count>0){
        [operation pause];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"当前不是wifi连接，是否继续下载" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消",nil];
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex==0){
        [operation resume];
    }
}

- (void)beginAnimation{
    isBeginEditing = YES;
    self.mainTableView.frame = CGRectMake(self.mainTableView.frame.origin.x, self.mainTableView.frame.origin.y, self.mainTableView.frame.size.width, self.mainTableView.frame.size.height-25);
}

- (void)endAnimation{
    
    isBeginEditing = NO;
    for(int i=0;i<selectCellArray.count;i++){
        NSNumber *number = [selectCellArray objectAtIndex:i];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:number.integerValue inSection:0];
        RMDownLoadingTableViewCell *cell = (RMDownLoadingTableViewCell*)[self.mainTableView cellForRowAtIndexPath:indexPath];
        cell.editingImageView.image = [UIImage imageNamed:@"no-select_cellImage"];
        [cellEditingImageArray replaceObjectAtIndex:number.integerValue withObject:@"no-select_cellImage"];
    }
    [selectCellArray removeAllObjects];
    self.mainTableView.frame = CGRectMake(self.mainTableView.frame.origin.x, self.mainTableView.frame.origin.y, self.mainTableView.frame.size.width, self.mainTableView.frame.size.height+25);
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identifier = @"downLoadingcellIIdentifier";
    RMDownLoadingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell==nil){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"RMDownLoadingTableViewCell" owner:self options:nil] lastObject];
        if(isBeginEditing)
            [cell setCellViewOfFrame];
    }
    //[cell setCellViewOfFrame];
    RMPublicModel *model = [self.dataArray objectAtIndex:indexPath.row];
    [cell.editingImageView setImage:[UIImage imageNamed:[cellEditingImageArray objectAtIndex:indexPath.row]]];
    if([model.name rangeOfString:@"电视剧"].location == NSNotFound){
        cell.titleLable.text = model.name;
    }else{
        NSString *titel = [model.name substringFromIndex:[model.name rangeOfString:@"_"].location+1];
//        titel = [titel substringToIndex:[titel rangeOfString:@"_"].location];
        cell.titleLable.text = titel;
    }
    [cell.headImage sd_setImageWithURL:[NSURL URLWithString:model.pic] placeholderImage:LOADIMAGE(@"Default90_119", kImageTypePNG)];
    
    cell.showDownLoadingState.text = model.downLoadState;
    if([[self setMemoryString:model.totalMemory] floatValue]==0){
        cell.showDownLoading.text = @"";
        [cell.downLoadProgress setProgress:0 animated:YES];
    }
    else{
        [cell.downLoadProgress setProgress:[model.cacheProgress floatValue] animated:YES];
        cell.showDownLoading.text = [NSString stringWithFormat:@"%@/%@",model.alreadyCasheMemory,model.totalMemory];
    }
    return cell;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 140.f;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(isBeginEditing){
        
        NSString *cellIamge = [cellEditingImageArray objectAtIndex:indexPath.row];
        if([cellIamge isEqualToString:@"no-select_cellImage"]){
            [cellEditingImageArray replaceObjectAtIndex:indexPath.row withObject:@"select_cellImage"];
        }else{
            [cellEditingImageArray replaceObjectAtIndex:indexPath.row withObject:@"no-select_cellImage"];
        }
        if([selectCellArray containsObject:[NSNumber numberWithInt:indexPath.row]]){
            [selectCellArray removeObject:[NSNumber numberWithInt:indexPath.row]];
        }
        else{
            [selectCellArray addObject:[NSNumber numberWithInt:indexPath.row]];
        }
        selectArray(selectCellArray);
        [self.mainTableView reloadData];
    }else{
        RMDownLoadingTableViewCell *cell = (RMDownLoadingTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        if([cell.showDownLoadingState.text isEqualToString:@"暂停缓存"]){
            RMPublicModel *model = [self.dataArray objectAtIndex:indexPath.row];
            model.downLoadState =@"等待缓存";
            [self.downLoadIDArray addObject:model];
//            self.isDownLoadNow = NO;
            [self.pauseLoadingArray removeObject:model];
            cell.showDownLoadingState.text = model.downLoadState;
            if(!self.isDownLoadNow){
                [self BeginDownLoad];
            }
        }
        else if([cell.showDownLoadingState.text isEqualToString:@"等待缓存"]){
            RMPublicModel *model = [self.dataArray objectAtIndex:indexPath.row];
            model.downLoadState = @"暂停缓存";
            [self.pauseLoadingArray addObject:model];
            [self.downLoadIDArray removeObject:model];
            cell.showDownLoadingState.text = model.downLoadState;
        }
        else if ([cell.showDownLoadingState.text isEqualToString:@"下载失败"]){
            RMPublicModel *model = [self.dataArray objectAtIndex:indexPath.row];
            model.downLoadState =@"等待缓存";
            cell.showDownLoadingState.text = model.downLoadState;
            [self.downLoadIDArray addObject:model];
            [self BeginDownLoad];
        }
        else {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showNetWorkingspeed) object:nil];
            [operation pause];
            RMPublicModel *model = [self.dataArray objectAtIndex:indexPath.row];
            model.downLoadState = @"暂停缓存";
            model.cacheProgress = [NSString stringWithFormat:@"%f",cell.downLoadProgress.progress];
            NSString *memory = cell.showDownLoading.text;
            NSRange range = [memory rangeOfString:@"/"];
            model.totalMemory = [memory substringFromIndex:range.location+1];
            model.alreadyCasheMemory = [memory substringToIndex:range.location];
            [self.pauseLoadingArray addObject:model];
            [self.downLoadIDArray removeObject:model];
            cell.showDownLoadingState.text = model.downLoadState;
            self.isDownLoadNow = NO; //表示暂停之后当前没有下载任务。
            if(self.downLoadIDArray.count>0){
                [self BeginDownLoad];
            }
        }
        selectIndex(indexPath.row);
        [self setPauseAllOrStartAllBtnState];
    }
}
- (IBAction)pauseOrStarAllBtnClick:(UIButton *)sender {
    if(self.dataArray.count==0||isBeginEditing){
        return;
    }
    if(!isPauseAllDownLoadAssignment){
        [self.pauseOrStarBtn setBackgroundImage:[UIImage imageNamed:@"start_all_downLoad_image"] forState:UIControlStateNormal];
        [self.showDownLoadState setTitle:@"全部开始" forState:UIControlStateNormal];
        self.isDownLoadNow = NO;
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showNetWorkingspeed) object:nil];
        [operation pause];
        [operation cancel];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:downLoadIndex inSection:0];
        RMDownLoadingTableViewCell *cell = (RMDownLoadingTableViewCell *)[self.mainTableView cellForRowAtIndexPath:indexPath];
        RMPublicModel *model = [self.dataArray objectAtIndex:downLoadIndex];
        model.downLoadState = @"暂停缓存";
        model.cacheProgress = [NSString stringWithFormat:@"%f",cell.downLoadProgress.progress];
        NSString *memory = cell.showDownLoading.text;
        NSRange range = [memory rangeOfString:@"/"];
        if(range.location != NSNotFound){
            model.totalMemory = [memory substringFromIndex:range.location+1];
            model.alreadyCasheMemory = [memory substringToIndex:range.location];
        }
        else{
            model.totalMemory = @"0M";
            model.alreadyCasheMemory = @"0M";
        }
        [self.downLoadIDArray removeAllObjects];
        for(int i=0;i<self.dataArray.count;i++){
            RMPublicModel *tmpModel = [self.dataArray objectAtIndex:i];
            tmpModel.downLoadState = @"暂停缓存";
            [self.pauseLoadingArray addObject:tmpModel];
        }
        [self.mainTableView reloadData];
        self.haveReadTheSchedule = 0;
        self.downLoadSpeed = 0;
        self.totalDownLoad = 0;
    }
    else{
        [self.pauseOrStarBtn setBackgroundImage:[UIImage imageNamed:@"pause_all_downLoad_Image"] forState:UIControlStateNormal];
        [self.showDownLoadState setTitle:@"全部暂停" forState:UIControlStateNormal];
        [self.pauseLoadingArray removeAllObjects];
        for(int i=0;i<self.dataArray.count;i++){
            RMPublicModel *tmpModel = [self.dataArray objectAtIndex:i];
            tmpModel.downLoadState = @"等待缓存";
            [self.downLoadIDArray addObject:tmpModel];
        }
        [self.mainTableView reloadData];
        if(!self.isDownLoadNow){
            RMPublicModel *model = [self.downLoadIDArray objectAtIndex:0];
            for (RMPublicModel *tmpmodel in self.dataArray) {
                if([tmpmodel.name isEqualToString:model.name]){
                    downLoadIndex = [self.dataArray indexOfObject:tmpmodel];
                    break;
                }
            }
            [self startDownloadWithMovieName:model];
        }
    }
    isPauseAllDownLoadAssignment = !isPauseAllDownLoadAssignment;
}

- (void)selectTableViewCellWithIndex:(void (^)(NSInteger))selectBlock{
    selectIndex = selectBlock;
}
- (void)delectCellArray:(void (^)(NSMutableArray *))block{
    selectArray = block;
}

- (void)selectAllTableViewCellWithState:(BOOL)state{
    [selectCellArray removeAllObjects];
    if(state){
        for(int i=0; i<self.dataArray.count;i++){
            [cellEditingImageArray replaceObjectAtIndex:i withObject:@"select_cellImage"];
            [selectCellArray addObject:[NSNumber numberWithInt:i]];
        }
        
    }else{
        for(int i=0; i<self.dataArray.count;i++){
            [cellEditingImageArray replaceObjectAtIndex:i withObject:@"no-select_cellImage"];
            [selectCellArray removeAllObjects];
        }
    }
    [self.mainTableView reloadData];
}

#pragma mark - 删除

- (void)deleteAllTableViewCell{
    
    NSMutableArray *deleteArray = [NSMutableArray array];
    NSArray *sort = [selectCellArray sortedArrayUsingComparator:^NSComparisonResult(NSNumber *obj1, NSNumber *obj2) {
        return obj1.integerValue < obj2.integerValue;
    }];
    for(int i=0;i<sort.count;i++){
        NSNumber *number = [sort objectAtIndex:i];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:number.integerValue inSection:0];
        [deleteArray addObject:indexPath];
    }
    for(int i=0;i<sort.count;i++){
        NSNumber *number = [sort objectAtIndex:i];
        RMPublicModel *model = [self.dataArray objectAtIndex:number.integerValue];
        [self.dataArray removeObjectAtIndex:number.integerValue];
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:number.integerValue inSection:0];
        NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
        [self.mainTableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        if (self.dataArray.count==0) {
            [self isShouldSetHiddenEmptyView:NO];
        }else{
            [self isShouldSetHiddenEmptyView:YES];
        }
        NSFileManager *fileManeger = [NSFileManager defaultManager];
        NSString *document = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSError *error = nil;
        NSString *toPath = [NSString stringWithFormat:@"%@/%@.mp4",document,model.name];
        BOOL delete = [fileManeger removeItemAtPath:toPath error:&error];
        if(delete){
            NSLog(@"删除成功");
        }
        if([self.downLoadIDArray containsObject:model]&&number.intValue==downLoadIndex){
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showNetWorkingspeed) object:nil];
            [operation pause];
            [operation cancel];
            [self.downLoadIDArray removeObject:model];
            self.isDownLoadNow = NO;
        }else if([self.downLoadIDArray containsObject:model]&&number.intValue!=downLoadIndex){
            [self.downLoadIDArray removeObject:model];
        }
        if([self.pauseLoadingArray containsObject:model]){
            [self.pauseLoadingArray removeObject:model];
        }
        [cellEditingImageArray removeObjectAtIndex:number.integerValue];
    }
    
    if(self.downLoadIDArray.count>0){
        downLoadIndex = 0;
        [self BeginDownLoad];
        self.downLoadSpeed = 0;
        self.haveReadTheSchedule = 0;
        self.totalDownLoad = 0;
    }
    [selectCellArray removeAllObjects];
    [[NSNotificationCenter defaultCenter ] postNotificationName:kDownLoadingControEndEditing object:nil];
}
- (void) BeginDownLoad{
    [self.mainTableView reloadData];
    [self isShouldSetHiddenEmptyView:YES];
    if(cellEditingImageArray.count<self.dataArray.count){
        if(cellEditingImageArray==nil){
            cellEditingImageArray = [[NSMutableArray alloc] init];
        }
        for(int i=0;i<self.dataArray.count-cellEditingImageArray.count;i++){
            [cellEditingImageArray addObject:@"no-select_cellImage"];
        }
    }
    if(!self.isDownLoadNow){
        RMPublicModel *model = [self.downLoadIDArray objectAtIndex:0];
        for (RMPublicModel *tmpmodel in self.dataArray) {
            if([tmpmodel.name isEqualToString:model.name]){
                downLoadIndex = [self.dataArray indexOfObject:tmpmodel];
                break;
            }
        }
        [self.showDownLoadState setTitle:@"全部暂停" forState:UIControlStateNormal];
        [self.pauseOrStarBtn setBackgroundImage:[UIImage imageNamed:@"pause_all_downLoad_Image"] forState:UIControlStateNormal];
        isPauseAllDownLoadAssignment = NO;
        [self startDownloadWithMovieName:model];
    }
    
    
}

//开始下载
- (void)startDownloadWithMovieName:(RMPublicModel *)model {
    self.isDownLoadNow = YES;
    NSString *downloadUrl = model.downLoadURL;
    
    NSString *cacheDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *downloadPath = [cacheDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",model.name]];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:downloadUrl]];
    //检查文件是否已经下载了一部分
    downloadedBytes = 0;
    if ([[NSFileManager defaultManager] fileExistsAtPath:downloadPath]) {
        //获取已下载的文件长度
        downloadedBytes = [self fileSizeForPath:downloadPath];
        if (downloadedBytes > 0) {
            NSMutableURLRequest *mutableURLRequest = [request mutableCopy];
            NSString *requestRange = [NSString stringWithFormat:@"bytes=%llu-", downloadedBytes];
            [mutableURLRequest setValue:requestRange forHTTPHeaderField:@"Range"];
            request = mutableURLRequest;
        }
    }
    //不使用缓存，避免断点续传出现问题
    [[NSURLCache sharedURLCache] removeCachedResponseForRequest:request];
    [operation cancel];
    //下载请求
    operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    //下载路径
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:downloadPath append:YES];
    //下载进度回调
    __unsafe_unretained RMDownLoadingViewController *weekSelf = self;
    
    [self showNetWorkingspeed];

    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        weekSelf.downLoadSpeed += bytesRead;
        weekSelf.haveReadTheSchedule = totalBytesRead;
        weekSelf.totalDownLoad = totalBytesExpectedToRead;
        //下载进度
        
    }];
    int index = downLoadIndex;
    AFHTTPRequestOperation *weekOperation = operation;
    //成功和失败回调
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [NSObject cancelPreviousPerformRequestsWithTarget:weekSelf selector:@selector(showNetWorkingspeed) object:nil];
        RMPublicModel *model = [weekSelf.dataArray objectAtIndex:index];
        model.downLoadState = @"下载中...";
        [weekSelf.downLoadIDArray removeObject:model];
        [weekSelf.dataArray removeObject:model];
        [weekSelf.mainTableView reloadData];
        weekSelf.isDownLoadNow = NO;
        [weekOperation pause];
        if (weekSelf.dataArray.count==0) {
            [weekSelf isShouldSetHiddenEmptyView:NO];
        }else{
            [weekSelf isShouldSetHiddenEmptyView:YES];
            if(weekSelf.downLoadIDArray.count>0){
                [weekSelf BeginDownLoad];
            }
        }
        NSFileManager *fileManeger = [NSFileManager defaultManager];
        
        NSString *document = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *path = [document stringByAppendingPathComponent:@"DownLoadSuccess"];
        BOOL isDir = NO;
        BOOL existed = [fileManeger fileExistsAtPath:path isDirectory:&isDir];
        if ( !(isDir == YES && existed == YES) )
        {
            [fileManeger createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        NSError *error;
        NSString *toPath = [NSString stringWithFormat:@"%@/%@.mp4",path,model.name];
        BOOL success = [fileManeger moveItemAtPath:downloadPath toPath:toPath  error:&error];
        if (success){
            
            //第一次下载的时候
            if([model.totalMemory isEqualToString:@"0M"]){
                model.totalMemory = [NSString stringWithFormat:@"%lldM",weekSelf.totalDownLoad/1024/1024];
            }
            [[Database sharedDatabase] insertDownLoadItem:model];
            RMMyDownLoadViewController * myDownLoadCtl = weekSelf.myDownLoadDelegate;
            [myDownLoadCtl setRightBarBtnItemState];
            
        }else{
            NSLog(@"error 处理  error:%@",error);
            BOOL delete = [fileManeger removeItemAtPath:toPath error:&error];
            if(delete)
                NSLog(@"删除成功");
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [NSObject cancelPreviousPerformRequestsWithTarget:weekSelf selector:@selector(showNetWorkingspeed) object:nil];
        [weekOperation pause];
        RMPublicModel *model = [weekSelf.dataArray objectAtIndex:index];
        model.downLoadState = @"下载失败";
//        model.cacheProgress = @"0";
//        model.totalMemory = @"0M";
//        model.alreadyCasheMemory = @"0M";
        [weekSelf.downLoadIDArray removeObject:model];
        [weekSelf.mainTableView reloadData];
        weekSelf.isDownLoadNow = NO;
        if(weekSelf.downLoadIDArray.count>0){
            [weekSelf BeginDownLoad];
        }
//        NSFileManager *fileManeger = [NSFileManager defaultManager];
//        NSString *document = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//        NSString *path = [document stringByAppendingPathComponent:@"DownLoadSuccess"];
//        NSError *myError;
//        NSString *toPath = [NSString stringWithFormat:@"%@/%@.mp4",path,model.name];
//        BOOL delete = [fileManeger removeItemAtPath:toPath error:&myError];
//        if(delete)
//            NSLog(@"删除成功");

    }];
    [operation start];
    
}

- (void)showNetWorkingspeed{
    
//    float progress = ((float)_haveReadTheSchedule) / (float)(_totalDownLoad );
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:downLoadIndex inSection:0];
    RMDownLoadingTableViewCell *cell = (RMDownLoadingTableViewCell *)[self.mainTableView cellForRowAtIndexPath:indexPath];
    RMPublicModel *model = [self.dataArray objectAtIndex:indexPath.row];
    cell.showDownLoadingState.text = [NSString stringWithFormat:@"%.1fkb/s",_downLoadSpeed/1024.0];
    //第一次下载的时候
    if([model.totalMemory isEqualToString:@"0M"]){
        cell.downLoadProgress.progress = 0;
        cell.showDownLoading.text = [NSString stringWithFormat:@"%lldM/%lldM",(_haveReadTheSchedule+downloadedBytes)/1024/1024,_totalDownLoad/1024/1024];
        model.totalMemory = [NSString stringWithFormat:@"%lldM",_totalDownLoad/1024/1024];
        model.alreadyCasheMemory = [NSString stringWithFormat:@"%lldM",(_haveReadTheSchedule+downloadedBytes)/1024/1024];
    }
   
    //暂停之后，或者继续下载之后
    else{
        float cashe = (_haveReadTheSchedule+downloadedBytes)/1024.0/1024.0;
        cell.showDownLoading.text = [NSString stringWithFormat:@"%.0fM/%@",cashe,model.totalMemory];
        cell.downLoadProgress.progress = cashe/[[self setMemoryString:model.totalMemory] floatValue];
        model.alreadyCasheMemory = [NSString stringWithFormat:@"%lldM",(_haveReadTheSchedule+downloadedBytes)/1024/1024];
//        model.totalMemory = [NSString stringWithFormat:@"%lldM",_totalDownLoad/1024/1024];
    }
    _downLoadSpeed = 0;
    [self performSelector:@selector(showNetWorkingspeed) withObject:nil afterDelay:1];
}
- (unsigned long long)fileSizeForPath:(NSString *)path {
    signed long long fileSize = 0;
    NSFileManager *fileManager = [NSFileManager new]; // default is not thread safe
    if ([fileManager fileExistsAtPath:path]) {
        NSError *error = nil;
        NSDictionary *fileDict = [fileManager attributesOfItemAtPath:path error:&error];
        if (!error && fileDict) {
            fileSize = [fileDict fileSize];
        }
    }
    return fileSize;
}

- (NSString *)setMemoryString:(NSString *)string{
    NSRange range = [string rangeOfString:@"M"];
    return [string substringToIndex:range.location];
}

- (void)saveData{
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showNetWorkingspeed) object:nil];
    [operation pause];
    [operation cancel];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:downLoadIndex inSection:0];
    RMDownLoadingTableViewCell *cell = (RMDownLoadingTableViewCell *)[self.mainTableView cellForRowAtIndexPath:indexPath];
    RMPublicModel *model = [self.dataArray objectAtIndex:downLoadIndex];
    model.cacheProgress = [NSString stringWithFormat:@"%f",cell.downLoadProgress.progress];
    NSString *memory = cell.showDownLoading.text;
    if(![memory isEqualToString:@""]){
        NSRange range = [memory rangeOfString:@"/"];
        model.totalMemory = [memory substringFromIndex:range.location+1];
        model.alreadyCasheMemory = [memory substringToIndex:range.location];
    }else{
        model.totalMemory = @"0M";
        model.alreadyCasheMemory = @"0M";

    }
    for(int i=0;i<self.dataArray.count;i++){
        RMPublicModel *tmpModel = [self.dataArray objectAtIndex:i];
        tmpModel.downLoadState = @"暂停缓存";
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//判断在dataArray中是否存在这个model
- (BOOL)dataArrayContainsModel:(RMPublicModel *)model{
    if(self.dataArray.count==0){
        NSData * data = [[NSUserDefaults standardUserDefaults] objectForKey:DownLoadDataArray_KEY];
        if(data==nil){
            return NO;
        }
        NSArray * SavedownLoad = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        for(RMPublicModel *model in SavedownLoad){
            [self.dataArray addObject:model];
        }
    }
    for (RMPublicModel *tmpModel in self.dataArray){
        if([tmpModel.name isEqualToString:model.name]){
            return YES;
        }
    }
    return NO;
}

- (void) setPauseAllOrStartAllBtnState{
    NSMutableArray *statusArr = [NSMutableArray array];
    for(RMPublicModel *model in self.dataArray){
        if([model.downLoadState isEqualToString:@"暂停缓存"]){
            [statusArr addObject:model];
        }
    }
    if(statusArr.count==self.dataArray.count){
        //全部开始
        [self.pauseOrStarBtn setBackgroundImage:[UIImage imageNamed:@"start_all_downLoad_image"] forState:UIControlStateNormal];
        [self.showDownLoadState setTitle:@"全部开始" forState:UIControlStateNormal];
        isPauseAllDownLoadAssignment = YES;
    }
    else{
        //全部暂停
        [self.pauseOrStarBtn setBackgroundImage:[UIImage imageNamed:@"pause_all_downLoad_Image"] forState:UIControlStateNormal];
        [self.showDownLoadState setTitle:@"全部暂停" forState:UIControlStateNormal];
        isPauseAllDownLoadAssignment = NO;
    }
}

@end
