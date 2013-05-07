//
//  CocosInspectorDOM.m
//  CocosInspector
//
//  Created by Kentaro Kumagai on 5/5/13.
//
//

#import "CocosInspectorDOM.h"

@interface CocosInspectorDOM ()
@property(nonatomic, readwrite) NSString *undoCacheAction;
@property(nonatomic, readwrite) CCNode *undoCacheNode;
@property(nonatomic, readwrite) CCNode *undoCacheParentNode;
@property(nonatomic, readwrite) NSInteger undoCacheZOrder;

@end

@implementation CocosInspectorDOM



- (id)init
{
    if ((self = [super init])) {
        
    }
    return self;
}

-(id)removeNode:(id)params {
    id nodeId = params[@"nodeId"];
    CCNode *node = (CCNode*)objc_unretainedObject([nodeId unsignedLongLongValue]);

    if ([node respondsToSelector:@selector(removeFromParentAndCleanup:)]) {
        
        id parentNodeId = [self nodeIdOfCCNode:node.parent];
        self.undoCacheAction = @"remove";
        self.undoCacheNode = node;
        self.undoCacheZOrder = node.zOrder;
        self.undoCacheParentNode = node.parent;
        
        [node removeFromParentAndCleanup:NO];
        
        [self notify:@{
            @"method": @"DOM.childNodeRemoved",
            @"params": @{
                @"parentNodeId": parentNodeId,
                @"nodeId": nodeId
            }
         }];
        /*
        DOM.childNodeRemoved
        
        {
        }
*/
        
        
    } else {
        NSLog(@"%@ does not respond to removeFromParentAndCleanup:", node);
    }
    return [self successResult];
}

/*
   -(id)moveTo:(id)params {
  //        insertBeforeNodeId = 270855792;
  //        nodeId = 270842992;
  //        targetNodeId = 270841296;
  }
  */


-(id)getDocument:(id)params {
    CCDirector *director = [CCDirector sharedDirector];
    CCScene *scene = director.runningScene;
    
    id result = @{
                  @"result": @{
                          @"root": @{
//                                      @"attributes": @[],
                                      @"nodeId": @"",
                                      @"nodeType": @(9),
                                      @"nodeName": @"#root",
                                      @"localName": @"",
                                      @"nodeValue": @"",
                                      @"childNodeCount": @(1),
                                      @"children":  @[
                                              [self nodeWithCCNode:scene]
                                              ],
                                      @"documentURL": @"http://example.com/",
                                      @"baseURL": @"http://example.com/",
                                      @"xmlVersion": @"1.0"

                                  }
                              
                              
                              
                          }
                  };
    
    return result;
}

static CCNode *highlighter = nil;

-(id)hideHighlight:(id)params {
    return [self notImplemented];
}
-(id)highlightNode:(id)params {
    CCNode *node = [self nodeFromParams:params];
//    CGPoint p = [node convertToWorldSpace:CGPointMake(0, 0)];
//    ccDrawCircle(node.anchorPointInPoints, 20, 0, 8, YES);
    CGRect bounds = node.boundingBox;
    
    
    if (highlighter) {
        [highlighter removeFromParentAndCleanup:YES];
    }
    CCNodeRGBA *highlight = [CCLayerColor node];
    [highlight setColor:ccc3(128, 128, 255)];
    highlight.opacity = 192;
    highlight.zOrder = 10000;
    CGPoint origin = [node.parent convertToWorldSpace:bounds.origin];
//    bounds.size;
    
    CCScene *scene = [CCDirector sharedDirector].runningScene;
    origin.x = origin.x / scene.scale;
    origin.y = origin.y / scene.scale;
    highlight.position = origin;
    
    float scale = 1; //scene.scale;
    
    highlight.anchorPoint = node.anchorPoint;
    highlight.contentSize = CGSizeMake(
                                       node.contentSize.width / scale,
                                       node.contentSize.height  / scale
                                       );

//    sprite.contentSize = node.contentSize;
    NSLog(@"ANCHOR: %f, %f\nORIGIN: %f %f \nSIZE: %f, %f\n",
    highlight.anchorPoint.x,
          highlight.anchorPoint.y,
          origin.x, origin.y,
          highlight.contentSize.width,
          highlight.contentSize.height
          
          );
    
    [scene addChild:highlight];
    highlighter = highlight;
/*
 
    CGPoint sceneBottomRightPoint = [node convertToWorldSpace:CGPointMake(node.contentSize.width/2, node.contentSize.height/2)];
    CGSize sceneSize = CGSizeMake(sceneBottomRightPoint.x - sceneOrigin.x, sceneBottomRightPoint.y - sceneOrigin.y);
    
    // convert cocos2d coordinate to uikit coordinate
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGRect frame = CGRectMake(
                                          sceneOrigin.x,
                                          screenSize.height - (sceneSize.width + sceneOrigin.y),
                              sceneSize.width, sceneSize.height);
    
    
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = [UIColor redColor];
    [[UIApplication sharedApplication].keyWindow addSubview:view];
*/
    
    // CCSpriteBatchNode does not responds to setOpacity: and crash when the node is focused
/*
    if ([node conformsToProtocol:@protocol(CCRGBAProtocol)]) {
        [node runAction:[CCSequence actions:
                         [CCFadeOut actionWithDuration:0.05],
                         [CCFadeIn actionWithDuration:0.05],
                         [CCFadeOut actionWithDuration:0.05],
                         [CCFadeIn actionWithDuration:0.05],
                         [CCCallBlockN actionWithBlock:^(CCNode *node) {
            //
        }],
                         nil
                         ]];
    }
  */
    return [self emptyResult];
}

-(id)markUndoableState:(id)params {
    return [self emptyResult];
}

-(id)undo:(id)params {
    if ([self.undoCacheAction isEqualToString:@"remove"]) {
        [self.undoCacheParentNode addChild:self.undoCacheNode z:self.undoCacheZOrder];
        self.undoCacheAction = nil;
    }
    return [self emptyResult];
}

@end
