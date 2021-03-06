//
//  AppDelegate.m
//  RMVideo
//
//  Created by runmobile on 14-9-28.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "AppDelegate.h"
#import "UtilityFunc.h"
#import "LeftMenuViewController.h"
#import "RightMenuViewController.h"
#import "RMRecommendedDailyViewController.h"
#import "RMSoHotListViewController.h"
#import "RMStarViewController.h"
#import "RMMyChannelViewController.h"
#import "HJMTabBar.h"
#import "MMDrawerController.h"
#import "MMDrawerVisualState.h"
#import "MMExampleDrawerVisualStateManager.h"
#import "UIViewController+MMDrawerController.h"
#import <QuartzCore/QuartzCore.h>
#import "UMSocial.h"
#import "UMSocialWechatHandler.h"
#import "UMSocialQQHandler.h"
#import "iflyMSC/iflySetting.h"
#import "iflyMSC/IFlySpeechUtility.h"
#import "RMCustomNavViewController.h"
#import "RMDownLoadingViewController.h"
#import "Flurry.h"
#import "Harpy.h"
#import "APService.h"

#define COLOR_RGB(r,g,b) [UIColor colorWithRed:(r/255.0f) green:(g/255.0f) blue:(b/255.0f) alpha:1]
#define IS_IOS7 [[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0
#define NAVI_COLOR [UIColor colorWithRed:0.76 green:0.03 blue:0.09 alpha:1]
#define APP @"APP"
#define ITUNES_APP @"https://itunes.apple.com/cn/app/r-evolve/id944155902?mt=8" //itunes

@interface AppDelegate ()

@property (nonatomic, strong) MMDrawerController * drawerController;

@property (nonatomic) UIBackgroundTaskIdentifier bgTask;

@end

@implementation AppDelegate
@synthesize drawerController = _drawerController;

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self loadMSC];
    //专门针对iPhone6 plus在处于横屏的时候的强制转成竖屏
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:NO];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [self appearance];
    
    [self initGlobalWidthAndHeight];
    
    [self initMainViewController];
        
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    [self.window makeKeyAndVisible];
    
    [self loadFlurry];
    
    [self loadSocial];
    
    CUSFileStorage *storage = [CUSFileStorageManager getFileStorage:CURRENTENCRYPTFILE];
    NSString * loginStatus = [AESCrypt decrypt:[storage objectForKey:LoginStatus_KEY] password:PASSWORD];
    if (loginStatus == nil){
        [storage beginUpdates];
        NSString * loginStatus = [AESCrypt encrypt:@"notlogin" password:PASSWORD];
        [storage setObject:loginStatus forKey:LoginStatus_KEY];
        [storage endUpdates];
    }
    
    //检查App更新(UpData)
    if ([UtilityFunc isConnectionAvailable] != 0) {
        [Harpy checkVersion];
    }
    if (launchOptions) {
        NSDictionary * pushDict = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (pushDict) {
            [application setApplicationIconBadgeNumber:0];
        }
    }
    //JPush
    [self loadJPushWithOptions:launchOptions];

    return YES;
}

- (void)loadFlurry {
    [Flurry setCrashReportingEnabled:YES];
    [Flurry startSession:@"PJZBVWP6HTXW8FZFFZW5"];
}

- (void)loadSocial {
    [UMSocialData setAppKey:UMengAppKey];
    [UMSocialWechatHandler setWXAppId:@"wxeb2fbbe81019f3b7" appSecret:@"3025a81418b686d9e38acafec6d21fc5" url:ITUNES_APP];
    [UMSocialQQHandler setQQWithAppId:@"1103514725" appKey:@"DPr140rgS4i2L53j" url:ITUNES_APP];
    [UMSocialQQHandler setSupportWebView:YES];
}

- (void)loadJPushWithOptions:(NSDictionary *)launchOptions {
    // Required
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_7_1
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        //可以添加自定义categories
        [APService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                       UIUserNotificationTypeSound |
                                                       UIUserNotificationTypeAlert)
                                           categories:nil];
    } else {
        //categories 必须为nil
        [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                       UIRemoteNotificationTypeSound |
                                                       UIRemoteNotificationTypeAlert)
                                           categories:nil];
    }
#else
    //categories 必须为nil
    [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                   UIRemoteNotificationTypeSound |
                                                   UIRemoteNotificationTypeAlert)
                                       categories:nil];
#endif
    // Required
    [APService setupWithOption:launchOptions];
}

