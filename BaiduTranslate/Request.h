//
//  Request.h
//  BaiduTranslate
//
//  Created by xy on 2016/11/10.
//  Copyright © 2016年 xy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Request : NSObject

@property (nonatomic, weak) id delegate;
@property (nonatomic, retain) NSMutableURLRequest *urlRequest;
@property (nonatomic, retain) NSData *HTTPBody;

@property (nonatomic, retain, readonly) NSError *error;
@property (nonatomic, retain, readonly) NSURLResponse *response;
@property (nonatomic, retain, readonly) NSData *data;

- (id)initWithUrl:(NSURL *)url;
- (NSData *)startRequest;
- (void)startSessionRequest;//新的请求方式

+ (NSDictionary *)requestWithUrl:(NSURL *)url;
+ (NSData *)bodyWithContent:(NSString *)content;
+ (NSData *)bodyFromYoudaoWtihContent:(NSString *)content;

+ (NSData *)requestWithUrl:(NSURL *)url httpBody:(NSData *)httpBody;
+ (NSData *)requestWithUrl:(NSURL *)url httpBody:(NSData *)httpBody timeoutInterval:(NSTimeInterval)timeoutInterval;
+ (NSString *)queryIPAdress:(NSString *)adress;

@end

@protocol RequestDelegate <NSObject>

- (void)completeRequest:(Request *)request;

@end
