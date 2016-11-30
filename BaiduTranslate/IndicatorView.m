//
//  IndicatorView.m
//  BaiduTranslate
//
//  Created by xy on 2016/11/16.
//  Copyright © 2016年 xy. All rights reserved.
//

#import "IndicatorView.h"

@implementation IndicatorView

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    self.layer.backgroundColor = [[NSColor blackColor] colorWithAlphaComponent:0.3].CGColor;
    // Drawing code here.
}

- (void)updateLayer
{
    [super updateLayer];
    
    self.layer.backgroundColor = [[NSColor blackColor] colorWithAlphaComponent:0.3].CGColor;
}

- (void)mouseDown:(NSEvent *)event
{
//    NSLog(@"Down, %@",event);
}

- (BOOL)acceptsFirstMouse:(NSEvent *)event
{
    NSLog(@"First, %@",event);
    return NO;
}

//- (BOOL)mouse:(NSPoint)point inRect:(NSRect)rect
//{
//    NSLog(@"inRect, %@",NSStringFromRect(rect));
//    return YES;
//}

- (void)mouseUp:(NSEvent *)event
{
//    NSLog(@"Up, %@",event);
}

@end
