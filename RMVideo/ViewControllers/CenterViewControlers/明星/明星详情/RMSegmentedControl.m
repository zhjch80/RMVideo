//
//  HMSegmentedControl.m
//  HMSegmentedControlExample
//
//  Created by Hesham Abd-Elmegid on 23/12/12.
//  Copyright (c) 2012 Hesham Abd-Elmegid. All rights reserved.
//

#import "RMSegmentedControl.h"
#import <QuartzCore/QuartzCore.h>

#define kIndicatorHeight                38.0
#define XiaHuaXianHight                     0.0f

@interface RMSegmentedControl (){
    NSArray * normalArr;
    NSArray * selectArr;
}

@property (nonatomic, strong) CALayer *selectedSegmentLayer;
@property (nonatomic, readwrite) CGFloat segmentWidth;

@end

@implementation RMSegmentedControl
@synthesize identifierType = _identifierType;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    if (self) {
        [self setDefaults];
    }
    
    return self;
}

- (id)initWithSectionTitles:(NSArray *)sectiontitles withIdentifierType:(NSString *)str {
    self = [super initWithFrame:CGRectZero];
    
    if (self) {
        self.sectionTitles = sectiontitles;
        self.identifierType = str;
        [self setDefaultsLabelTitle];
        [self setDefaults];
    }
    
    return self;
}

- (void)setDefaults {
    self.font = [UIFont fontWithName:@"STHeitiSC-Light" size:18.0f];
    self.textColor = [UIColor blackColor];
    self.backgroundColor = [UIColor whiteColor];
    self.selectionIndicatorColor = [UIColor colorWithRed:52.0f/255.0f green:181.0f/255.0f blue:229.0f/255.0f alpha:1.0f];
    
    self.selectedIndex = 0;
    self.segmentEdgeInset = UIEdgeInsetsMake(0, 5, 0, 5);
    self.height = 32.0f;
    self.selectionIndicatorHeight = XiaHuaXianHight;
    self.selectionIndicatorMode = HMSelectionIndicatorFillsSegment;
    
    self.selectedSegmentLayer = [CALayer layer];
}

