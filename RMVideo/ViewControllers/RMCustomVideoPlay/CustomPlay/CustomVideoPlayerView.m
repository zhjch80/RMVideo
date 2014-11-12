//
//  CustomVideoPlayerView.m
//  LawtvApp
//
//  Created by Mac on 14-6-10.
//  Copyright (c) 2014年 Mac. All rights reserved.
//
#import "CustomVideoPlayerView.h"
#import "UtilityFunc.h"
#import "CustomSVProgressHUD.h"
#import "SVProgressHUD.h"

@interface CustomVideoPlayerView ()<TouchViewDelegate>

@end
static void *CustomVideoPlayerViewStatusObservationContext = &CustomVideoPlayerViewStatusObservationContext;
@implementation CustomVideoPlayerView
{
    id playbackObserver;
    BOOL viewIsShowing;
    BOOL isShowTVEpisode;
    int FastForwardOrRetreatQuickly; //电影若快进和快退时，标记当前的位置
    NSString *positionIdentifier; //判断当前是否是左右滑动
    CustomSVProgressHUD *customSVP;
}


//TODO:取消延迟方法，改延迟方法主要是隐藏导航栏和播放控制按钮的视图
- (void)CustomViewWillDisappear{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hiddenNavBarAndPlayerHudBottom) object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [self.playerItem removeObserver:self forKeyPath:@"status"];
    [self.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        customSVP = [[[NSBundle mainBundle] loadNibNamed:@"CustomSVProgressHUD" owner:self options:nil] lastObject];
        customSVP.frame = CGRectMake(([UtilityFunc shareInstance].globleHeight-customSVP.frame.size.width)/2, ([UtilityFunc shareInstance].globleWidth-customSVP.frame.size.height)/2, customSVP.frame.size.width, customSVP.frame.size.height);
    }
    return self;
}
- (void)contentURL:(NSURL *)contentURL
{
    
    [SVProgressHUD showWithStatus:@"加载中" maskType:SVProgressHUDMaskTypeBlack];
    if (self.playerItem) {
        //[self.playerItem removeObserver:self forKeyPath:@"status"];
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:AVPlayerItemDidPlayToEndTimeNotification
                                                      object:self.playerItem];
        [self.playerItem removeObserver:self forKeyPath:@"status"];
        [self.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];

    }
    self.playerItem = [AVPlayerItem playerItemWithURL:contentURL];
    self.moviePlayer = [AVPlayer playerWithPlayerItem:self.playerItem];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.moviePlayer];
    [self.playerLayer setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [self.moviePlayer seekToTime:kCMTimeZero];
    [self.layer addSublayer:self.playerLayer];
    self.contentURL = contentURL;
    
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];// 监听status属性
    [self.playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];// 监听loadedTimeRanges属性
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerFinishedPlaying) name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];

    [self initializePlayer:self.frame];
}

- (void)replaceCurrentItem
{
    [self pause];
    //释放播放资源
    [self.moviePlayer replaceCurrentItemWithPlayerItem:nil];
}

-(void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self.playerLayer setFrame:frame];
}


