//
//  CustomVideoPlayerController.h
//  LawtvApp
//
//  Created by Mac on 14-6-10.
//  Copyright (c) 2014年 Mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomVideoPlayerController : UIViewController
@property (nonatomic,copy) NSString *playURL;

- (void)createPlayerViewWithURL:(NSString *)url isPlayLocalVideo:(BOOL)isLocal;
- (void)createTopTool;

@end
