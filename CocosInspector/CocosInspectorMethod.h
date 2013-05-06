//
//  CocosInspectorMethod.h
//  CocosInspector
//
//  Created by Kentaro Kumagai on 5/5/13.
//
//

#import "cocos2d.h"
#import "BLWebSocketsServer.h"

@interface CocosInspectorMethod : NSObject
- (id)nodeWithCCNode:(CCNode*)node ;
-(CCNode*)nodeFromParams:(id)params ;
-(id)notify:(id)message ;
-(NSString*)nodeIdOfCCNode:(CCNode*)node ;

-(id)successResult ;
-(id)emptyResult ;
-(id)notImplemented ;

@end
