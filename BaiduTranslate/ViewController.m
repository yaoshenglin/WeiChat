//
//  ViewController.m
//  BaiduTranslate
//
//  Created by xy on 2016/11/10.
//  Copyright © 2016年 xy. All rights reserved.
//

#import "ViewController.h"
#import "Request.h"
#import "Tools.h"

@interface ViewController ()<NSTextViewDelegate>
{
    NSDictionary *dicMeans;
    NSScrollView *scrollView;
    
    BOOL isEntry;
}

@end

@implementation ViewController

- (void)viewWillAppear
{
    [super viewWillAppear];
    
    self.view.window.title = @"百度翻译1";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    NSTextView *textView = _txtContent.documentView;
    textView.delegate = self;
    
    textView.automaticQuoteSubstitutionEnabled = NO;
    _txtLocalized.textView.automaticQuoteSubstitutionEnabled = NO;
    
    _progressBgView.layer.backgroundColor = [[NSColor blackColor] colorWithAlphaComponent:0.3].CGColor;
}

- (void)viewWillLayout
{
    [super viewWillLayout];
}

- (void)viewDidAppear
{
    [super viewDidAppear];
    
    [self showActivityView:YES];
    [Tools duration:0.3 block:^{
        [self showActivityView:NO];
        NSString *urlString = @"http://1212.ip138.com/ic.asp";
        NSURL *url = [NSURL URLWithString:urlString];
        NSData *data = [Request requestWithUrl:url httpBody:nil timeoutInterval:1.5];
        
        NSString *content = [data stringUsingEncode:GBEncoding];
        NSArray *list = [content componentsSeparatedByString:@"center"];
        content = [list objAtIndex:1] ?: @"";
        content = [content replaceStrings:@[@">",@"</"] withString:@""];
        [_txtMeans setTextViewString:content];
        NSLog(@"%@",content);
    }];
}

- (void)showActivityView:(BOOL)isShow
{
    _progressBgView.hidden = !isShow;
    
    if (isShow) {
        [_progressIndicatorView startAnimation:nil];
    }else{
        [_progressIndicatorView stopAnimation:nil];
    }
}

#pragma mark 百度翻译
- (IBAction)translateContent:(NSButton *)sender
{
    dicMeans = nil;
    NSTextView *textView = _txtContent.documentView;
    NSString *content = textView.string;
    [self queryContene:content];
}

- (void)queryContene:(NSString *)content
{
    if (content.length <= 0) {
        NSError *error = [NSError errorWithDomain:@"输入内容为空" code:0 userInfo:@{NSLocalizedDescriptionKey:@"the content is nil"}];
        NSLog(@"%@",error.localizedDescription);
        NSAlert *alert = [NSAlert alertWithError:error];
        alert.messageText = @"输入内容不能为空";
        [alert addButtonWithTitle:@"确定"];
        [alert runModal];
        return;
    }
    
    [self showActivityView:YES];
    NSString *urlString = @"http://fanyi.baidu.com/v2transapi";
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSData *httpBody = [Request bodyWithContent:content];
    Request *request = [[Request alloc] initWithUrl:url];
    request.delegate = self;
    request.HTTPBody = httpBody;
    [request startSessionRequest];
}

#pragma mark 有道翻译
- (IBAction)translateContentFromYoudao:(NSButton *)sender
{
    dicMeans = nil;
    NSTextView *textView = _txtContent.documentView;
    NSString *content = textView.string;
    [self queryFromYoudaoWtihContent:content];
}

- (void)queryFromYoudaoWtihContent:(NSString *)content
{
    [self showActivityView:YES];
    NSTextView *textView = _txtMeans.documentView;

    NSString *urlString = @"http://fanyi.youdao.com/translate";
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSData *data = [Request bodyFromYoudaoWtihContent:content];
    
    Request *request = [[Request alloc] initWithUrl:url];
    request.delegate = self;
    request.HTTPBody = data;
    [request startSessionRequest];
    
    
    if (content.length > 0 && content.length < 6) {
        textView.string = @"";
        [Tools duration:0.5 block:^{
            NSString *urlString = @"http://dict.youdao.com/jsonapi";
            NSURL *url = [NSURL URLWithString:urlString];
            
            NSString *bodyStr = [NSString stringWithFormat:@"q=%@&doctype=json&keyfrom=mac.main&id=E9B5EABC072E404ED1C7D35D8FAD541B&vendor=appstore&appVer=2.1.1&client=macdict&le=eng",content];
            NSData *data = [bodyStr dataUsingEncoding:NSUTF8StringEncoding];
            
            Request *request = [[Request alloc] initWithUrl:url];
            request.delegate = self;
            request.HTTPBody = data;
            [request startSessionRequest];
        }];
    }
}

