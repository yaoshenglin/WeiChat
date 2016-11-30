//
//  Tools.m
//  BaiduTranslate
//
//  Created by xy on 2016/11/10.
//  Copyright © 2016年 xy. All rights reserved.
//

#import "Tools.h"
#include <objc/runtime.h>
#import <Cocoa/Cocoa.h>

@implementation Tools

#pragma mark - --------其它------------------------
+ (void)duration:(NSTimeInterval)dur block:(dispatch_block_t)block
{
    dispatch_queue_t queue = dispatch_get_main_queue();
    if (block) {
        int64_t delta = (int64_t)(dur * NSEC_PER_SEC);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delta), queue, block);
    }
}

//异步
+ (void)asyncWithBlock:(dispatch_block_t)block
{
    long identifier = DISPATCH_QUEUE_PRIORITY_DEFAULT;
    dispatch_queue_t queue = dispatch_get_global_queue(identifier, 0);
    //queue = dispatch_queue_create("com.icf.serialqueue", nil);//用于异步顺序执行
    if (block) dispatch_async(queue, block);
}

//同步
+ (void)syncWithBlock:(dispatch_block_t)block
{
    dispatch_queue_t queue = dispatch_get_main_queue();
    if (block) dispatch_sync(queue, block);
}

+ (void)async:(dispatch_block_t)block complete:(dispatch_block_t)nextBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
        if (block) block();
        dispatch_queue_t queue = dispatch_get_main_queue();
        if (nextBlock) dispatch_async(queue, nextBlock);
    });
}

@end

#pragma mark NSString
@implementation NSString (NSObject)
- (NSString *)replaceString:(NSString *)target withString:(NSString *)replacement
{
    NSString *result = [self stringByReplacingOccurrencesOfString:target withString:replacement];
    return result;
}

- (NSString *)replaceStrings:(NSArray *)targets withString:(NSString *)replacement
{
    NSString *result = self;
    for (NSString *target in targets) {
        result = [result stringByReplacingOccurrencesOfString:target withString:replacement];
    }
    return result;
}

- (NSString *)stringUsingASCIIEncoding
{
    const char *cString = [self cStringUsingEncoding:NSUTF8StringEncoding];
    NSString *desc = [NSString stringWithCString:cString encoding:NSNonLossyASCIIStringEncoding];
    return desc;
}

- (BOOL)writeToEndWtihPath:(NSString *)path
{
    NSFileHandle *outFile = [NSFileHandle fileHandleForWritingAtPath:path];
    if(outFile == nil)
    {
        NSLog(@"Open of file for writing failed");
        return NO;
    }
    //找到并定位到outFile的末尾位置(在此后追加文件)
    [outFile seekToEndOfFile];
    
    //写入数据
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    [outFile writeData:data];
    
    data = [@"\n" dataUsingEncoding:NSUTF8StringEncoding];
    [outFile writeData:data];
    
    //关闭读写文件
    [outFile closeFile];
    
    return YES;
}

@end

#pragma mark - --------NSArray------------------------
@implementation NSArray (NSObject)

- (id)objAtIndex:(NSInteger)index
{
    if (self.count > index && index >= 0) {
        return [self objectAtIndex:index];
    }
    
    return nil;
}

@end

#pragma mark - --------NSDictionary------------------------
@implementation NSDictionary (NSObject)

- (NSString *)stringUsingASCIIEncoding
{
    NSString *desc = self.description;
    desc = [desc stringUsingASCIIEncoding];
    return desc;
}

@end

#pragma mark NSData
@implementation NSData (NSObject)

- (NSString *)stringUsingEncode:(NSStringEncoding)encode
{
    NSString *result = [[NSString alloc] initWithData:self encoding: encode];
    return result;
}

@end

#pragma mark - --------NSScrollView------------------------
@implementation NSScrollView (NSObject)

- (NSString *)string
{
    NSTextView *textView = self.documentView;
    return textView.string;
}

- (NSTextView *)textView
{
    if ([self.documentView isKindOfClass:[NSTextView class]]) {
        return self.documentView;
    }
    return nil;
}