-(void)initializePlayer:(CGRect)frame
{    
    int frameWidth =  frame.size.width;
    
    self.backgroundColor = [UIColor blackColor];
    viewIsShowing =  NO;
    
    [self.layer setMasksToBounds:YES];
    self.playerHudBottom = [[UIView alloc] init];
    self.playerHudBottom.frame = CGRectMake(0, 0, [UtilityFunc shareInstance].globleAllHeight, [UtilityFunc shareInstance].globleAllHeight-([UtilityFunc shareInstance].globleWidth-49));
    [self.playerHudBottom setBackgroundColor:[UIColor colorWithRed:0.15 green:0.15 blue:0.15 alpha:0.4]];
    self.playerHudCenter.userInteractionEnabled = YES;
    [self addSubview:self.playerHudBottom];

    
    //Play 按钮
    self.playPauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.playPauseButton.frame = CGRectMake(10, 7, 35, 35);
    [self.playPauseButton addTarget:self action:@selector(playButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.playPauseButton setBackgroundImage:[UIImage imageNamed:@"pause"] forState:UIControlStateSelected];
    [self.playPauseButton setBackgroundImage:[UIImage imageNamed:@"play_btn"] forState:UIControlStateNormal];
    [self.playPauseButton setTintColor:[UIColor blueColor]];
    [self.playerHudBottom addSubview:self.playPauseButton];
    //下一集 按钮
    self.nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.nextButton.frame = CGRectMake(55, 7, 35, 35);
    [self.nextButton addTarget:self action:@selector(playNextButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.nextButton setBackgroundImage:[UIImage imageNamed:@"next_btn"] forState:UIControlStateNormal];
    [self.nextButton setTintColor:[UIColor blueColor]];
    [self.playerHudBottom addSubview:self.nextButton];
    //视频当前播放时间
    self.playBackTime = [[UILabel alloc] init];
    self.playBackTime.frame = CGRectMake(135-35, 10, 50, 30);
    self.playBackTime.text = [self getStringFromCMTime:self.moviePlayer.currentTime];
    [self.playBackTime setTextAlignment:NSTextAlignmentLeft];
    [self.playBackTime setTextColor:[UIColor whiteColor]];
    self.playBackTime.font = [UIFont systemFontOfSize:12*frameWidth/240];
    [self.playerHudBottom addSubview:self.playBackTime];
    //视频总的时间数
    self.playBackTotalTime = [[UILabel alloc] init];
    self.playBackTotalTime.frame = CGRectMake(frameWidth+140, 10, 50, 30);
    self.playBackTotalTime.text = [self getStringFromCMTime:self.moviePlayer.currentItem.asset.duration];
    [self.playBackTotalTime setTextAlignment:NSTextAlignmentRight];
    [self.playBackTotalTime setTextColor:[UIColor whiteColor]];
    self.playBackTotalTime.font = [UIFont systemFontOfSize:12*frameWidth/240];
    [self.playerHudBottom addSubview:self.playBackTotalTime];
    
    self.videoProgress = [[UIProgressView alloc] initWithFrame:CGRectMake(150, 25, frameWidth-10, 30)];
    [self.playerHudBottom addSubview:self.videoProgress];
    
    //跟踪电影播放的进度条
    self.progressBar = [[UISlider alloc] init];
    self.progressBar.frame = CGRectMake(145, 10, frameWidth, 30);
    //配置slider
    //左右滑轨
//    UIImage * leftTrackImage = [[UIImage imageFromMainBundleFile:@"glowStick_brightness_leftTrack.png"] stretchableImageWithLeftCapWidth:12 topCapHeight:5];
//    UIImage * rightTrackImage = [[UIImage imageFromMainBundleFile:@"glowStick_brightness_rightTrack.png"] stretchableImageWithLeftCapWidth:12 topCapHeight:5];
//    //滑块图片
//    UIImage * thumbImage = [UIImage imageFromMainBundleFile:@"glowStick_brightness_thumb.png"];

//    [self.progressBar setMinimumTrackImage:leftTrackImage forState:UIControlStateNormal];
//    [self.progressBar setMaximumTrackImage:rightTrackImage forState:UIControlStateNormal];
//    [self.progressBar setThumbImage:thumbImage forState:UIControlStateNormal];
//    [self.progressBar setThumbImage:thumbImage forState:UIControlStateHighlighted];
    
    [self.progressBar addTarget:self action:@selector(progressBarChanged:) forControlEvents:UIControlEventValueChanged];
    [self.playerHudBottom addSubview:self.progressBar];
    
    UIButton *selectEpisodeBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    selectEpisodeBtn.frame = CGRectMake(520, 5, 40, 40);
    [selectEpisodeBtn setTitle:@"选集" forState:UIControlStateNormal];
    [selectEpisodeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [selectEpisodeBtn addTarget:self action:@selector(selectTVEpisodebtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.playerHudBottom addSubview:selectEpisodeBtn];
    

    
    for (UIView *view in [self subviews]) {
        view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    
    CMTime interval = CMTimeMake(33, 1000);
    __weak __typeof(self) weakself = self;
//    if (playbackObserver) {
//        [self.moviePlayer removeTimeObserver:playbackObserver];
//    }
    playbackObserver = [self.moviePlayer addPeriodicTimeObserverForInterval:interval queue:dispatch_get_main_queue() usingBlock: ^(CMTime time) {
        CMTime endTime = CMTimeConvertScale (weakself.moviePlayer.currentItem.asset.duration, weakself.moviePlayer.currentTime.timescale, kCMTimeRoundingMethod_RoundHalfAwayFromZero);
        if (CMTimeCompare(endTime, kCMTimeZero) != 0) {
            double normalizedTime = (double) weakself.moviePlayer.currentTime.value / (double) endTime.value;
            weakself.progressBar.value = normalizedTime;
        }
        weakself.playBackTime.text = [weakself getStringFromCMTime:weakself.moviePlayer.currentTime];
    }];
    
    [self showHud:NO];
    
    //添有手势的视图
    self.touchView = [[TouchVIew alloc] initWithFrame:CGRectMake(0, 44, [UtilityFunc shareInstance].globleAllHeight, [UtilityFunc shareInstance].globleWidth-44-49)];
    self.touchView.delegate = self;
    [self addSubview:self.touchView];
    customSVP.hidden = YES;
    customSVP.totalTimeString = [self getStringFromCMTime:self.moviePlayer.currentItem.asset.duration];
    [self addSubview:customSVP];
    //隐藏屏幕导航栏和菜单栏
    [self performSelector:@selector(hiddenNavBarAndPlayerHudBottom) withObject:nil afterDelay:3];
}

//隐藏菜单栏并通知主视图隐藏导航
- (void)hiddenNavBarAndPlayerHudBottom{

    if([self.delegate respondsToSelector:@selector(playViewTouchesEnded)]){
        [self.delegate playViewTouchesEnded];
    }
    [self showHud:!viewIsShowing];
}

//弹出选集视图
- (void)selectTVEpisodebtnClick{
    __unsafe_unretained CustomVideoPlayerView *weekSelf = self;
    if(!isShowTVEpisode){
        [UIView animateWithDuration:0.3 animations:^{
            weekSelf.TVSelectEpisodeScrollView.frame =  CGRectMake([UtilityFunc shareInstance].globleAllHeight-150, 44, 150, [UtilityFunc shareInstance].globleWidth-44-49);
        }];
    }else{
        [UIView animateWithDuration:0.3 animations:^{
            weekSelf.TVSelectEpisodeScrollView.frame =  CGRectMake([UtilityFunc shareInstance].globleAllHeight, 44, 150, [UtilityFunc shareInstance].globleWidth-44-49);
        }];
    }
    isShowTVEpisode = !isShowTVEpisode;
    [self setHiddenView];
}
//跳转下一集
- (void)playNextButtonAction:(UIButton *)sender{
    
    NSString * str = @"http://220.181.185.11/youku/697756E8B683F82D76D2E461A1/030020010052A84E8B5217055EEB3E4DC7771E-B14F-EB8E-CB90-E28B72954460.mp4";
    NSURL * _URL = [NSURL URLWithString:str];
//    self.playerItem = nil;
//    [self.playerItem removeObserver:self forKeyPath:@"status"];
//    [self.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
//    
//    self.playerItem = [AVPlayerItem playerItemWithURL:_URL];
//    self.moviePlayer = [AVPlayer playerWithPlayerItem:self.playerItem];
//    self.playerLayer.player = self.moviePlayer;
//    
//    CMTime interval = CMTimeMake(33, 1000);
//    __weak __typeof(self) weakself = self;
//    playbackObserver = [self.moviePlayer addPeriodicTimeObserverForInterval:interval queue:dispatch_get_main_queue() usingBlock: ^(CMTime time) {
//        CMTime endTime = CMTimeConvertScale (weakself.moviePlayer.currentItem.asset.duration, weakself.moviePlayer.currentTime.timescale, kCMTimeRoundingMethod_RoundHalfAwayFromZero);
//        if (CMTimeCompare(endTime, kCMTimeZero) != 0) {
//            double normalizedTime = (double) weakself.moviePlayer.currentTime.value / (double) endTime.value;
//            weakself.progressBar.value = normalizedTime;
//        }
//        weakself.playBackTime.text = [weakself getStringFromCMTime:weakself.moviePlayer.currentTime];
//    }];
//    [self play];
//    [self setHiddenView];
    [SVProgressHUD showWithStatus:@"加载中" maskType:SVProgressHUDMaskTypeBlack];
    if (self.playerItem) {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:AVPlayerItemDidPlayToEndTimeNotification
                                                      object:self.playerItem];
        [self.playerItem removeObserver:self forKeyPath:@"status"];
        [self.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
        
    }
    self.playerItem = [AVPlayerItem playerItemWithURL:_URL];
    self.moviePlayer = [AVPlayer playerWithPlayerItem:self.playerItem];
    self.playerLayer.player = self.moviePlayer;
    self.contentURL = _URL;
    
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];// 监听status属性
    [self.playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];// 监听loadedTimeRanges属性
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerFinishedPlaying) name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
    [self play];
}
//设置选集的视图大小
- (void)setSelectionEpisodeScrollViewWithArray:(NSMutableArray *)tvArray{
    self.TVSelectEpisodeScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake([UtilityFunc shareInstance].globleAllHeight, 44, 150, [UtilityFunc shareInstance].globleWidth-44-49)];
    self.TVSelectEpisodeScrollView.alpha = 0.5;
    self.TVSelectEpisodeScrollView.backgroundColor = [UIColor colorWithRed:0.15 green:0.15 blue:0.15 alpha:0.7];
    int count = 0;
    if(tvArray.count%3==0){
        count = (int)tvArray.count/3;
    }
    else{
        count = (int)tvArray.count/3+1;
    }
    self.TVSelectEpisodeScrollView.contentSize = CGSizeMake(150, count*50);
    for(int i=0;i<tvArray.count;i++){
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button setTitle:[NSString stringWithFormat:@"%d",i+1] forState:UIControlStateNormal];
        button.frame = CGRectMake(i%3*50, i/3*50, 50, 50);
        button.tag = i+1;
        [button addTarget:self action:@selector(TVEpisodeBntClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.TVSelectEpisodeScrollView addSubview:button];
    }
    [self addSubview:self.TVSelectEpisodeScrollView];
}

//点击所选集数
- (void)TVEpisodeBntClick:(UIButton *)sender{
    [UIView animateWithDuration:0.3 animations:^{
        self.TVSelectEpisodeScrollView.frame =  CGRectMake([UtilityFunc shareInstance].globleAllHeight, 44, 150, [UtilityFunc shareInstance].globleWidth-44-49);
    }];
    isShowTVEpisode = NO;
    if([self.delegate respondsToSelector:@selector(selectTVEpisodeWithIndex:)]){
        [self.delegate selectTVEpisodeWithIndex:sender.tag];
    }
}
//全屏
-(void)zoomButtonPressed
{
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        
        self.isFullScreenMode = YES;
        int val = UIInterfaceOrientationLandscapeRight;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}

-(void)setIsFullScreenMode:(BOOL)isFullScreenMode
{
    _isFullScreenMode = isFullScreenMode;
    if (isFullScreenMode) {
        self.backgroundColor = [UIColor blackColor];
    } else {
        self.backgroundColor = [UIColor blackColor];
    }
}

-(void)playerFinishedPlaying
{
    [self.moviePlayer pause];
    [self.moviePlayer seekToTime:kCMTimeZero];
    [self.playPauseButton setSelected:NO];
    self.isPlaying = NO;
    if ([self.delegate respondsToSelector:@selector(playerFinishedPlayback:)]) {
        [self.delegate playerFinishedPlayback:self];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [self.playerItem removeObserver:self forKeyPath:@"status"];
    [self.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hiddenNavBarAndPlayerHudBottom) object:nil];
    if(viewIsShowing){
         [self performSelector:@selector(hiddenNavBarAndPlayerHudBottom) withObject:nil afterDelay:3];
    }
    CGPoint point = [(UITouch*)[touches anyObject] locationInView:self];
    if (CGRectContainsPoint(self.touchView.frame, point)) {
        if([self.delegate respondsToSelector:@selector(playViewTouchesEnded)]){
            [self.delegate playViewTouchesEnded];
        }
        [self showHud:!viewIsShowing];
        if(isShowTVEpisode){
            [UIView animateWithDuration:0.3 animations:^{
                self.TVSelectEpisodeScrollView.frame =  CGRectMake([UtilityFunc shareInstance].globleAllHeight, 44, 150, [UtilityFunc shareInstance].globleWidth-44-49);
            }];
            isShowTVEpisode = !isShowTVEpisode;
        }
            
    }
}

-(void) showHud:(BOOL)show
{
    __weak __typeof(self) weakself = self;
    if(show) {
        CGRect frame = self.playerHudBottom.frame;
        frame.origin.y = self.bounds.size.height;
        [UIView animateWithDuration:0.3 animations:^{
            weakself.playerHudBottom.frame = frame;
            //weakself.playPauseButton.layer.opacity = 0;
            viewIsShowing = show;
        }];
    } else {
        CGRect frame = self.playerHudBottom.frame;
        frame.origin.y = self.bounds.size.height-self.playerHudBottom.frame.size.height;
        [UIView animateWithDuration:0.3 animations:^{
            weakself.playerHudBottom.frame = frame;
            //weakself.playPauseButton.layer.opacity = 1;
            viewIsShowing = show;
        }];
    }
}

-(NSString*)getStringFromCMTime:(CMTime)time
{
    Float64 currentSeconds = CMTimeGetSeconds(time);
    int mins = currentSeconds/60.0;
    int secs = fmodf(currentSeconds, 60.0);
    NSString *minsString = mins < 10 ? [NSString stringWithFormat:@"0%d", mins] : [NSString stringWithFormat:@"%d", mins];
    NSString *secsString = secs < 10 ? [NSString stringWithFormat:@"0%d", secs] : [NSString stringWithFormat:@"%d", secs];
    return [NSString stringWithFormat:@"%@:%@", minsString, secsString];
}


//TODO:播放/暂停
-(void)playButtonAction:(UIButton*)sender
{
    if (self.isPlaying) {
        [self pause];
    } else {
        [self play];
    }
    [self setHiddenView];
}

//TODO:跟踪视频播放的进度条
-(void)progressBarChanged:(UISlider*)sender
{
    if (self.isPlaying) {
        [self.moviePlayer pause];
    }
    
    CMTime seekTime = CMTimeMakeWithSeconds(sender.value * (double)self.moviePlayer.currentItem.asset.duration.value/(double)self.moviePlayer.currentItem.asset.duration.timescale, self.moviePlayer.currentTime.timescale);
    [self.moviePlayer seekToTime:seekTime];
    
    [self performSelector:@selector(delayPlay) withObject:self afterDelay:0.1];
    [self setHiddenView];
}


- (void)delayPlay {
    [self play];
}

-(void)play
{
    [self.moviePlayer play];
    self.isPlaying = YES;
    [self.playPauseButton setSelected:YES];
}

-(void)pause
{
    [self.moviePlayer pause];
    self.isPlaying = NO;
    [self.playPauseButton setSelected:NO];
}
- (void)gestureRecognizerStateBegan{
    positionIdentifier = @"none";
    FastForwardOrRetreatQuickly = self.progressBar.value * (double)self.moviePlayer.currentItem.asset.duration.value/(double)self.moviePlayer.currentItem.asset.duration.timescale;
}
-(void)gestureRecognizerStateEnded{
    
    if([positionIdentifier isEqualToString:@"right"]||[positionIdentifier isEqualToString:@"left"]){
        CMTime seekTime = CMTimeMakeWithSeconds(FastForwardOrRetreatQuickly, self.moviePlayer.currentTime.timescale);
        [self.moviePlayer seekToTime:seekTime];
        [self performSelector:@selector(delayPlay) withObject:self afterDelay:0.1];
    }
    customSVP.hidden = YES;
}
//点击以及滑动视图（TouchView）的代理方法
- (void)touchInViewOfLocation:(float)space andDirection:(NSString *)direction slidingPosition:(NSString *)position{
    [self setHiddenView];
    if([direction isEqualToString:@"right"]){
        positionIdentifier = direction;
        NSLog(@"FastForwardOrRetreatQuickly:%d---%f---right",FastForwardOrRetreatQuickly,space);
        if(customSVP.hidden)
            customSVP.hidden = NO;
        if(self.isPlaying){
            [self pause];
        }
        BOOL isfastForward = NO;
        if(space>0)
            isfastForward = YES;
        [customSVP showWithState:isfastForward andNowTime:FastForwardOrRetreatQuickly];
        FastForwardOrRetreatQuickly = FastForwardOrRetreatQuickly - space;
        
    }else if([direction isEqualToString:@"left"]){
        positionIdentifier = direction;
        if(customSVP.hidden)
            customSVP.hidden = NO;
        if(self.isPlaying){
            [self pause];
        }
        BOOL isfastForward = NO;
        if(space>0)
            isfastForward = YES;
        [customSVP showWithState:isfastForward andNowTime:FastForwardOrRetreatQuickly];
        NSLog(@"FastForwardOrRetreatQuickly:%d---%f-----left",FastForwardOrRetreatQuickly,space);
        
        FastForwardOrRetreatQuickly = FastForwardOrRetreatQuickly -  space;
    }
    else if ([direction isEqualToString:@"down"]){
        
        if(!customSVP.hidden)
            customSVP.hidden = YES;
        
        //控制声音
        if([position isEqualToString:@"left"]){
            MPMusicPlayerController *mpc = [MPMusicPlayerController applicationMusicPlayer];
            float num = mpc.volume;
            num += space/100;
            mpc.volume = num;  //0.0~1.0
        }
        //控制屏幕亮度
        else if([position isEqualToString:@"right"]){
            float num =[UIScreen mainScreen].brightness;
            NSLog(@"num:%f",num);
            num += space/100;
            [UIScreen mainScreen].brightness = num;
        }
        [self setHiddenView];
        
    }
    else if ([direction isEqualToString:@"up"]){
        
        if(!customSVP.hidden)
            customSVP.hidden = YES;
        //控制声音
        if([position isEqualToString:@"left"]){
            MPMusicPlayerController *mpc = [MPMusicPlayerController applicationMusicPlayer];
            float num  = mpc.volume;
            num += space/100;
            mpc.volume = num;  //0.0~1.0
        }
        //控制屏幕亮度
        else if ([position isEqualToString:@"right"]){
            float num =[UIScreen mainScreen].brightness;
            NSLog(@"num:%f",num);
            num += space/100;
            [UIScreen mainScreen].brightness = num;
        }
        [self setHiddenView];
    }
}

//TODO:调整屏幕亮度
- (void)brightnessSliderWillChanged:(UISlider *)slider{
//    [UIScreen mainScreen].brightness = slider.value;
//    [self setHiddenView];
}

//延时，自动隐藏导航和菜单栏
- (void)setHiddenView{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hiddenNavBarAndPlayerHudBottom) object:nil];
    [self performSelector:@selector(hiddenNavBarAndPlayerHudBottom) withObject:nil afterDelay:3];
}

