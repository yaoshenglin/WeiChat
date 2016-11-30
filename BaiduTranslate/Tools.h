//
//  Tools.h
//  BaiduTranslate
//
//  Created by xy on 2016/11/10.
//  Copyright © 2016年 xy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

typedef CF_ENUM(NSStringEncoding, CFStringBuilt) {
    GBEncoding = 0x80000632 /* kTextEncodingUnicodeDefault + kUnicodeUTF32LEFormat */
};

@interface Tools : NSObject

+ (void)duration:(NSTimeInterval)dur block:(dispatch_block_t)block;
//异步
+ (void)asyncWithBlock:(dispatch_block_t)block;
//同步
+ (void)syncWithBlock:(dispatch_block_t)block;
+ (void)async:(dispatch_block_t)block complete:(dispatch_block_t)nextBlock;

@end

#pragma mark NSString
@interface NSString (NSObject)

- (NSString *)replaceString:(NSString *)target withString:(NSString *)replacement;
- (NSString *)replaceStrings:(NSArray *)targets withString:(NSString *)replacement;

- (NSString *)stringUsingASCIIEncoding;

- (BOOL)writeToEndWtihPath:(NSString *)path;//写入文件末尾

@end

#pragma mark - NSArray
@interface NSArray (NSObject)

- (id)objAtIndex:(NSInteger)index;//根据下标获取数据

@end

#pragma mark - NSDictionary
@interface NSDictionary (NSObject)

- (NSString *)stringUsingASCIIEncoding;

@end

#pragma mark NSData
@interface NSData (NSObject)

- (NSString *)stringUsingEncode:(NSStringEncoding)encode;

@end

#pragma mark - NSScrollView
@interface NSScrollView (NSObject)

- (NSString *)string;
- (NSTextView *)textView;
- (void)setTextViewString:(NSString *)string;

@end

#pragma mark - NSObject
@interface NSObject (NSObject)

- (void)duration:(NSTimeInterval)dur action:(SEL)action;
- (void)duration:(NSTimeInterval)dur action:(SEL)action with:(id)anArgument;
- (NSData *)archivedData;//存档数据
- (BOOL)isBelongTo:(NSArray *)list;
- (NSString *)className;//返回类名
- (BOOL)classNameIsEqual:(id)aClass;//类名相同
#pragma mark - 通过对象获取全部属性
- (NSArray *)getObjectPropertyList;
- (NSArray *)getObjectIvarList;
- (id)copyObject;//复制一个对象
#pragma mark - 通过对象返回一个NSDictionary，键是属性名称，值是属性值。
- (NSDictionary *)getObjectData;

@end
