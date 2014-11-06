//
//  DAAutoScrollView.m
//  DAAutoScroll
//
//  Created by Daniel Amitay on 2/13/12.
//  Copyright (c) 2012 Daniel Amitay. All rights reserved.
//

#import "DAAutoScrollView.h"

#define Margins     0

@implementation DAAutoScrollView

@synthesize pointsPerSecond = _pointsPerSecond;

- (void)loadTextViewWithString:(NSString *)str WithTextFont:(UIFont *)font WithTextColor:(UIColor *)color WithTextAlignment:(NSTextAlignment)alignment WithSetupLabelCenterPoint:(BOOL)isSetup WithTextOffset:(NSInteger)offset {
    self.userInteractionEnabled = NO;
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(Margins, 0, 0, 18)];
    label.numberOfLines = 1;
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = alignment;
    label.font = font;
    label.textColor = color;
    label.text = str;
    [self addSubview:label];
    [label sizeToFit];
    self.contentSize = CGSizeMake(label.frame.size.width, 25);
    if (label.frame.size.width > self.frame.size.width){
    }else{
        if (isSetup){
            label.center = CGPointMake(self.frame.size.width/2 + offset, 9);
        }else{
        }
    }
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    if(newWindow) {
        [self.panGestureRecognizer addTarget:self action:@selector(gestureDidChange:)];
        [self.pinchGestureRecognizer addTarget:self action:@selector(gestureDidChange:)];
    }else{
        [self stopScrolling];
        [self.panGestureRecognizer removeTarget:self action:@selector(gestureDidChange:)];
        [self.pinchGestureRecognizer removeTarget:self action:@selector(gestureDidChange:)];
    }
}

#pragma mark - Touch methods

- (BOOL)touchesShouldBegin:(NSSet *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view {
    [self stopScrolling];
    return [super touchesShouldBegin:touches withEvent:event inContentView:view];
}

- (void)gestureDidChange:(UIGestureRecognizer *)gesture {
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan: {
            [self stopScrolling];
        }
            break;
        default:
            break;
    }
}

- (BOOL)becomeFirstResponder {
    [self stopScrolling];
    return [super becomeFirstResponder];
}

#pragma mark - Property methods

- (CGFloat)pointsPerSecond {
    if (!_pointsPerSecond) {
        _pointsPerSecond = 3.0f;
    }
    return _pointsPerSecond;
}

#pragma mark - Public methods

- (void)startScrolling {
    [self stopScrolling];
    
    CGFloat animationDuration = (0.5f / self.pointsPerSecond);
    _scrollTimer = [NSTimer scheduledTimerWithTimeInterval:animationDuration
                                                    target:self
                                                  selector:@selector(updateScroll)
                                                  userInfo:nil
                                                   repeats:YES];
}

- (void)stopScrolling {
    [_scrollTimer invalidate];
    _scrollTimer = nil;
}

- (void)updateScroll {
    CGFloat animationDuration = _scrollTimer.timeInterval;
    CGFloat pointChange = self.pointsPerSecond * animationDuration;
    CGPoint newOffset = self.contentOffset;
    newOffset.x = newOffset.x + pointChange;
    
    if (newOffset.x > (self.contentSize.width - self.bounds.size.width + 2*Margins)) {
        [UIView animateWithDuration:0.44 animations:^{
            self.contentOffset =CGPointMake(0, 0);
        }];
        [self startScrolling];
    }else{
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:animationDuration];
        self.contentOffset = newOffset;
        [UIView commitAnimations];
    }
}

@end
