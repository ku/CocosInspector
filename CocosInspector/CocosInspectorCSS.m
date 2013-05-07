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
        "position", "visible", "scale", "rotation", NULL
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

-(id)_cssPropertyWithName:(NSString*)name value:(NSString*)value {
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
                        name, @"name",
                        value, @"value",
                        [NSNumber numberWithBool:NO], @"implicit",
                        @"active", @"status",
                        nil
                    ];
}
-(id)_getInlineStylesForNode:(CCNode*)node {
    return @{
         @"cssProperties": @[
                    [self _cssPropertyWithName:@"position" value:[NSString stringWithFormat:@"%f %f", node.position.x, node.position.y]],
                    [self _cssPropertyWithName:@"scale"    value:[NSString stringWithFormat:@"%f", node.scale]],
                    [self _cssPropertyWithName:@"visible"  value:[NSString stringWithFormat:@"%d", node.visible]],
                    [self _cssPropertyWithName:@"rotation"  value:[NSString stringWithFormat:@"%f", node.rotation]],
                 ],
         @"shorthandEntries":@[],
         @"styleId": @{
                 @"ordinal": @0,
                 @"styleSheetId": [self nodeIdOfCCNode:node]
                 },
         };
}
-(id)getInlineStylesForNode:(id)params {
    CCNode *node = [self nodeFromParams:params];
    return @{
             @"result": @{
                     @"inlineStyle": [self _getInlineStylesForNode:node]
                    }
            };
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

-(id)styleWithName:(NSString*)name value:(NSString*)value node:(CCNode*)node {
    id style = [self _getInlineStylesForNode:node];
    for (id prop in style[@"result"][@"cssProperties"]) {
        if ([name isEqualToString:prop[@"name"]]) {
            prop[@"value"] = value;
            break;
        }
    }
    return @{
        @"result": @{
            @"style": style
        }
    };
}

-(id)setPropertyText:(id)params {
    NSString *text = params[@"text"];
    text = [[NSRegularExpression regularExpressionWithPattern:@";$" options:0 error:nil]
            stringByReplacingMatchesInString:text
            options:0
            range:NSMakeRange(0, [text length])
            withTemplate:@""];
    text = [[NSRegularExpression regularExpressionWithPattern:@"(\\s+)" options:0 error:nil]
            stringByReplacingMatchesInString:text
            options:0
            range:NSMakeRange(0, [text length])
            withTemplate:@" "];
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"([a-z_-]+)\\s*:\\s*(.+)" options:0 error:nil];
    NSTextCheckingResult *match = [regex firstMatchInString:text options:0 range:NSMakeRange(0, text.length)];
    if (match) {
        NSString *name = [text substringWithRange:[match rangeAtIndex:1]];
        NSString *value = [text substringWithRange:[match rangeAtIndex:2]];
        
        NSArray *args = [value componentsSeparatedByString:@" "];
        
        if ([args count] >= 1) {
            CCNode *node = [self nodeFromParams:params];
            
            if ([name isEqualToString:@"position"]) {
                if ([args count] >= 2) {
                    NSString *x = [args objectAtIndex:0];
                    NSString *y = [args objectAtIndex:1];
                    
                    node.position = ccp([x floatValue], [y floatValue]);
                    return [self styleWithName:name value:value node:node];
                }
            } else if ([name isEqualToString:@"scale"]) {
                if ([args count] >= 1) {
                    NSString *scale = [args objectAtIndex:0];
                    
                    node.scale = [scale floatValue];
                    return [self styleWithName:name value:value node:node];
                }
                
            } else if ([name isEqualToString:@"visible"]) {
                id value = [args objectAtIndex:0];
                node.visible = [value intValue];
                return [self styleWithName:name value:value node:node];
            } else if ([name isEqualToString:@"rotation"]) {
                id value = [args objectAtIndex:0];
                node.rotation = [value floatValue];
                return [self styleWithName:name value:value node:node];
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
