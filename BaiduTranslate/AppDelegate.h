//
//  AppDelegate.h
//  BaiduTranslate
//
//  Created by xy on 2016/11/10.
//  Copyright © 2016年 xy. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Reachability;
@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (nonatomic, retain) Reachability *hostReach;

@end