-(void)setDefaultsLabelTitle{
    float screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    NSString * name_1 = [NSString stringWithFormat:@"%@",[self.sectionTitles objectAtIndex:0]]; //电影
    NSString * name_2 = [NSString stringWithFormat:@"%@",[self.sectionTitles objectAtIndex:1]]; //电视剧
    NSString * name_3 = [NSString stringWithFormat:@"%@",[self.sectionTitles objectAtIndex:2]]; //综艺

    NSMutableArray * nameArr = [NSMutableArray arrayWithObjects:@"电影", @"电视剧", @"综艺", nil];

    int count = [self.sectionTitles count];
    if (name_1.length == 0){
        for (int i=0; i<[nameArr count]; i++){
            if ([[nameArr objectAtIndex:i] isEqualToString:@"电影"]) {
                [nameArr removeObjectAtIndex:i];
                count --;
            }
        }
    }
    if (name_2.length == 0){
        for (int i=0; i<[nameArr count]; i++){
            if ([[nameArr objectAtIndex:i] isEqualToString:@"电视剧"]) {
                [nameArr removeObjectAtIndex:i];
                count --;
            }
        }
    }
    if (name_3.length == 0){
        for (int i=0; i<[nameArr count]; i++){
            if ([[nameArr objectAtIndex:i] isEqualToString:@"综艺"]) {
                [nameArr removeObjectAtIndex:i];
                count --;
            }
        }
    }
    
    float MARGIN = 0.0;
    float subMARGIN = 0.0;

    if (count == 1){
        MARGIN = 2.0;
        subMARGIN = 4.0;
    }else if (count == 2){
        MARGIN = 3.0;
    }else if (count == 3){
        MARGIN = 2.5;
    }

    UIView * bgView = [[UIView alloc] init];
    bgView.backgroundColor = [UIColor colorWithRed:0.94 green:0.93 blue:0.93 alpha:1];
    bgView.frame = CGRectMake(20, 5, screenWidth - 40, 35);

    [self addSubview:bgView];
    
    CAShapeLayer *shapeLayer;
    
    //border definitions
    CGFloat cornerRadius = 8;
    CGFloat borderWidth = 1;
    UIColor *lineColor = [UIColor whiteColor];
    
    //drawing
    CGRect frame = bgView.bounds;
    
    //creating a path
    CGMutablePathRef path = CGPathCreateMutable();
    
    //drawing a border around a view
    CGPathMoveToPoint(path, NULL, 0, frame.size.height - cornerRadius);
    CGPathAddLineToPoint(path, NULL, 0, cornerRadius);
    CGPathAddArc(path, NULL, cornerRadius, cornerRadius, cornerRadius, M_PI, -M_PI_2, NO);
    CGPathAddLineToPoint(path, NULL, frame.size.width - cornerRadius, 0);
    CGPathAddArc(path, NULL, frame.size.width - cornerRadius, cornerRadius, cornerRadius, -M_PI_2, 0, NO);
    CGPathAddLineToPoint(path, NULL, frame.size.width, frame.size.height - cornerRadius);
    CGPathAddArc(path, NULL, frame.size.width - cornerRadius, frame.size.height - cornerRadius, cornerRadius, 0, M_PI_2, NO);
    CGPathAddLineToPoint(path, NULL, cornerRadius, frame.size.height);
    CGPathAddArc(path, NULL, cornerRadius, frame.size.height - cornerRadius, cornerRadius, M_PI_2, M_PI, NO);
    
    //path is set as the _shapeLayer object's path
    shapeLayer.path = path;
    CGPathRelease(path);
    
    shapeLayer.backgroundColor = [[UIColor clearColor] CGColor];
    shapeLayer.frame = frame;
    shapeLayer.masksToBounds = NO;
    [shapeLayer setValue:[NSNumber numberWithBool:NO] forKey:@"isCircle"];
    shapeLayer.fillColor = [[UIColor clearColor] CGColor];
    shapeLayer.strokeColor = [lineColor CGColor];
    shapeLayer.lineWidth = borderWidth;
    shapeLayer.lineDashPattern = [NSArray arrayWithObjects:[NSNumber numberWithInt:1], nil];
    shapeLayer.lineCap = kCALineCapRound;
    
    //_shapeLayer is added as a sublayer of the view
    [bgView.layer addSublayer:shapeLayer];
    bgView.layer.cornerRadius = cornerRadius;

    for (int i=0; i<count; i++){
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(MARGIN + i * ((screenWidth - 50)/count) + i*MARGIN, 2, (screenWidth - 48)/count + subMARGIN, 31);
        button.tag = 100+i;
        [button setTitle:[nameArr objectAtIndex:i] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(switchSelected:) forControlEvents:UIControlEventTouchUpInside];
        button.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [bgView addSubview:button];
        
        if (self.selectedIndex == i){
            button.backgroundColor = [UIColor colorWithRed:0.94 green:0.93 blue:0.93 alpha:1];
            [button setTitleColor:[UIColor colorWithRed:0.96 green:0.3 blue:0.29 alpha:1] forState:UIControlStateNormal];
        }else{
            button.backgroundColor = [UIColor colorWithRed:0.15 green:0.15 blue:0.15 alpha:1];
            [button setTitleColor:[UIColor colorWithRed:0.94 green:0.93 blue:0.93 alpha:1] forState:UIControlStateNormal];
        }
        
        if (i == 0){
            UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:button.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft cornerRadii:CGSizeMake(8, 8)];
            CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
            maskLayer.frame = button.bounds;
            maskLayer.path = maskPath.CGPath;
            button.layer.mask = maskLayer;
        }
        
        if (i == count-1){
            UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:button.bounds byRoundingCorners:UIRectCornerTopRight | UIRectCornerBottomRight cornerRadii:CGSizeMake(8, 8)];
            CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
            maskLayer.frame = button.bounds;
            maskLayer.path = maskPath.CGPath;
            button.layer.mask = maskLayer;
        }
        
        if (count == 1){
            UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:button.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft | UIRectCornerTopRight | UIRectCornerBottomRight cornerRadii:CGSizeMake(8, 8)];
            CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
            maskLayer.frame = button.bounds;
            maskLayer.path = maskPath.CGPath;
            button.layer.mask = maskLayer;
        }
    }
}

- (void)switchSelected:(UIButton *)sender{
    for (int i=100; i<103; i++){
        UIButton * button = (UIButton *)[self viewWithTag:i];
        button.backgroundColor = [UIColor colorWithRed:0.15 green:0.15 blue:0.15 alpha:1];
        [button setTitleColor:[UIColor colorWithRed:0.94 green:0.93 blue:0.93 alpha:1] forState:UIControlStateNormal];
    }
    sender.backgroundColor = [UIColor colorWithRed:0.94 green:0.93 blue:0.93 alpha:1];
    [sender setTitleColor:[UIColor colorWithRed:0.96 green:0.3 blue:0.29 alpha:1] forState:UIControlStateNormal];
    if ([self.delegate respondsToSelector:@selector(switchSelectedMethodWithValue:withTitle:)]){
        [self.delegate switchSelectedMethodWithValue:sender.tag-100 withTitle:sender.titleLabel.text];
    }
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
    [self.backgroundColor set];
    UIRectFill([self bounds]);
    
    [self.textColor set];
    
    [self.sectionTitles enumerateObjectsUsingBlock:^(id titleString, NSUInteger idx, BOOL *stop) {
        CGFloat stringHeight = [titleString sizeWithFont:self.font].height;
        CGFloat y = ((self.height - self.selectionIndicatorHeight) / 2) + (self.selectionIndicatorHeight - stringHeight / 2);
        CGRect rect = CGRectMake(self.segmentWidth * idx, y, self.segmentWidth, stringHeight);
        
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
        [titleString drawInRect:rect
                       withFont:self.font
                  lineBreakMode:UILineBreakModeClip
                      alignment:UITextAlignmentCenter];
#else
        [titleString drawInRect:rect
                       withFont:self.font
                  lineBreakMode:NSLineBreakByClipping
                      alignment:NSTextAlignmentCenter];
#endif

        self.selectedSegmentLayer.frame = [self frameForSelectionIndicator];
        self.selectedSegmentLayer.backgroundColor = self.selectionIndicatorColor.CGColor;
        [self.layer addSublayer:self.selectedSegmentLayer];

    }];
}