- (void)setAVPlayerWithTime:(int)time{
    
    if (self.isPlaying) {
        [self.moviePlayer pause];
    }
    
    CMTime seekTime = CMTimeMakeWithSeconds(time, self.moviePlayer.currentTime.timescale);
    [self.moviePlayer seekToTime:seekTime];
    
    [self performSelector:@selector(delayPlay) withObject:self afterDelay:0.1];
    [self setHiddenView];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    AVPlayerItem *playerItem = (AVPlayerItem *)object;

    if ([keyPath isEqualToString:@"status"]) {
        
        if ([playerItem status] == AVPlayerStatusReadyToPlay) {

            NSLog(@"AVPlayerStatusReadyToPlay");

//            self.playPauseButton.enabled = YES;
            [SVProgressHUD dismiss];

//            CMTime duration = self.playerItem.duration;// 获取视频总长度

//            CGFloat totalSecond = playerItem.duration.value / playerItem.duration.timescale;// 转换成秒

//            NSString *totalTime = [self convertTime:totalSecond];// 转换成播放时间

//            NSLog(@"movie total duration:%f",CMTimeGetSeconds(duration));

//            [self monitoringPlayback:self.playerItem];// 监听播放状态

        } else if ([playerItem status] == AVPlayerStatusFailed) {

            NSLog(@"AVPlayerStatusFailed");
            [SVProgressHUD showErrorWithStatus:@"加载失败"];


        }

    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {

        NSTimeInterval timeInterval = [self availableDuration];// 计算缓冲进度

//        NSLog(@"Time Interval:%f",timeInterval); 

        CMTime duration = self.playerItem.duration;

        CGFloat totalDuration = CMTimeGetSeconds(duration);
        [self customVideoSlider:duration];

        [self.videoProgress setProgress:timeInterval / totalDuration animated:YES];
//        NSLog(@"totalDuration:%f",totalDuration);

    }

}

- (NSTimeInterval)availableDuration {
    NSArray *loadedTimeRanges = [[self.playerLayer.player currentItem] loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}

- (NSString *)convertTime:(CGFloat)second{
    NSDate *d = [NSDate dateWithTimeIntervalSince1970:second];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if (second/3600 >= 1) {
        [formatter setDateFormat:@"HH:mm:ss"];
    } else {
        [formatter setDateFormat:@"mm:ss"];
    }
    NSString *showtimeNew = [formatter stringFromDate:d];
    return showtimeNew;
}
//- (void)monitoringPlayback:(AVPlayerItem *)playerItem {
//
////    __unsafe_unretained CustomVideoPlayerView *weekSelf = self;
////    [self.playerLayer.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time) {
////    
////        CGFloat currentSecond = playerItem.currentTime.value/playerItem.currentTime.timescale;// 计算当前在第几秒
////    
////        NSLog(@"currentSecond:%f",currentSecond);
////    
////        NSString *timeString = [weekSelf convertTime:currentSecond];
////    
////        NSLog(@"%@",[NSString stringWithFormat:@"%@",timeString]);
////    
////    }];
//    
//}

- (void)customVideoSlider:(CMTime)duration {
    
//    self.progressBar.maximumValue = CMTimeGetSeconds(duration);
    UIGraphicsBeginImageContextWithOptions((CGSize){ 1, 1 }, NO, 0.0f);
    UIImage *transparentImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self.progressBar setMinimumTrackImage:transparentImage forState:UIControlStateNormal];
    [self.progressBar setMaximumTrackImage:transparentImage forState:UIControlStateNormal];
}
@end
