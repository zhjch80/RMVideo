//
//  AOTag.m
//  AOTagDemo
//
//  Created by Loïc GRIFFIE on 16/09/13.
//  Copyright (c) 2013 Appsido. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "AOTagList.h"
#import "UtilityFunc.h"

#define tagFontSize         18
#define tagFontType         @"Helvetica-Light"
#define tagMargin           15.0f
#define tagHeight           25.0f
#define tagCornerRadius     3.0f
#define tagCloseButton      7.0f

@implementation AOTagList

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setBackgroundColor:[UIColor clearColor]];
        [self setUserInteractionEnabled:YES];
        
        self.tags = [NSMutableArray array];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    int n = 0;
    float x = 40.0f;
    float y = 0.0f;
    
    for (id v in [self subviews])
        if ([v isKindOfClass:[AOTag class]])
            [v removeFromSuperview];
    
    for (AOTag *tag in self.tags)
    {
        if (x + [tag getTagSize].width + tagMargin > self.frame.size.width) {
            n = 0;
            x = 40.0;
            y += [tag getTagSize].height + tagMargin;
        }
        else{
            x += (n ? tagMargin : 0.0f);
        }
        
        [tag setFrame:CGRectMake(x-10, y, [tag getTagSize].width, [tag getTagSize].height)];
        [self addSubview:tag];
        
        x += [tag getTagSize].width;
        
        n++;
    }
    
    CGRect r = [self frame];
    r.size.height = y + tagHeight + 30;
    [self setFrame:r];
    [self.heightDelegate clickChangeBtnWithTagListHeight:self.frame.size.height];
}

- (AOTag *)generateTagWithLabel:(NSString *)tTitle withImage:(NSString *)tImage
{
    AOTag *tag = [[AOTag alloc] initWithFrame:CGRectZero];
    
    [tag setDelegate:self.delegate];
    [tag setTImage:[UIImage imageNamed:tImage]];
    [tag setTTitle:tTitle];
    
    [self.tags addObject:tag];
    
    return tag;
}

- (void)addTag:(NSString *)tTitle withImage:(NSString *)tImage
{
    [self generateTagWithLabel:(tTitle ? tTitle : @"") withImage:(tImage ? tImage : @"")];
    
    [self setNeedsDisplay];
}

- (void)addTag:(NSString *)tTitle withImageURL:(NSURL *)imageURL andImagePlaceholder:(NSString *)tPlaceholderImage
{
    AOTag *tag = [self generateTagWithLabel:(tTitle ? tTitle : @"") withImage:(tPlaceholderImage ? tPlaceholderImage : @"")];
    [tag setTURL:imageURL];
    
    [self setNeedsDisplay];
}

- (void)addTag:(NSString *)tTitle
     withImage:(NSString *)tImage
withLabelColor:(UIColor *)labelColor
withBackgroundColor:(UIColor *)backgroundColor
withCloseButtonColor:(UIColor *)closeColor
{
    AOTag *tag = [self generateTagWithLabel:(tTitle ? tTitle : @"") withImage:(tImage ? tImage : @"")];
    
    if (labelColor) [tag setTLabelColor:labelColor];
    if (backgroundColor) [tag setTBackgroundColor:backgroundColor];
    if (closeColor) [tag setTCloseButtonColor:closeColor];
    
    [self setNeedsDisplay];
}

- (void)addTag:(NSString *)tTitle
withImagePlaceholder:(NSString *)tPlaceholderImage
  withImageURL:(NSURL *)imageURL
withLabelColor:(UIColor *)labelColor
withBackgroundColor:(UIColor *)backgroundColor
withCloseButtonColor:(UIColor *)closeColor
{
    AOTag *tag = [self generateTagWithLabel:(tTitle ? tTitle : @"") withImage:(tPlaceholderImage ? tPlaceholderImage : @"")];
    
    [tag setTURL:imageURL];
    
    if (labelColor) [tag setTLabelColor:labelColor];
    if (backgroundColor) [tag setTBackgroundColor:backgroundColor];
    if (closeColor) [tag setTCloseButtonColor:closeColor];
    
    [self setNeedsDisplay];
}

- (void)addTags:(NSArray *)tags
{
    for (NSDictionary *tag in tags)
        [self addTag:[tag objectForKey:@"title"] withImage:[tag objectForKey:@"image"]];
}

- (void)removeTag:(AOTag *)tag
{
    [self.tags removeObject:tag];
    
    [self setNeedsDisplay];
}

- (void)removeAllTag
{
    for (id t in [NSArray arrayWithArray:[self tags]])
        [self removeTag:t];
}

@end

@implementation AOTag

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
//        self.tBackgroundColor = [UIColor colorWithRed:0.204 green:0.588 blue:0.855 alpha:1.000];
        self.tBackgroundColor = [UIColor whiteColor];
        self.tLabelColor = [UIColor whiteColor];
        self.tCloseButtonColor = [UIColor colorWithRed:0.710 green:0.867 blue:0.953 alpha:1.000];
        
        self.tURL = nil;
        
        [self setBackgroundColor:[UIColor clearColor]];
        [self setUserInteractionEnabled:YES];
        
        [[self layer] setCornerRadius:tagCornerRadius];
        [[self layer] setMasksToBounds:YES];
        
    }
    return self;
}

- (CGSize)getTagSize
{
    CGSize tSize = [self.tTitle sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:tagFontType size:tagFontSize]}];
    
    return CGSizeMake(tagMargin + tSize.width + tagMargin - 20, tagHeight+8);
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    self.layer.backgroundColor = [self.tBackgroundColor CGColor];
    CALayer *layer = [self layer];
    [layer setCornerRadius:3.0];
