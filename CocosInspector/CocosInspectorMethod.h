//
//  CocosInspectorMethod.h
//  CocosInspector
//
//  Created by Kentaro Kumagai on 5/5/13.
//
//

#import "cocos2d.h"

@interface CocosInspectorMethod : NSObject
- (id)nodeWithCCNode:(CCNode*)node ;
-(CCNode*)nodeFromParams:(id)params ;

-(id)successResult ;
-(id)emptyResult ;
-(id)notImplemented ;

@end