#pragma mark - MSC 科大讯飞 语音

- (void)loadMSC {
    //设置log等级，此处log为默认在app沙盒目录下的msc.log文件
    [IFlySetting setLogFile:LVL_NONE];
    
    //输出在console的log开关 发布时候关闭
    [IFlySetting showLogcat:NO];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [paths objectAtIndex:0];
    //设置msc.log的保存路径
    [IFlySetting setLogFilePath:cachePath];
    
    //创建语音配置,appid必须要传入，仅执行一次则可
    NSString *initString = [[NSString alloc] initWithFormat:@"appid=%@,timeout=%@",APPID_VALUE,TIMEOUT_VALUE];
    
    //所有服务启动前，需要确保执行createUtility
    [IFlySpeechUtility createUtility:initString];
}

#pragma mark - The main method

- (void)initGlobalWidthAndHeight {
    //屏幕宽 高
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    [UtilityFunc shareInstance].globleWidth = screenRect.size.width; //屏幕宽度
    [UtilityFunc shareInstance].globleHeight = screenRect.size.height-20;  //屏幕高度（无顶栏）
    [UtilityFunc shareInstance].globleAllHeight = screenRect.size.height;  //屏幕高度（有顶栏）
}

- (void)appearance {
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    [UIApplication sharedApplication].statusBarHidden = NO;
    
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          COLOR_RGB(53, 55, 76),
                                                          NSForegroundColorAttributeName,
                                                          COLOR_RGB(0, 0, 0),
                                                          NSShadowAttributeName,
                                                          [NSValue valueWithUIOffset:UIOffsetMake(0, 0)],
                                                          NSShadowAttributeName,
                                                          [UIFont systemFontOfSize:18.0f],
                                                          NSForegroundColorAttributeName,nil]];
    if (IS_IOS7){
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
        [[UINavigationBar appearance] setBarTintColor:NAVI_COLOR];
    }else{
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
        [[UINavigationBar appearance] setBarStyle:UIBarStyleBlackTranslucent];
    }
    
}