- (void)setTextViewString:(NSString *)string
{
    NSTextView *textView = self.documentView;
    textView.string = string;
}

@end

#pragma mark - --------NSObject------------------------
@implementation NSObject (NSObject)

- (void)duration:(NSTimeInterval)dur action:(SEL)action
{
    [self performSelector:action withObject:nil afterDelay:dur];
}

- (void)duration:(NSTimeInterval)dur action:(SEL)action with:(id)anArgument
{
    [self performSelector:action withObject:anArgument afterDelay:dur];
}

- (NSData *)archivedData
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
    return data;
}

- (void)isNULLToEqual:(id)obj
{
    if (self == nil) {
    }
}

- (BOOL)isBelongTo:(NSArray *)list
{
    if ([list containsObject:self]) {
        return YES;
    }
    
    return NO;
}

- (NSString *)className
{
    NSString *result = NSStringFromClass([self class]);
    return result;
}

- (BOOL)classNameIsEqual:(id)aClass
{
    if (!aClass) {
        return NO;
    }
    
    if ([self.className isEqualToString:NSStringFromClass([aClass class])]) {
        return YES;
    }
    
    return NO;
}

#pragma mark - 通过对象获取全部属性
- (NSArray *)getObjectPropertyList
{
    NSArray *list = nil;
    unsigned int propsCount;
    objc_property_t *props = class_copyPropertyList([self class], &propsCount);
    list = propsCount>0 ? @[] : nil;
    for(int i = 0;i < propsCount; i++)
    {
        objc_property_t prop = props[i];
        
        const char *name = property_getName(prop);
        NSString *propName = [NSString stringWithUTF8String:name];
        list = [list arrayByAddingObject:propName];
    }
    
    return list;
}

- (NSArray *)getObjectIvarList
{
    NSArray *list = nil;
    unsigned int propsCount;
    Ivar *ivar = class_copyIvarList([self class], &propsCount);
    list = propsCount>0 ? @[] : nil;
    for(int i = 0;i < propsCount; i++) {
        Ivar var = ivar[i];
        const char *name = ivar_getName(var);
        NSString *propName = [NSString stringWithUTF8String:name];
        list = [list arrayByAddingObject:propName];
    }
    
    return list;
}

- (id)copyObject
{
    id obj = [[self.class alloc] init];
    NSArray *listPro = [self getObjectIvarList];
    for (NSString *key in listPro) {
        id value = [self valueForKey:key];
        [obj setValue:value forKey:key];
    }
    
    return obj;
}

#pragma mark - 通过对象返回一个NSDictionary，键是属性名称，值是属性值。
- (NSDictionary *)getObjectData
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    unsigned int propsCount;
    objc_property_t *props = class_copyPropertyList([self class], &propsCount);
    for(int i = 0;i < propsCount; i++)
    {
        objc_property_t prop = props[i];
        
        NSString *propName = [NSString stringWithUTF8String:property_getName(prop)];
        id value = [self valueForKey:propName];
        if(value == nil)
        {
            value = [NSNull null];
        }
        else
        {
            value = [value getObjectInternal];
        }
        [dic setObject:value forKey:propName];
    }
    return dic;
}

- (id)getObjectInternal
{
    if([self isKindOfClass:[NSString class]]
       || [self isKindOfClass:[NSNumber class]]
       || [self isKindOfClass:[NSNull class]])
    {
        return self;
    }
    
    if([self isKindOfClass:[NSArray class]])
    {
        NSArray *objarr = (NSArray *)self;
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:objarr.count];
        for(int i = 0;i < objarr.count; i++)
        {
            [arr setObject:[[objarr objectAtIndex:i] getObjectInternal] atIndexedSubscript:i];
        }
        return arr;
    }
    
    if([self isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *objdic = (NSDictionary *)self;
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:[objdic count]];
        for(NSString *key in objdic.allKeys)
        {
            [dic setObject:[[objdic objectForKey:key] getObjectInternal] forKey:key];
        }
        return dic;
    }
    return [self getObjectData];
}

@end
