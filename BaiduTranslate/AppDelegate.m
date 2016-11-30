//
//  AppDelegate.m
//  BaiduTranslate
//
//  Created by xy on 2016/11/10.
//  Copyright © 2016年 xy. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    
    NSWindow *window = [NSApplication sharedApplication].windows.firstObject;
    window.title = @"百度翻译";
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    // Insert code here to tear down your application
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

@end
