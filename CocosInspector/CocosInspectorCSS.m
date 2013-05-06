//
//  CocosInspectorCSS.m
//  CocosInspector
//
//  Created by Kentaro Kumagai on 5/5/13.
//
//

#import "CocosInspectorCSS.h"

@implementation CocosInspectorCSS

-(id)getComputedStyleForNode:(id)params {
    return @{
             @"result": @{
                     @"computedStyle": @[
                             /*
                             @{
                                 @"name": @"color",
                                 @"value":@"red"
                                 },
                             @{
                                 @"name": @"width",
                                 @"value":@"100px"
                                 },
                             @{
                                 @"name": @"height",
                                 @"value":@"100px"
                                 },
                              */
                             ]
                     }
             };
    
}

-(id)getSupportedCSSProperties:(id)params {
    const char* supported_properties[] = {
        "position", "visible", "scale", NULL
    };
    
    NSMutableArray *properties = [NSMutableArray arrayWithCapacity:sizeof(supported_properties)];
    const char **p = supported_properties;
    do {
        NSString *name = [NSString stringWithCString:*p encoding:NSASCIIStringEncoding];
        [properties addObject:@{
         @"name": name
         }];
    } while (*++p);
    return @{
             @"result": @{
                     @"cssProperties": properties
                     }
             };
};
-(id)getInlineStylesForNode:(id)params {
    CCNode *node = [self nodeFromParams:params];
    return @{
             @"result": @{
                     @"inlineStyle": @{
                             @"cssProperties": @[
                                        @{
                                            @"name": @"position" ,
                                            @"value": [NSString stringWithFormat:@"%f %f", node.position.x, node.position.y],
                                            @"implicit": [NSNumber numberWithBool:NO],
                                            @"status": @"active",
                                        },
                                        @{
                                            @"name": @"scale" ,
                                            @"value": [NSString stringWithFormat:@"%f", node.scaleX],
                                            @"implicit": [NSNumber numberWithBool:NO],
                                            @"status": @"active",
                                        },
                                        @{
                                            @"name": @"visible" ,
                                            @"value": [NSString stringWithFormat:@"%d", node.visible],
                                            @"implicit": [NSNumber numberWithBool:NO],
                                            @"status": @"active",
                                        },
                                     ],
                             @"shorthandEntries":@[],
                             @"styleId": @{
                                     @"ordinal": @0,
                                     @"styleSheetId": params[@"nodeId"]
                                     },
                             }
                     }
             };
    
    /*
     {
     "result": {
     "inlineStyle": {
     "cssProperties": [
     {
     "name": "color",
     "value": "red",
     "text": "color: red;",
     "range": {
     "startLine": 1,
     "startColumn": 4,
     "endLine": 1,
     "endColumn": 15
     },
     "implicit": false,
     "status": "active"
     }
     ],
     "shorthandEntries": [],
     "styleId": {
     "styleSheetId": "1",
     "ordinal": 0
     },
     "width": "",
     "height": "",
     "range": {
     "startLine": 0,
     "startColumn": 0,
     "endLine": 2,
     "endColumn": 0
     },
     "cssText": "\n    color: red;\n"
     }
     },
     "id": 112
     }
     */
}


-(id)enable:(id)params {
    return [self emptyResult];
}


// put to suppress annoying error messages
-(id)getMatchedStylesForNode:(id)params {
    return @{
             @"result": @{
                     @"inherited": @[],
                     @"matchedCSSRules": @[],
                     @"pseudoElements": @[]
                     }
             };
}

-(id)setPropertyText:(id)params {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"([a-z_-]+)\\s*:\\s*(\\S+)\\s*(\\S+)?" options:0 error:nil];
    NSString *text = params[@"text"];
    NSTextCheckingResult *match = [regex firstMatchInString:text options:0 range:NSMakeRange(0, text.length)];
    if (match) {
        NSMutableArray *args = [[NSMutableArray alloc] initWithCapacity:match.numberOfRanges];
        for (int i = 1; i < regex.numberOfCaptureGroups; i++) {
            NSString *value = [text substringWithRange:[match rangeAtIndex:i]];
            if (value) {
                [args addObject:value];
            }
        }

        NSString *name = nil;
        if ([args count] < 2) {
            if ([args count] == 1) {
                name = [args objectAtIndex:0];
            }
        } else {
            CCNode *node = [self nodeFromParams:params];
            
            name = [args objectAtIndex:0];
            [args removeObjectAtIndex:0];
            
            if ([name isEqualToString:@"position"]) {
                if ([args count] >= 2) {
                    NSString *x = [args objectAtIndex:0];
                    NSString *y = [args objectAtIndex:1];
                    
                    node.position = ccp([x floatValue], [y floatValue]);
                    return [self emptyResult];
                }
            } else if ([name isEqualToString:@"scale"]) {
                if ([args count] >= 1) {
                    NSString *scale = [args objectAtIndex:0];
                    
                    node.scale = [scale floatValue];
                    return [self emptyResult];
                }
                
            } else if ([name isEqualToString:@"visible"]) {
                id value = [args objectAtIndex:0];
                node.visible = [value intValue];
                return [self emptyResult];
            } else {
                return @{
                         @"error": @{
                                 @"message": [NSString stringWithFormat:@"unknown property %@", name]
                                 }
                         
                         };
            }
        }
        
        return @{
                 @"error": @{
                         @"message": [NSString stringWithFormat:@"invalid arguments %@", name]
                         }
                 
                 };
        

    }
    
    return [self emptyResult];
}
@end
