//
//  AppDelegate.m
//  BaiduTranslate
//
//  Created by xy on 2016/11/10.
//  Copyright © 2016年 xy. All rights reserved.
//

#import "AppDelegate.h"
#import "Reachability.h"
#import "Tools.h"

@interface AppDelegate ()
{
    BOOL islaunch;
}

@end

@implementation AppDelegate

@synthesize hostReach;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    
    NSWindow *window = [NSApplication sharedApplication].windows.firstObject;
    window.title = @"百度翻译";
    
    //开启网络状况的监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    hostReach = [Reachability reachabilityWithHostName:@"http://1212.ip138.com/ic.asp"];
    [hostReach startNotifier];  //开始监听，会启动一个run loop
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    // Insert code here to tear down your application
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

#pragma mark - --------网络状态监听----------------
- (void)reachabilityChanged:(NSNotification *)note
{
    if (!islaunch) {
        islaunch = YES;
        return;
    }
    
    Reachability *currReach = [note object];
    NSParameterAssert([currReach isKindOfClass:[Reachability class]]);
    
    //对连接改变做出响应处理动作
    NetworkStatus status = [currReach currentReachabilityStatus];//当前的状态
    
    if (status == ReachableViaWWAN) {
        NSError *error = [NSError errorWithDomain:@"网络已连接！" code:0 userInfo:@{NSLocalizedDescriptionKey:@"the content is nil"}];
        NSLog(@"%@",error.localizedDescription);
        NSAlert *alert = [NSAlert alertWithError:error];
        alert.messageText = @"当前为移动数据网络";
        [alert addButtonWithTitle:@"确定"];
        [alert runModal];
    }
    else if(status == ReachableViaWiFi)
    {
        NSString *SSIDStr = [Tools getCurrentWifiSSID];
        NSLog(@"当前连接为WiFi网络！SSID : %@", SSIDStr);
        NSDictionary *dicIP = [Tools getLocalIPAddress];
        NSLog(@"当前连接为WiFi网络！IP : %@", dicIP.stringUsingASCIIEncoding);
        
        NSError *error = [NSError errorWithDomain:@"WiFi已经连接！" code:0 userInfo:@{NSLocalizedDescriptionKey:@"the content is nil"}];
        NSLog(@"%@",error.localizedDescription);
        NSAlert *alert = [NSAlert alertWithError:error];
        alert.messageText = @"网络状态发生了改变";
        [alert addButtonWithTitle:@"确定"];
        [alert runModal];
        
    }else{
        
        NSString *SSIDStr = [Tools getCurrentWifiSSID];
        if (SSIDStr.length <= 0) {
            SSIDStr = @"WiFi没有连接！";
            NSLog(@"WiFi没有连接！");
        }else{
            SSIDStr = @"网络不可用！";
            NSLog(@"网络不可用！");
        }
        
        NSError *error = [NSError errorWithDomain:@"网络不可用！" code:0 userInfo:@{NSLocalizedDescriptionKey:@"the content is nil"}];
        NSLog(@"%@",error.localizedDescription);
        NSAlert *alert = [NSAlert alertWithError:error];
        alert.messageText = SSIDStr;
        [alert addButtonWithTitle:@"确定"];
        [alert runModal];
    }
}

@end
