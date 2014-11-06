//
//  DAAutoScrollView.h
//  DAAutoScroll
//
//  Created by Daniel Amitay on 2/13/12.
//  Copyright (c) 2012 Daniel Amitay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DAAutoScrollView : UIScrollView {
    NSTimer *_scrollTimer;
}
/*
 *  每秒移动的距离
 */
@property (nonatomic) CGFloat pointsPerSecond;

/**
 *  开始循环
 */
- (void)startScrolling;

/**
 *  停止循环
 */
- (void)stopScrolling;

/**
 *  加载文字到循环滚动View上
 *  @param  str         加载的文字
 *  @param  color       加载字的颜色
 *  @param  alignment   样式
 */
- (void)loadTextViewWithString:(NSString *)str WithTextFont:(UIFont *)font WithTextColor:(UIColor *)color WithTextAlignment:(NSTextAlignment)alignment WithSetupLabelCenterPoint:(BOOL)isSetup WithTextOffset:(NSInteger)offset;

/*
 如果要交互 必须实现的方法
 - (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
 if (!decelerate) {
 for (int i=0; i<20; i++){
 [(DAAutoScrollView *)[self.view viewWithTag:i + 101] startScrolling];
 }
 }
 }
 
 - (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
 for (int i=0; i<20; i++){
 [(DAAutoScrollView *)[self.view viewWithTag:i + 101] startScrolling];
 }
 }

 */

@end
