//
//  CocosInspectorMethod.m
//  CocosInspector
//
//  Created by Kentaro Kumagai on 5/5/13.
//
//

#import "CocosInspectorMethod.h"
@interface CocosInspectorMethod ()
@property(nonatomic, readwrite) NSMutableDictionary *nodeCache;
@end

@implementation CocosInspectorMethod
- (id)init {
    if (self = [super init]) {
        self.nodeCache = [NSMutableDictionary dictionary];
    }
    return self;
}

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
    
    id nodeType = @(1);//node isKindOfClass:[CCScene class]] ? 9 : 1);
    NSString *xmlVersion = @"";
    
    NSNumber *nodeId = [NSNumber numberWithUnsignedLongLong:(unsigned long long)node];
    [self.nodeCache setObject:node forKey:nodeId];
    
    
    NSMutableArray *attributes = [NSMutableArray array];
    if (node.tag != -1) {
        [attributes addObject:@"tag"];
        [attributes addObject:[NSString stringWithFormat:@"%d", node.tag]];
    }
    
    id chromeNode = @{
                      @"attributes": attributes,
                      @"nodeId": nodeId,
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

-(NSNumber*)nodeIdOfCCNode:(CCNode*)node {
    NSNumber *nodeId = [NSNumber numberWithUnsignedLongLong:(unsigned long long)node];
    return nodeId;
}

-(id)notify:(id)message {
    NSData *data = [NSJSONSerialization dataWithJSONObject:message options:0 error:nil];
    // FIXME should send only to the correponding client
    [[BLWebSocketsServer sharedInstance] pushToAll:data];
    return nil;
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
