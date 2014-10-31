//
//  RMLoginViewController.m
//  RMVideo
//
//  Created by 润华联动 on 14-10-17.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMLoginViewController.h"

@interface RMLoginViewController ()

@end
@implementation RMLoginViewController
static id _instance;
/*
 永远只分配一块内存来创建对象
 提供一个类方法，返回内部唯一的一个变量
 最好保证init方法也只初创化一次
 */

//构造方法
- (id)init {
    static id obj=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ((obj=[super init]) != nil) {
            //code ...
            
            
        }
    });
    self=obj;

    return self;
}

+ (id)alloc {
    return [super alloc];
}

//重写该方法，控制内存的分配，永远只分配一次存储空间
+ (id)allocWithZone:(struct _NSZone *)zone {
    //里面的代码只会执行一次
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance=[super allocWithZone:zone];
    });
    return _instance;
}

//类方法 里面的代码永远都只执行一次
+ (instancetype)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance=[[self alloc]init];
    });
    return _instance;
}

+ (id)copyWithZone:(struct _NSZone *)zone {
    return _instance;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setTitle:@"登录"];
    
    leftBarButton.hidden = YES;
    [rightBarButton setTitle:@"取消" forState:UIControlStateNormal];
    [rightBarButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    rightBarButton.frame = CGRectMake(0, 0, 60, 30);
    rightBarButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    
    
    
    
    
}

- (void)navgationBarButtonClick:(UIBarButtonItem *)sender {
    switch (sender.tag) {
        case 1:{
        
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
