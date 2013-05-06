//
//  CocosInspectorDOM.m
//  CocosInspector
//
//  Created by Kentaro Kumagai on 5/5/13.
//
//

#import "CocosInspectorDOM.h"

@implementation CocosInspectorDOM

-(id)removeNode:(id)params {
    id nodeId = params[@"nodeId"];
    CCNode *node = (CCNode*)objc_unretainedObject([nodeId unsignedLongLongValue]);

    [node removeFromParent];
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
                          @"root": [self nodeWithCCNode:scene]
                          }
                  };
    
    return result;
}

-(id)hideHighlight:(id)params {
    return [self notImplemented];
}
-(id)highlightNode:(id)params {
    CCNode *node = [self nodeFromParams:params];
/*
 
    CGPoint sceneOrigin = [node convertToWorldSpace:CGPointMake(-node.contentSize.width/2, -node.contentSize.height/2)];
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

    return [self emptyResult];
}

-(id)markUndoableState:(id)params {
    return [self emptyResult];
}

@end
