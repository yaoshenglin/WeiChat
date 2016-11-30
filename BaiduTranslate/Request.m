//
//  Request.m
//  BaiduTranslate
//
//  Created by xy on 2016/11/10.
//  Copyright © 2016年 xy. All rights reserved.
//

#import "Request.h"
#import "Tools.h"

@implementation Request

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    
    return self;
}

- (id)initWithUrl:(NSURL *)url
{
    _urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    _urlRequest.HTTPMethod = @"POST";
    
    return self;
}

- (void)setHTTPBody:(NSData *)HTTPBody
{
    _HTTPBody = HTTPBody;
    _urlRequest.HTTPBody = HTTPBody;
}

- (void)setValue:(nullable NSString *)value forHTTPHeaderField:(NSString *)field
{
    [_urlRequest setValue:value forHTTPHeaderField:field];
}

- (NSData *)startRequest
{
    //强制同步
    dispatch_semaphore_t disp = dispatch_semaphore_create(0);
    
    NSURLSession *urlSession = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:_urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        _error = error;
        _response = response;
        _data = data;
        dispatch_semaphore_signal(disp);
    }];
    [dataTask resume];
    
    dispatch_semaphore_wait(disp, DISPATCH_TIME_FOREVER);
    
    return _data;
}

- (void)startSessionRequest
{
    //异步请求
    NSURLSession *urlSession = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:_urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        _error = error;
        _response = response;
        _data = data;
        if ([_delegate respondsToSelector:@selector(completeRequest:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_delegate completeRequest:self];
            });
        }
    }];
    [dataTask resume];
}

//- (NSURLRequest *)requestWithUrl:(NSURL *)url
//{
//    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
//    request.HTTPMethod = @"POST";
//
//    return request;
//}

+ (NSDictionary *)requestWithUrl:(NSURL *)url
{
    //boundary
    NSString *theBoundary = @"from=zh&to=en&query=搞笑的手机号码&transtype=translang&simple_means_flag=3";
    //    theBoundary = [theBoundary stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //访问请求
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"POST";
    //用来拼接参数
    NSMutableData *dataContent = [NSMutableData data];
    //拼接第一个参数
    [dataContent appendData:[theBoundary dataUsingEncoding:NSUTF8StringEncoding]];
    //    //拼接参数名
    //    [data appendData:[@"Content-Disposition:form-data;name=\\\"uid\\\"\\r\\n" dataUsingEncoding:NSUTF8StringEncoding]];
    //    [data appendData:[@"\\r\\n" dataUsingEncoding:NSUTF8StringEncoding]];
    //    //拼接参数值
    //    [data appendData:[@"11230953" dataUsingEncoding:NSUTF8StringEncoding]];
    //    [data appendData:[@"\\r\\n" dataUsingEncoding:NSUTF8StringEncoding]];
    //    //拼接第二个参数
    //    [data appendData:[[NSString stringWithFormat:@"--%@\\r\\n", theBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    //    //拼接参数名
    //    [data appendData:[@"Content-Disposition:form-data;name=\\\"file\\\";filename=\\\"myText.txt\\\"\\r\\n" dataUsingEncoding:NSUTF8StringEncoding]];
    //    //拼接文件类型
    //    [data appendData:[@"Content-Type:text/plain" dataUsingEncoding:NSUTF8StringEncoding]];
    //    [data appendData:[@"\\r\\n" dataUsingEncoding:NSUTF8StringEncoding]];
    //    //拼接参数值
    //    [data appendData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"myText" ofType:@"txt"]]];
    //    [data appendData:[@"\\r\\n" dataUsingEncoding:NSUTF8StringEncoding]];
    //拼接结束标志
    
    //[request setValue:@"*/*" forHTTPHeaderField:@"Accept"];
    //[request setValue:@"http://fanyi.baidu.com" forHTTPHeaderField:@"Origin"];
    //[request setValue:@"XMLHttpRequest" forHTTPHeaderField:@"X-Requested-With"];
    //[request setValue:@"http://fanyi.baidu.com/?aldtype=16047" forHTTPHeaderField:@"Referer"];
    //[request setValue:@"gzip, deflate" forHTTPHeaderField:@"Accept-Encoding"];
    //[request setValue:@"zh-CN,zh;q=0.8" forHTTPHeaderField:@"Accept-Language"];
    //[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    request.HTTPBody = dataContent;
    [request setValue:[NSString stringWithFormat:@"%ld", dataContent.length] forHTTPHeaderField:@"Content-Length"];
    
    __block NSError *err = nil;
    __block NSURLResponse *respon = nil;
    dispatch_semaphore_t disp = dispatch_semaphore_create(0);
    NSURLSession *urlSession = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        err = error;
        respon = response;
        dataContent.data = data;
        dispatch_semaphore_signal(disp);
    }];
    [dataTask resume];
    dispatch_semaphore_wait(disp, DISPATCH_TIME_FOREVER);
    
    //NSURLSession *session = [NSURLSession sharedSession];
    //NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
    //    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    //    NSLog(@"%@", dic);
    //}];
    //[dataTask resume];
    NSMutableDictionary *dicValue = [NSMutableDictionary dictionary];
    if (dataContent) {
        [dicValue setObject:dataContent forKey:@"data"];
    }
    
    if (respon) {
        [dicValue setObject:respon forKey:@"response"];
    }
    
    if (err) {
        [dicValue setObject:err forKey:@"error"];
    }
    
    return dicValue;
}