- (void)initMainViewController {
    RMCustomNavViewController * leftMenuNav = [[RMCustomNavViewController alloc] initWithRootViewController:[[LeftMenuViewController alloc] init]];
    
    RMCustomNavViewController * rightMenuNav = [[RMCustomNavViewController alloc] initWithRootViewController:[[RightMenuViewController alloc] init]];
    
    RMCustomNavViewController * recommendedDailyNav = [[RMCustomNavViewController alloc] initWithRootViewController:[[RMRecommendedDailyViewController alloc] init]];
    
    RMCustomNavViewController * soHotListNav = [[RMCustomNavViewController alloc] initWithRootViewController:[[RMSoHotListViewController alloc] init]];
    
    RMCustomNavViewController * starNav = [[RMCustomNavViewController alloc] initWithRootViewController:[[RMStarViewController alloc] init]];
    
    RMCustomNavViewController * myChannelNav = [[RMCustomNavViewController alloc] initWithRootViewController:[[RMMyChannelViewController alloc] init]];
    
    NSArray * ctlsArr = [NSArray arrayWithObjects:recommendedDailyNav, soHotListNav, starNav, myChannelNav, nil];
    
    NSArray * normalImageArray;
    NSArray * selectedImageArray;
    
    if (IS_IPHONE_6_SCREEN){
        normalImageArray = [[NSArray alloc] initWithObjects:@"RecommendedDaily_black_6", @"SoHotList_black_6", @"Star_black_6", @"MyChannel_black_6", nil];
        
        selectedImageArray = [[NSArray alloc] initWithObjects:@"RecommendedDaily_red_6", @"SoHotList_red_6", @"Star_red_6", @"MyChannel_red_6", nil];
    }else if (IS_IPHONE_6p_SCREEN){
        normalImageArray = [[NSArray alloc] initWithObjects:@"RecommendedDaily_black_6p", @"SoHotList_black_6p", @"Star_black_6p", @"MyChannel_black_6p", nil];
        
        selectedImageArray = [[NSArray alloc] initWithObjects:@"RecommendedDaily_red_6p", @"SoHotList_red_6p", @"Star_red_6p", @"MyChannel_red_6p", nil];
    }else{
        normalImageArray = [[NSArray alloc] initWithObjects:@"RecommendedDaily_black", @"SoHotList_black", @"Star_black", @"MyChannel_black", nil];
        
        selectedImageArray = [[NSArray alloc] initWithObjects:@"RecommendedDaily_red", @"SoHotList_red", @"Star_red", @"MyChannel_red", nil];
    }

    
    HJMTabBar * customTab = [[HJMTabBar alloc] init];
    [customTab setTabWithArray:ctlsArr NormalImageArray:normalImageArray SelectedImageArray:selectedImageArray];

    _drawerController = [[MMDrawerController alloc]
                             initWithCenterViewController:customTab
                             leftDrawerViewController:leftMenuNav
                             rightDrawerViewController:rightMenuNav];
    [_drawerController setShowsShadow:NO];
    
    [_drawerController setMaximumRightDrawerWidth:200.0];
    [_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
    [_drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeNone];
     
    [self.drawerController
     setDrawerVisualStateBlock:^(MMDrawerController *drawerController, MMDrawerSide drawerSide, CGFloat percentVisible) {
         MMDrawerControllerDrawerVisualStateBlock block;
         block = [[MMExampleDrawerVisualStateManager sharedManager]
                  drawerVisualStateBlockForDrawerSide:drawerSide];
         if(block){
             block(drawerController, drawerSide, percentVisible);
         }
     }];
    
    [self.window setRootViewController:_drawerController];  
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

    /*
    //后台时，如果某些代码你不希望执行，可以加以下条件：
    UIApplication *application = [UIApplication sharedApplication];
    if( application.applicationState == UIApplicationStateBackground) {
        return;
    }
    */
    
    /*
    self.bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
        //10分钟后执行这里，应该进行一些清理工作，如断开和服务器的链接等...
        [application endBackgroundTask:self.bgTask];
        self.bgTask = UIBackgroundTaskInvalid;
    }];
    if (self.bgTask == UIBackgroundTaskInvalid){
        NSLog(@"faild to start backgroud task!");
    }
    
    // Start the long-running task and return immediately.
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    // Do the work associated with the task, preferably in chunks.
        NSTimeInterval timeRemain = 0;
        do{
        [NSThread sleepForTimeInterval:5];
            if (self.bgTask != UIBackgroundTaskInvalid) {
                timeRemain = [application backgroundTimeRemaining];
                NSLog(@"Time remaining: %f",timeRemain);
            }
        }while(self.bgTask != UIBackgroundTaskInvalid && timeRemain > 0);
        // 如果改为timeRemain > 5*60,表示后台运行5分钟
        // done!
        // 如果没到10分钟，也可以主动关闭后台任务，但这需要在主线程中执行，否则会出错
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.bgTask != UIBackgroundTaskInvalid)
            {
                // 和上面10分钟后执行的代码一样
                // ...
                // if you don't call endBackgroundTask, the OS will exit your app.
                [application endBackgroundTask:self.bgTask];
                self.bgTask = UIBackgroundTaskInvalid;
            }
        });
    });
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    // 如果没到10分钟又打开了app,结束后台任务
    /*
    if (self.bgTask!=UIBackgroundTaskInvalid) {
        [application endBackgroundTask:self.bgTask];
        self.bgTask = UIBackgroundTaskInvalid;
    }
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [application setApplicationIconBadgeNumber:0];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"beginPlayMovie" object:nil];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    [self beingBackgroundUpdateTask];
    // 在这里加上你需要长久运行的代码
    RMDownLoadingViewController *downLoading = [RMDownLoadingViewController shared];
    if(downLoading.dataArray.count>0){
        [downLoading saveData];
        NSData * data = [NSKeyedArchiver archivedDataWithRootObject:downLoading.dataArray];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:DownLoadDataArray_KEY];
    }else{
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:DownLoadDataArray_KEY];
        
    }
    [self endBackgroundUpdateTask];
}

#pragma mark- 社会化

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return  [UMSocialSnsService handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return  [UMSocialSnsService handleOpenURL:url];
}

#pragma mark- JPush

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Required
    [APService registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [application setApplicationIconBadgeNumber:0];
    // Required
    [APService handleRemoteNotification:userInfo];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    // IOS 7 Support Required
    [APService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}
- (void)beingBackgroundUpdateTask
{
    self.backgroundUpdateTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [self endBackgroundUpdateTask];
    }];
}

- (void)endBackgroundUpdateTask
{
    [[UIApplication sharedApplication] endBackgroundTask: self.backgroundUpdateTask];
    self.backgroundUpdateTask = UIBackgroundTaskInvalid;
}
@end