#pragma mark 完成请求
- (void)completeRequest:(Request *)request
{
    [self showActivityView:NO];
    NSError *error = request.error;
    if (!error) {
        NSData *data = request.data;
        [self parseData:data fromRequest:request];
        
    }else{
        NSLog(@"%@",error.localizedDescription);
        
        error = error ?: [NSError errorWithDomain:@"输入内容为空" code:0 userInfo:@{NSLocalizedDescriptionKey:@"输入内容不能为空"}];
        NSLog(@"%@",error.localizedDescription);
        NSAlert *alert = [NSAlert alertWithError:error];
        alert.messageText = error.localizedDescription;
        [alert addButtonWithTitle:@"确定"];
        [alert beginSheetModalForWindow:self.view.window completionHandler:nil];
    }
}

- (void)parseData:(NSData *)data fromRequest:(Request *)request
{
    NSString *host = request.urlRequest.URL.host;
    NSTextView *textView = _txtMeans.documentView;
    
    NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse *)request.response;
    NSInteger statusCode = urlResponse.statusCode;
    if (statusCode != 200) {
        textView.string = [urlResponse.description stringUsingASCIIEncoding];
        
        CFStringRef theString = (__bridge CFStringRef)urlResponse.textEncodingName;
        CFStringEncoding enc = CFStringConvertIANACharSetNameToEncoding(theString);
        NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding (enc);
        NSString *stringL = [[NSString alloc] initWithData:data encoding: encoding];
        NSLog(@"%@",stringL);
        return;
    }
    
    if ([host hasPrefix:@"fanyi.baidu.com"]) {
        NSError *error = nil;
        NSDictionary *dicData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        if (!dicData) {
            NSLog(@"%ld, %@",error.code,error.localizedDescription);
            
            NSString *textEncodingName = urlResponse.textEncodingName ?: @"utf-8";
            CFStringRef theString = (__bridge CFStringRef)textEncodingName;
            CFStringEncoding enc = CFStringConvertIANACharSetNameToEncoding(theString);
            NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding (enc);
            NSString *string = [[NSString alloc] initWithData:data encoding:encoding];
            if (string) {
                [_txtMeans setTextViewString:string];
            }else{
                [_txtMeans setTextViewString:@"数据解析出错"];
            }
            
            return;
        }
        
        NSDictionary *result = [[dicData valueForKeyPath:@"trans_result.data"] firstObject];
        NSString *src = [result valueForKey:@"src"] ?: @"";
        NSString *dst = [result valueForKey:@"dst"] ?: @"";
        NSLog(@"%@",src);
        NSLog(@"%@",dst);
        dicMeans = @{@"mean":dst};
        textView.string = [NSString stringWithFormat:@"%@\n",[result valueForKey:@"dst"]];
        //NSLog(@"%@",[dicData valueForKeyPath:@"liju_result.double"]);
        NSDictionary *dic = [[dicData valueForKeyPath:@"dict_result.simple_means.symbols"] firstObject];
        NSArray *listParts = [dic valueForKey:@"parts"];
        for (NSDictionary *item in listParts) {
            NSArray *listMeans = [item valueForKey:@"means"];
            
            for (NSDictionary *itemMeans in listMeans) {
                
                if ([itemMeans isKindOfClass:[NSString class]]) {
                    //部分翻译较短,结构相对简单(比如数字类)
                    NSString *content = (NSString *)itemMeans;
                    if (![content isEqualToString:dst]) {
                        textView.string = [NSString stringWithFormat:@"%@\n%@",textView.string,content];
                    }
                }
                else if ([itemMeans isKindOfClass:[NSDictionary class]]) {
                    NSArray *means = [itemMeans valueForKey:@"means"];
                    NSString *content = [NSString stringWithFormat:@"%@ : %@",[itemMeans valueForKey:@"text"],[means componentsJoinedByString:@","]];
                    NSLog(@"%@",content);
                    textView.string = [NSString stringWithFormat:@"%@\n%@",textView.string,content];
                }else{
                    NSString *content = [NSString stringWithFormat:@"%@",listMeans];
                    NSError *error = [NSError errorWithDomain:@"翻译有误" code:0 userInfo:@{NSLocalizedDescriptionKey:@"the content is error"}];
                    NSLog(@"%@",error.localizedDescription);
                    NSAlert *alert = [NSAlert alertWithError:error];
                    alert.messageText = content;
                    [alert addButtonWithTitle:@"确定"];
                    [alert runModal];
                }
            }
            
        }
    }
    else if ([host hasPrefix:@"fanyi.youdao.com"]) {
        NSDictionary *dicData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"%@",[dicData stringUsingASCIIEncoding]);
        NSString *result = [[[dicData valueForKeyPath:@"translateResult.tgt"] firstObject] firstObject];
        textView.string = [NSString stringWithFormat:@"%@\n",result];
        
        dicMeans = @{@"mean":result?:@""};
    }
    else if ([host hasPrefix:@"dict.youdao.com"]) {
        NSDictionary *dicData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        if (dicData) {
            NSLog(@"%@",[dicData stringUsingASCIIEncoding]);
            
            if ([dicData objectForKey:@"blng_sents_part"]) {
                dicData = [dicData valueForKeyPath:@"blng_sents_part"];
                NSArray *list = [dicData valueForKey:@"sentence-pair"];
                NSString *content = [textView.string stringByAppendingString:@"\n\n例句：\n"];
                for (int i=0; i<list.count; i++) {
                    NSDictionary *dic = list[i];
                    NSString *sentence = [dic valueForKey:@"sentence"];
                    NSString *sentence_translation = [dic valueForKey:@"sentence-translation"];
                    NSString *source = [dic valueForKey:@"source"];
                    
                    content = [content stringByAppendingFormat:@"%d.%@\n",i+1,sentence];
                    content = [content stringByAppendingFormat:@"%@\n",sentence_translation];
                    if (source) {
                        content = [content stringByAppendingFormat:@"来自%@\n",source];
                    }
                    
                    content = [content stringByAppendingFormat:@"\n"];
                }
                
                textView.string = [NSString stringWithFormat:@"%@\n",content];
            }else{
                NSString *result = [dicData valueForKeyPath:@"fanyi.tran"];
                textView.string = [NSString stringWithFormat:@"%@\n",result];
            }
        }else{
            NSString *string = [data stringUsingEncode:NSUTF8StringEncoding];
            NSLog(@"%@",string);
        }
    }
    
    [self showLocalizedContent];
}