+ (NSData *)bodyWithContent:(NSString *)content
{
    NSString *theBoundary = [NSString stringWithFormat:@"from=zh&to=en&query=%@&transtype=translang&simple_means_flag=3",content];
    
    NSData *data = [theBoundary dataUsingEncoding:NSUTF8StringEncoding];
    return data;
}

+ (NSData *)bodyFromYoudaoWtihContent:(NSString *)content
{
    NSString *theBoundary = [NSString stringWithFormat:@"i=%@&type=AUTO&doctype=json&id=E9B5EABC072E404ED1C7D35D8FAD541B&vendor=appstore&appVer=2.1.1&xmlVersion=1.6&keyfrom=mac.fanyi",content];
    NSData *data = [theBoundary dataUsingEncoding:NSUTF8StringEncoding];
    return data;
}

+ (NSData *)requestWithUrl:(NSURL *)url httpBody:(NSData *)httpBody
{
    return [self requestWithUrl:url httpBody:httpBody timeoutInterval:0];
}

+ (NSData *)requestWithUrl:(NSURL *)url httpBody:(NSData *)httpBody timeoutInterval:(NSTimeInterval)timeoutInterval
{
    __block NSError *_error = nil;
    __block NSURLResponse *_response = nil;
    __block NSData *_data = nil;
    NSMutableURLRequest *_urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    _urlRequest.HTTPBody = httpBody;
    _urlRequest.HTTPMethod = @"GET";
    if (timeoutInterval > 0) {
        _urlRequest.timeoutInterval = timeoutInterval;
    }
    
    dispatch_semaphore_t disp = dispatch_semaphore_create(0);
    
    NSURLSession *urlSession = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:_urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        _error = error;
        _response = response;
        _data = data;
        dispatch_semaphore_signal(disp);
    }];
    [dataTask resume];
    
    dispatch_semaphore_wait(disp, DISPATCH_TIME_FOREVER);
    
    if (_error) {
        NSLog(@"%ld, %@",(long)_error.code,_error.localizedDescription);
        if (!_data) {
            NSString *errMsg = [NSString stringWithFormat:@"%ldcenter%@",_error.code,_error.localizedDescription];
            _data = [errMsg dataUsingEncoding:GBEncoding];
        }
    }
    
    return _data;
}

+ (NSString *)queryIPAdress:(NSString *)adress
{
    adress = adress ?: @"120.197.55.147";
    NSString *urlString = [NSString stringWithFormat:@"https://sp0.baidu.com/8aQDcjqpAAV3otqbppnN2DJv/api.php?query=%@&co=&resource_id=6006&t=1478844763925&ie=utf8&oe=gbk&cb=op_aladdin_callback&format=json&tn=baidu&cb=jQuery1102046848492178260515_1478844287070&_=1478844287074",adress];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSData *data = [self.class requestWithUrl:url httpBody:nil];
    
    NSString *path = @"/Users/xy/Documents/CrashInfo/iP地址.txt";
    [data writeToFile:path atomically:YES];
    
    NSString *content = [data stringUsingEncode:0x80000632];
    if (!content) {
        content = [data stringUsingEncode:NSUTF8StringEncoding];
    }
    return content;
}

@end
