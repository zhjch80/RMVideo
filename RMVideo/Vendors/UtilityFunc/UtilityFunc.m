//
//  UtilityFunc.m
//  RMVideo
//
//  Created by runmobile on 14-9-29.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "UtilityFunc.h"
#import "Reachability.h"

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

@implementation UtilityFunc
@synthesize globleWidth, globleHeight, globleAllHeight,dic,isAudio;

+ (UtilityFunc *)shareInstance {
    static UtilityFunc *__singletion;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __singletion=[[self alloc] init];
    });
    return __singletion;
}


// 是否4英寸屏幕
+ (BOOL)is4InchScreen {
    static BOOL bIs4Inch = NO;
    static BOOL bIsGetValue = NO;
    
    if (!bIsGetValue)
    {
        CGRect rcAppFrame = [UIScreen mainScreen].bounds;
        bIs4Inch = (rcAppFrame.size.height == 568.0f);
        
        bIsGetValue = YES;
    }else{}
    
    return bIs4Inch;
}

//检查网络链接是否可用
+ (NSInteger)isConnectionAvailable {
    NSInteger isNet = 0;
    Reachability * reach = [Reachability reachabilityWithHostname:@"www.baidu.com"];
    switch ([reach currentReachabilityStatus]) {
        case NotReachable:
            isNet = 0;
            break;
        case ReachableViaWWAN:
            isNet = 1;
            break;
        case ReachableViaWiFi:
            isNet = 2;
            break;
        default:
            break;
    }
    return isNet;
}

+ (UIColor *)colorWithHexString:(NSString *)hexString {
    return [[self class] colorWithHexString:hexString alpha:1.0];
}

+ (UIColor *)colorWithHexString:(NSString *)hexString alpha:(CGFloat)alpha {
    // Check for hash and add the missing hash
    if('#' != [hexString characterAtIndex:0])
    {
        hexString = [NSString stringWithFormat:@"#%@", hexString];
    }
    
    // check for string length
    assert(7 == hexString.length || 4 == hexString.length);
    
    // check for 3 character HexStrings
    hexString = [[self class] hexStringTransformFromThreeCharacters:hexString];
    
    NSString *redHex    = [NSString stringWithFormat:@"0x%@", [hexString substringWithRange:NSMakeRange(1, 2)]];
    unsigned redInt = [[self class] hexValueToUnsigned:redHex];
    
    NSString *greenHex  = [NSString stringWithFormat:@"0x%@", [hexString substringWithRange:NSMakeRange(3, 2)]];
    unsigned greenInt = [[self class] hexValueToUnsigned:greenHex];
    
    NSString *blueHex   = [NSString stringWithFormat:@"0x%@", [hexString substringWithRange:NSMakeRange(5, 2)]];
    unsigned blueInt = [[self class] hexValueToUnsigned:blueHex];
    
    UIColor *color = [UtilityFunc colorWith8BitRed:redInt green:greenInt blue:blueInt alpha:alpha];
    
    return color;
}

+ (UIColor *)colorWith8BitRed:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue {
    return [[self class] colorWith8BitRed:red green:green blue:blue alpha:1.0];
}

+ (UIColor *)colorWith8BitRed:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue alpha:(CGFloat)alpha {
    UIColor *color = nil;
#if (TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE)
    color = [UIColor colorWithRed:(float)red/255 green:(float)green/255 blue:(float)blue/255 alpha:alpha];
#else
    color = [UIColor colorWithCalibratedRed:(float)red/255 green:(float)green/255 blue:(float)blue/255 alpha:alpha];
#endif
    
    return color;
}