- (void)showLocalizedContent
{
    NSTextView *textView = _txtLocalized.documentView;
    
    NSString *prefixString = @"WaitLogin";
    NSString *suffixString = _txtContent.string;//x
    NSString *engString = _txtMeans.string;//
    engString = [engString replaceString:@"\n" withString:@""];
    
    if (dicMeans) {
        engString = [dicMeans valueForKey:@"mean"];
    }
    
    printf("\n\"%s\" = \"%s\";\n",prefixString.UTF8String,suffixString.UTF8String);
    printf("\"%s\" = \"%s\";\n\n",prefixString.UTF8String,engString.UTF8String);
    printf("LocalizedSingle(@\"%s\")\n\n",prefixString.UTF8String);
    
    NSString *content = [NSString stringWithFormat:@"\"%@\" = \"%@\";\n",prefixString,suffixString];
    content = [content stringByAppendingFormat:@"\"%@\" = \"%@\";\n\n",prefixString,engString];
    content = [content stringByAppendingFormat:@"LocalizedSingle(@\"%@\")",prefixString];
    textView.string = content;
}

- (void)setRepresentedObject:(id)representedObject
{
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

#pragma mark - --------NSTextViewDelegate------------------------
// Delegate only.  Supersedes textView:willChangeSelectionFromCharacterRange:toCharacterRange:.  Return value must be a non-nil, non-empty array of objects responding to rangeValue.
- (NSArray<NSValue *> *)textView:(NSTextView *)textView willChangeSelectionFromCharacterRanges:(NSArray<NSValue *> *)oldSelectedCharRanges toCharacterRanges:(NSArray<NSValue *> *)newSelectedCharRanges
{
    NSValue *theValue = newSelectedCharRanges.firstObject;
    NSRange range = theValue.rangeValue;
    
    NSString *content = textView.string;
    if (content.length == range.location) {
        //光标在末尾
        isEntry = YES;
    }else{
        isEntry = NO;
    }
    
    return newSelectedCharRanges;
}

- (BOOL)textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector
{
    NSString *content = textView.string;
    if (content.length <= 0) {
        [_txtMeans setTextViewString:@""];
        return YES;
    }
    
    if (isEntry) {
        [self queryContene:content];
    }
    
    return NO;
}

- (BOOL)textView:(NSTextView *)textView shouldChangeTextInRanges:(NSArray<NSValue *> *)affectedRanges replacementStrings:(nullable NSArray<NSString *> *)replacementStrings
{
    if (affectedRanges.count > 1 || replacementStrings.count > 1) {
        NSLog(@"affected, %@",affectedRanges);
        NSLog(@"replacement, %@",replacementStrings);
    }
    
    NSString *replacementString = replacementStrings.firstObject;
    if ([replacementString isEqualToString:@"\n"]) {
        return NO;
    }
    
    return YES;
}

- (NSAlert *)showErrMsg:(NSString *)msg title:(NSString *)title
{
    NSError *error = [NSError errorWithDomain:@"内容有误" code:0 userInfo:@{NSLocalizedDescriptionKey:@"the content is error"}];
    NSLog(@"%@",error.localizedDescription);
    NSAlert *alert = [NSAlert alertWithError:error];
    alert.messageText = msg;
    alert.informativeText = title;
    alert.alertStyle = NSAlertStyleInformational;
    [alert addButtonWithTitle:@"确定"];
    [alert runModal];
    
    return alert;
}

#pragma mark 保存数据
- (IBAction)saveData:(NSButton *)sender
{
    NSString *path = [@"~/" stringByExpandingTildeInPath];
    NSString *directoryPath = [path stringByAppendingPathComponent:@"/Documents/Caches/语言国际化"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:directoryPath]) {
        [fileManager createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *zhFilePath = [directoryPath stringByAppendingPathComponent:@"中文.txt"];
    NSData *data = [@"" dataUsingEncoding:NSUTF8StringEncoding];
    if (![fileManager fileExistsAtPath:zhFilePath]) {
        [fileManager createFileAtPath:zhFilePath contents:data attributes:nil];
    }
    
    NSString * enFilePath = [directoryPath stringByAppendingPathComponent:@"英文.txt"];
    if (![fileManager fileExistsAtPath:enFilePath]) {
        [fileManager createFileAtPath:enFilePath contents:data attributes:nil];
    }
    
//    NSString *content = _txtLocalized.string;
//    NSArray *list = [content componentsSeparatedByString:@"LocalizedSingle(@\""];
//    list = [[list objAtIndex:1] componentsSeparatedByString:@"\""];
//    if (list.count != 2) {
//        [self showErrMsg:@"写入内容格式错误" title:@""];
//        return;
//    }
//    
//    //组合数据
//    NSString *prefixString = list.firstObject;
//    NSString *suffixString = _txtContent.string;//内容
//    NSString *engString = _txtMeans.string;//翻译
//    engString = [engString replaceString:@"\n" withString:@""];
//    
//    if (dicMeans) {
//        engString = [dicMeans valueForKey:@"mean"];
//    }
//    
//    NSString *content1 = [NSString stringWithFormat:@"\"%@\" = \"%@\";",prefixString,suffixString];
//    NSString *content2 = [NSString stringWithFormat:@"\"%@\" = \"%@\";",prefixString,engString];
    
    //
    NSString *content = _txtLocalized.string;
    NSArray *list = [content componentsSeparatedByString:@"\";\n"];
    if (list.count < 3) {
        [self showErrMsg:@"写入内容格式错误" title:@""];
        return;
    }
    
    NSString *content1 = list.firstObject;
    NSString *content2 = list[1];
    content = list[2];
    
    content = [content replaceString:@"\n" withString:@""];
    list = [content componentsSeparatedByString:@"LocalizedSingle(@\""];
    list = [[list objAtIndex:1] componentsSeparatedByString:@"\""];
    if (list.count != 2) {
        [self showErrMsg:@"写入内容格式错误" title:@""];
        return;
    }
    NSString *prefixString = list.firstObject;
    content = [NSString stringWithContentsOfFile:zhFilePath encoding:NSUTF8StringEncoding error:nil];
    NSString *key = [NSString stringWithFormat:@"\"%@\"",prefixString];;
    if ([content containsString:key]) {
        [self showErrMsg:@"该键值已经存在，请检查后再保存" title:@"内容重复"];
        return;
    }
    
    content1 = [content1 stringByAppendingString:@"\";"];
    content2 = [content2 stringByAppendingString:@"\";"];
    content1 = [content1 replaceString:@"\"WaitLogin\"" withString:key];
    content2 = [content2 replaceString:@"\"WaitLogin\"" withString:key];
    BOOL isSuccess1 = [content1 writeToEndWtihPath:zhFilePath];
    BOOL isSuccess2 = [content2 writeToEndWtihPath:enFilePath];
    
    if (!isSuccess1 || !isSuccess2) {
        [self showErrMsg:@"写入数据失败" title:@""];
    }else{
        [self showActivityView:YES];
        [Tools duration:0.2 block:^{
            [self showActivityView:NO];
        }];
    }
    
    NSLog(@"%@",content1);
    NSLog(@"%@",content2);
    NSLog(@"%@",key);
}


@end