- (CGRect)frameForSelectionIndicator {
    CGFloat stringWidth = [[self.sectionTitles objectAtIndex:self.selectedIndex] sizeWithFont:self.font].width;
    
    if (self.selectionIndicatorMode == HMSelectionIndicatorResizesToStringWidth) {
        CGFloat widthTillEndOfSelectedIndex = (self.segmentWidth * self.selectedIndex) + self.segmentWidth;
        CGFloat widthTillBeforeSelectedIndex = (self.segmentWidth * self.selectedIndex);
        
        CGFloat x = ((widthTillEndOfSelectedIndex - widthTillBeforeSelectedIndex) / 2) + (widthTillBeforeSelectedIndex - stringWidth / 2);
        return CGRectMake(x, kIndicatorHeight, stringWidth, self.selectionIndicatorHeight);
    } else {
        return CGRectMake(self.segmentWidth * self.selectedIndex, kIndicatorHeight, self.segmentWidth, self.selectionIndicatorHeight);
    }
}

- (void)updateSegmentsRects {
    // If there's no frame set, calculate the width of the control based on the number of segments and their size
    if (CGRectIsEmpty(self.frame)) {
        self.segmentWidth = 0;
        
        for (NSString *titleString in self.sectionTitles) {
            CGSize resultSize;
            NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:self.font, NSFontAttributeName, nil];
            CGRect rect = [titleString boundingRectWithSize:CGSizeMake(500, 500)
                                               options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                            attributes:attrs
                                               context:nil];
            resultSize = rect.size;
            resultSize = CGSizeMake(ceil(resultSize.width), ceil(resultSize.height));
//            CGFloat stringWidth = [titleString sizeWithFont:self.font].width + self.segmentEdgeInset.left + self.segmentEdgeInset.right;
            CGFloat stringWidth = resultSize.width + self.segmentEdgeInset.left + self.segmentEdgeInset.right;
            self.segmentWidth = MAX(stringWidth, self.segmentWidth);
        }
        
        self.bounds = CGRectMake(0, 0, self.segmentWidth * self.sectionTitles.count, self.height);
    } else {
        self.segmentWidth = self.frame.size.width / self.sectionTitles.count;
        self.height = self.frame.size.height;
    }
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    // Control is being removed
    if (newSuperview == nil)
        return;
    
    [self updateSegmentsRects];
}

#pragma mark - Touch

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:self];
    
    if (CGRectContainsPoint(self.bounds, touchLocation)) {
        NSInteger segment = touchLocation.x / self.segmentWidth;
        
        if (segment != self.selectedIndex) {
            [self setSelectedIndex:segment animated:YES];
        }
    }
}

#pragma mark -

- (void)setSelectedIndex:(NSInteger)index {
    [self setSelectedIndex:index animated:NO];
}

- (void)setSelectedIndex:(NSUInteger)index animated:(BOOL)animated {
    _selectedIndex = index;
    
    if (animated) {
        // Restore CALayer animations
        self.selectedSegmentLayer.actions = nil;
        
        [CATransaction begin];
        [CATransaction setAnimationDuration:0.15f];
        [CATransaction setCompletionBlock:^{
            if (self.superview)
                [self sendActionsForControlEvents:UIControlEventValueChanged];
            
            if (self.indexChangeBlock)
                self.indexChangeBlock(index);
        }];
        self.selectedSegmentLayer.frame = [self frameForSelectionIndicator];
        [CATransaction commit];
    } else {
        // Disable CALayer animations
        NSMutableDictionary *newActions = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNull null], @"position", [NSNull null], @"bounds", nil];
        self.selectedSegmentLayer.actions = newActions;
        
        self.selectedSegmentLayer.frame = [self frameForSelectionIndicator];
        
        if (self.superview)
            [self sendActionsForControlEvents:UIControlEventValueChanged];
        
        if (self.indexChangeBlock)
            self.indexChangeBlock(index);

    }    
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    if (self.sectionTitles)
        [self updateSegmentsRects];
    
    [self setNeedsDisplay];
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    
    if (self.sectionTitles)
        [self updateSegmentsRects];
    
    [self setNeedsDisplay];
}

@end
