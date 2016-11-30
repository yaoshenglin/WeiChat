//
//  ViewController.h
//  BaiduTranslate
//
//  Created by xy on 2016/11/10.
//  Copyright © 2016年 xy. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController

@property (weak) IBOutlet NSScrollView *txtContent;
@property (weak) IBOutlet NSScrollView *txtMeans;
@property (weak) IBOutlet NSButton *btnTranslate;
@property (weak) IBOutlet NSView *progressBgView;
@property (weak) IBOutlet NSProgressIndicator *progressIndicatorView;
@property (weak) IBOutlet NSScrollView *txtLocalized;

@end