//    layer.borderColor = [[UIColor colorWithRed:0.47 green:0.47 blue:0.47 alpha:1] CGColor];
//    layer.borderWidth = 1.0f;
    
//    self.tImageURL = [[EGOImageView alloc] initWithPlaceholderImage:self.tImage delegate:self];
//    [self.tImageURL setBackgroundColor:[UIColor purpleColor]];
//    [self.tImageURL setFrame:CGRectMake(0.0f, 0.0f, [self getTagSize].height, [self getTagSize].height)];
//    if (self.tURL) [self.tImageURL setImageURL:[self tURL]];
//    [self addSubview:self.tImageURL];
    
    NSArray * colorArr = [NSArray arrayWithObjects:
                       [UtilityFunc colorWithHexString:@"b9090b"],
                       [UtilityFunc colorWithHexString:@"df5f12"],
                       [UtilityFunc colorWithHexString:@"4e5bd2"],
                       [UtilityFunc colorWithHexString:@"109f71"],
                       [UtilityFunc colorWithHexString:@"a89114"],
                       [UtilityFunc colorWithHexString:@"312f2f"],
                       [UtilityFunc colorWithHexString:@"cc2175"],
                       [UtilityFunc colorWithHexString:@"7e15ea"],
                       [UtilityFunc colorWithHexString:@"5c0cc9"],
                       [UtilityFunc colorWithHexString:@"882558"],
                       [UtilityFunc colorWithHexString:@"f4775b"],
                       [UtilityFunc colorWithHexString:@"5abcbb"],
                       [UtilityFunc colorWithHexString:@"a784d4"],
                       [UtilityFunc colorWithHexString:@"117bac"],
                       [UtilityFunc colorWithHexString:@"20a520"],
                       [UtilityFunc colorWithHexString:@"83329e"],
                       [UtilityFunc colorWithHexString:@"0987ff"],
                       [UtilityFunc colorWithHexString:@"a18190"],
                       [UtilityFunc colorWithHexString:@"f97314"],
                       [UtilityFunc colorWithHexString:@"fc0cab"],
                       [UtilityFunc colorWithHexString:@"70e000"],
                       [UtilityFunc colorWithHexString:@"11c100"],
                       [UtilityFunc colorWithHexString:@"fb7367"],
                       [UtilityFunc colorWithHexString:@"a82ee8"],
                       [UtilityFunc colorWithHexString:@"f757d1"],
                       [UtilityFunc colorWithHexString:@"0478ff"],
                       [UtilityFunc colorWithHexString:@"2bc28b"],
                       nil];
        
    CGSize tSize = [self.tTitle sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:tagFontType size:tagFontSize]}];
    //tagHeight + tagMargin
    [self.tTitle drawInRect:CGRectMake(5, ([self getTagSize].height / 2.0f) - (tSize.height / 2.0f), tSize.width, tSize.height)
             withAttributes:@{NSFontAttributeName:[UIFont fontWithName:tagFontType size:tagFontSize], NSForegroundColorAttributeName:[colorArr objectAtIndex:arc4random()%colorArr.count]}];
    //self.tLabelColor
//[UIColor colorWithRed:arc4random_uniform(100)/100. green:arc4random_uniform(100)/100. blue:arc4random_uniform(100)/100. alpha:1]
    
//    AOTagCloseButton *close = [[AOTagCloseButton alloc] initWithFrame:CGRectMake([self getTagSize].width - tagHeight, 0.0, tagHeight, tagHeight)
//                                                            withColor:self.tCloseButtonColor];
//    [self addSubview:close];
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tagSelected:)];
    [recognizer setNumberOfTapsRequired:1];
    [recognizer setNumberOfTouchesRequired:1];
    [self addGestureRecognizer:recognizer];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(tagDidAddTag:)])
        [self.delegate performSelector:@selector(tagDidAddTag:) withObject:self];
}

- (void)tagSelected:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(tagDidSelectTag:)])
        [self.delegate performSelector:@selector(tagDidSelectTag:) withObject:self];
}

- (void)tagClose:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(tagDidRemoveTag:)])
        [self.delegate performSelector:@selector(tagDidRemoveTag:) withObject:self];
    
    [(AOTagList *)[self superview] removeTag:self];
}

#pragma mark - EGOImageView Delegate methods

- (void)imageViewLoadedImage:(EGOImageView *)imageView
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(tagDistantImageDidLoad:)])
        [self.delegate performSelector:@selector(tagDistantImageDidLoad:) withObject:self];
}

- (void)imageViewFailedToLoadImage:(EGOImageView *)imageView error:(NSError*)error
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(tagDistantImageDidFailLoad:withError:)])
        [self.delegate performSelector:@selector(tagDistantImageDidFailLoad:withError:) withObject:self withObject:error];
}

@end

@implementation AOTagCloseButton

- (id)initWithFrame:(CGRect)frame withColor:(UIColor *)color
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setBackgroundColor:[UIColor clearColor]];
        [self setUserInteractionEnabled:YES];
        
        [self setCColor:color];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
//    UIImageView * image = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 15, 15)];
//    image.backgroundColor = [UIColor clearColor];
//    image.userInteractionEnabled = YES;
//    image.image = [UIImage imageNamed:@"mx_add_img"];
//    [self addSubview:image];
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tagClose:)];
    [recognizer setNumberOfTapsRequired:1];
    [recognizer setNumberOfTouchesRequired:1];
    [self addGestureRecognizer:recognizer];
}

- (void)tagClose:(id)sender
{
    if ([[self superview] respondsToSelector:@selector(tagClose:)])
        [[self superview] performSelector:@selector(tagClose:) withObject:self];
}

@end