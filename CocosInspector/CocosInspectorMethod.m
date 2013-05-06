//
//  CocosInspectorMethod.m
//  CocosInspector
//
//  Created by Kentaro Kumagai on 5/5/13.
//
//

#import "CocosInspectorMethod.h"

@implementation CocosInspectorMethod

- (id)nodeWithCCNode:(CCNode*)node {
    id klass = [node class];
    NSString *className = [klass description];
    
    CCArray *children = [node children];
    NSMutableArray *childNodes = [NSMutableArray array];
    
    if ([children count] > 0) {
        for (id child in children) {
            [childNodes addObject:[self nodeWithCCNode:child]];
        }
    }
    
    id nodeType = @([node isKindOfClass:[CCScene class]] ? 9 : 1);
    NSString *xmlVersion = @"";
    if ( [node isKindOfClass:[CCScene class]]) {
        className = @"#document";
        xmlVersion = @"1.0";
    }
    
    id chromeNode = @{
                      @"nodeId": [NSNumber numberWithUnsignedLongLong:(unsigned long long)node],
                      @"nodeType": nodeType,
                      @"nodeName": className,
                      @"localName": @"",
                      @"nodeValue": @"",
                      @"childNodeCount": @([children count]),
                      @"children":  childNodes,
                      @"documentURL": @"http://example.com/",
                      @"baseURL": @"http://example.com/",
                      @"xmlVersion": xmlVersion
                      };
    
    return chromeNode;
}

-(CCNode*)nodeFromParams:(id)params {
    id nodeId = params[@"nodeId"];
    if (!nodeId) {
        nodeId = params[@"styleId"][@"styleSheetId"];
    }
    CCNode *node = (CCNode*)objc_unretainedObject([nodeId unsignedLongLongValue]);
    return node;
}


-(id)successResult {
    return [self emptyResult];
}
-(id)emptyResult {
    return @{
             @"result": @{}
             };
}
-(id)notImplemented {
    return @{};
}

@end
