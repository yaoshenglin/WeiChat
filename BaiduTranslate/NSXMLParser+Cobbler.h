//
//  NSXMLParser+Cobbler.h
//  BaiduTranslate
//
//  Created by xy on 2016/11/11.
//  Copyright © 2016年 xy. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark -
#pragma mark XMLNode
@interface XMLNode : NSObject
{
@private
    
    NSString *_strNodeName;//结点名称
    NSDictionary *_dicAttributes;//结点属性
    NSMutableArray *_arrayChild;//子结点
    NSString *_strNodeValue;//结点值
    NSUInteger _nodeDepth;
    XMLNode *_nodeParent;//父结点
}

@property (nonatomic, copy) NSString *nodeName;
@property (nonatomic, copy) NSDictionary *nodeAttributesDict;
@property (nonatomic, readonly) NSArray *children;
@property (nonatomic, copy) NSString *nodeValue;
@property (nonatomic, readonly) NSUInteger nodeDepth;
@property (nonatomic, assign) XMLNode *nodeParent;

- (void)clear;

@end

#pragma mark -
#pragma mark NSXMLParser Cobbler

@interface NSXMLParser (Cobbler)

+ (XMLNode *)parseToXMLNode:(NSData *)dataXML;

@end
