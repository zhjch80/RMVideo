//
//  RMLoginViewController.h
//  RMVideo
//
//  Created by 润华联动 on 14-10-17.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMBaseViewController.h"

typedef enum{
    usingSinaLogin = 1,
    usingTencentLogin
    
} LoginType;

@interface RMLoginViewController : RMBaseViewController{
    LoginType loginType;
}
@property (weak, nonatomic) IBOutlet UILabel *lableTitle;

@end
