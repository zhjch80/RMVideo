//
//  RMDownLoadingViewController.m
//  RMVideo
//
//  Created by 润华联动 on 14-10-17.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMDownLoadingViewController.h"
#import "RMDownLoadingTableViewCell.h"

@interface RMDownLoadingViewController ()<UITableViewDelegate,UITableViewDataSource>

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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSData * data = [[NSUserDefaults standardUserDefaults] objectForKey:DownLoadDataArray_KEY];
    if(data==nil){
        //**********************测试代码*****************************
        NSArray *array = [NSArray arrayWithObjects:
                          @"http://220.181.185.11/youku/65731ACC75844831216E3C4844/0300200100544E32020A2D0014D61B004A5863-6A4D-E160-C56E-827D4238A6CE.mp4",
                          @"http://220.181.154.16/youku/656B30CDEB4483119528C6ED4/030020010053FB3BCE67EF05CF07DD52B74D26-EF08-8769-2598-9D1A5CE6E429.mp4",
                          @"http://220.181.185.19/youku/67727438CB34683298E27F55BF/0300200100513DD205D938055EEB3E16881E52-345A-B3E8-2FA8-FEEBDC4DE258.mp4",
                          @"http://106.38.249.111/youku/6572F43C9913E7AB76FC8341D/030020010050DF50204722055EEB3EEEFEA7BC-55AD-EED3-7D4A-675DFBC92E6B.mp4",
                          @"http://106.38.249.78/youku/69722980B683378C8B18348B1/030020010050B4DD0D8561055EEB3E385E6FED-6204-8E1F-0267-F7940EF9D418.mp4", nil];
        NSArray *nameArray = [NSArray arrayWithObjects:@"绣春刀",@"庞贝末日",@"神笔马良",@"幻影车神",@"分手大师", nil];
        for(int i=0;i<5;i++){
            RMPublicModel *model = [[RMPublicModel alloc] init];
            model.downLoadURL = [array objectAtIndex:i];
            model.name = [nameArray objectAtIndex:i];
            model.pic = @"http://a.hiphotos.baidu.com/image/w%3D310/sign=d372b7e38544ebf86d71623ee9f8d736/30adcbef76094b3614bd950da1cc7cd98d109d27.jpg";
            model.downLoadState = @"等待缓存";
            model.totalMemory = @"0M";
            model.alreadyCasheMemory = @"0M";
            model.cacheProgress = @"0.0";
            [self.dataArray addObject:model];
            downLoadIndex = 0;
            [self BeginDownLoad];
        }
        /**********************************************************/
    }else{
        isCLickPauseCell = YES;
        NSArray * SavedownLoad = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        self.dataArray = [SavedownLoad mutableCopy];
        [self.mainTableView reloadData];
        [self.pauseOrStarBtn setBackgroundImage:[UIImage imageNamed:@"start_all_downLoad_image"] forState:UIControlStateNormal];
        [self.showDownLoadState setTitle:@"全部开始" forState:UIControlStateNormal];
        self.isDownLoadNow = NO;
    }
    [self setExtraCellLineHidden:self.mainTableView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beginAnimation) name:kDownLoadingControStartEditing object:nil];
    [[NSNotificationCenter defaultCenter ] addObserver:self selector:@selector(endAnimation) name:kDownLoadingControEndEditing object:nil];
    selectCellArray = [[NSMutableArray alloc] init];
    cellEditingImageArray = [[NSMutableArray alloc] init];
    isPauseAllDownLoadAssignment = NO;
    for (int i=0; i<self.dataArray.count; i++) {
        [cellEditingImageArray addObject:@"no-select_cellImage"];
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
    cell.titleLable.text = model.name;
    [cell.headImage sd_setImageWithURL:[NSURL URLWithString:model.pic]];
    [cell.downLoadProgress setProgress:[model.cacheProgress floatValue] animated:YES];
    cell.showDownLoadingState.text = model.downLoadState;
    if([[self setMemoryString:model.totalMemory] floatValue]==0){
        cell.showDownLoading.text = @"";
    }
    else{
        cell.showDownLoading.text = [NSString stringWithFormat:@"%@/%@",model.alreadyCasheMemory,model.totalMemory];

    }
    return cell;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 84.f;
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
            if(self.isDownLoadNow){
                model.downLoadState =@"等待缓存";
                cell.showDownLoadingState.text = model.downLoadState;
                [self.mainTableView reloadData];
                RMPublicModel *model = [self.dataArray objectAtIndex:downLoadIndex];
                [self startDownloadWithMovieName:model];
            }
            else{
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showNetWorkingspeed) object:nil];
                [operation pause];
            }
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
    }
}
- (IBAction)pauseOrStarAllBtnClick:(UIButton *)sender {
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
        model.totalMemory = [memory substringFromIndex:range.location+1];
        model.alreadyCasheMemory = [memory substringToIndex:range.location];
        [self.downLoadIDArray removeAllObjects];
        for(int i=0;i<self.dataArray.count;i++){
            RMPublicModel *tmpModel = [self.dataArray objectAtIndex:i];
            tmpModel.downLoadState = @"暂停缓存";
            [self.pauseLoadingArray addObject:tmpModel];
        }
        [self.mainTableView reloadData];
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

- (void)deleteAllTableViewCell{
    
    NSMutableArray *deleteArray = [NSMutableArray array];
    NSArray *sort = [selectCellArray sortedArrayUsingComparator:^NSComparisonResult(NSNumber *obj1, NSNumber *obj2) {
        return obj1.integerValue<obj2.integerValue;
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
        
        if([self.downLoadIDArray containsObject:model]){
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showNetWorkingspeed) object:nil];
            [operation pause];
            [operation cancel];
            [self.downLoadIDArray removeObject:model];
            self.isDownLoadNow = NO;
        }else{
            [self.pauseLoadingArray removeObject:model];
        }
        [cellEditingImageArray removeObjectAtIndex:number.integerValue];
    }
    
    if(self.downLoadIDArray.count>0){
        downLoadIndex = 0;
        [self BeginDownLoad];
    }
    [self.mainTableView deleteRowsAtIndexPaths:deleteArray withRowAnimation:UITableViewRowAnimationNone];
    [self.mainTableView reloadData];
    [selectCellArray removeAllObjects];
    [[NSNotificationCenter defaultCenter ] postNotificationName:kDownLoadingControEndEditing object:nil];
}
- (void) BeginDownLoad{
    if(!isCLickPauseCell){
        for (RMPublicModel *model in self.dataArray) {
            if([self.downLoadIDArray containsObject: model]){
                continue;
            }else{
                [self.downLoadIDArray addObject:model];
            }
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
    unsigned long long downloadedBytes = 0;
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
        [weekSelf.downLoadIDArray removeObject:model];
        [weekSelf.dataArray removeObject:model];
        [weekSelf.mainTableView reloadData];
        if(weekSelf.downLoadIDArray.count==0){
            weekSelf.isDownLoadNow = YES;
        }else{
            weekSelf.isDownLoadNow = NO;
        }
        [weekOperation pause];
        [weekSelf BeginDownLoad];
        
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
                model.totalMemory = [NSString stringWithFormat:@"%lldM",weekSelf.totalDownLoad/2028/1024];
            }
            [[Database sharedDatabase] insertDownLoadItem:model];
            [[NSNotificationCenter defaultCenter] postNotificationName:DownLoadSuccess_KEY object:nil];
            
        }else{
            NSLog(@"error 处理  error:%@",error);
            BOOL delete = [fileManeger removeItemAtPath:toPath error:&error];
            if(delete)
                NSLog(@"删除成功");
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        RMDownLoadingTableViewCell *cell = (RMDownLoadingTableViewCell *)[weekSelf.mainTableView cellForRowAtIndexPath:indexPath];
        cell.showDownLoadingState.text = @"下载失败";
        weekSelf.downLoadSpeed = 0;

    }];
    [operation start];
    
}