+ (NSString *)hexStringTransformFromThreeCharacters:(NSString *)hexString {
    if(hexString.length == 4)
    {
        hexString = [NSString stringWithFormat:@"#%@%@%@%@%@%@",
                     [hexString substringWithRange:NSMakeRange(1, 1)],[hexString substringWithRange:NSMakeRange(1, 1)],
                     [hexString substringWithRange:NSMakeRange(2, 1)],[hexString substringWithRange:NSMakeRange(2, 1)],
                     [hexString substringWithRange:NSMakeRange(3, 1)],[hexString substringWithRange:NSMakeRange(3, 1)]];
    }
    
    return hexString;
}

+ (unsigned)hexValueToUnsigned:(NSString *)hexValue {
    unsigned value = 0;
    
    NSScanner *hexValueScanner = [NSScanner scannerWithString:hexValue];
    [hexValueScanner scanHexInt:&value];
    
    return value;
}

+ (CGSize)boundingRectWithSize:(CGSize)size font:(UIFont*)font text:(NSString*)text {
    CGSize resultSize;
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        resultSize = [text sizeWithFont:font
                      constrainedToSize:size
                          lineBreakMode:NSLineBreakByTruncatingTail];
    } else {
        NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
        CGRect rect = [text boundingRectWithSize:size
                                         options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                      attributes:attrs
                                         context:nil];
        resultSize = rect.size;
        resultSize = CGSizeMake(ceil(resultSize.width), ceil(resultSize.height));
    }
    return resultSize;
}

+ (UIView *)rotatingView:(UIView *)view {
    CGAffineTransform transform = view.transform;
    transform =  CGAffineTransformRotate(transform, (- M_PI / 4.0));
    view.transform = transform;
    return view;
}

/**
 *
 *  返回缓存图片的本地路径
 *
 */
+ (NSString *)localImageCachesPath {
    return [NSString stringWithFormat:@"%@/DBImageView", NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0]];
}

/**
 *
 * 计算该路径下文件大小 返回单位为M
 *
 */
//+ (CGFloat) fileSizeAtPath:(NSString*) filePath{
//    NSFileManager* manager = [NSFileManager defaultManager];
//    if ([manager fileExistsAtPath:filePath]){
//        return ([[manager attributesOfItemAtPath:filePath error:nil] fileSize])/1024.0;
//    }
//    return 0;
//}

/**
 *
 *  返回总共硬盘大小 返回单位是bt
 *
 */
+ (NSNumber *)totalDiskSpace {
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    return [fattributes objectForKey:NSFileSystemSize];
}

/**
 *
 *  返回硬盘剩余大小 返回单位是bt
 *
 */
+ (NSNumber *) freeDiskSpace {
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    return [fattributes objectForKey:NSFileSystemFreeSize];
}

//这个方法不能用了  需要把6 6+ 得判断加上
+ (UIDeviceResolution) currentResolution {
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        if ([[UIScreen mainScreen] respondsToSelector: @selector(scale)]) {
            CGSize result = [[UIScreen mainScreen] bounds].size;
            result = CGSizeMake(result.width * [UIScreen mainScreen].scale, result.height * [UIScreen mainScreen].scale);
            return (result.height == 960 ? UIDevice_iPhoneHiRes : UIDevice_iPhoneTallerHiRes);
        } else
            return UIDevice_iPhoneStandardRes;
    } else
        return (([[UIScreen mainScreen] respondsToSelector: @selector(scale)]) ? UIDevice_iPadHiRes : UIDevice_iPadStandardRes);
}

//单个文件的大小
+ (float) fileSizeAtPath:(NSString*) filePath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize]/2048.0/1024.0;
    }
    return 0;
}
//遍历文件夹获得文件夹大小，返回多少M
+ (float ) folderSizeAtPath:(NSString*) folderPath{
    
    NSFileManager* fileManeger = [NSFileManager defaultManager];
    NSError *error;
    NSArray *array = [fileManeger contentsOfDirectoryAtPath:folderPath error:&error];
    float sum = 0;
    for(NSString *string in array){
        sum = sum + [self fileSizeAtPath:[NSString stringWithFormat:@"%@/%@",folderPath,string]];
    }
    return sum;
}

@end