- (void)showNetWorkingspeed{
    
    float progress = ((float)_haveReadTheSchedule) / (float)(_totalDownLoad );
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:downLoadIndex inSection:0];
    RMDownLoadingTableViewCell *cell = (RMDownLoadingTableViewCell *)[self.mainTableView cellForRowAtIndexPath:indexPath];
    RMPublicModel *model = [self.dataArray objectAtIndex:indexPath.row];
    cell.showDownLoadingState.text = [NSString stringWithFormat:@"%.1fkb/s",_downLoadSpeed/2048.0];
    //第一次下载的时候
    if([model.totalMemory isEqualToString:@"0M"]){
        cell.downLoadProgress.progress = progress;
        cell.showDownLoading.text = [NSString stringWithFormat:@"%lldM/%lldM",_haveReadTheSchedule/2048/1024,_totalDownLoad/2028/1024];
    }
    //暂停之后，或者继续下载之后
    else{
        float cashe = _haveReadTheSchedule/2048.0/1024.0+[[self setMemoryString:model.alreadyCasheMemory] floatValue];
        cell.showDownLoading.text = [NSString stringWithFormat:@"%.0fM/%@",cashe,model.totalMemory];
        cell.downLoadProgress.progress = cashe/[[self setMemoryString:model.totalMemory] floatValue];
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

- (void)viewDidAppear:(BOOL)animated{
    isCLickPauseCell = YES;
}
- (void)viewWillDisappear:(BOOL)animated{
    isCLickPauseCell = NO;
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
- (void)dealloc{
    NSLog(@"进来没");
    /*
         }
     */
}
@end
