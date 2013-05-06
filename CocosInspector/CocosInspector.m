//
//  CocosInspector.m
//  CocosInspector
//
//  Created by Kentaro Kumagai on 5/5/13.
//
//

// http://stackoverflow.com/questions/7017281/performselector-may-cause-a-leak-because-its-selector-is-unknown
#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

#import "CocosInspector.h"
#import "BLWebSocketsServer.h"

@interface CocosInspector ()
@property(nonatomic, readwrite) NSMutableDictionary *methodCache;
@end

@implementation CocosInspector


- (id)initWithPort:(NSUInteger)port
{
    if ((self = [super init])) {
        [[BLWebSocketsServer sharedInstance] setHandleRequestBlock:^NSData *(NSData *data) {
            return [self  websocketCallback:data];
        }];
        
        [[BLWebSocketsServer sharedInstance] startListeningOnPort:port withProtocolName:nil andCompletionBlock:^(NSError *error) {
            if (error) {
                NSLog(@"BLWebSocketsServer failed to start %@", error);
            }
            else {
                NSLog(@"Server started");
            }
        }];

        self.methodCache = [NSMutableDictionary dictionary];
    }
    return self;
}

-(NSData*)websocketCallback:(NSData*)data {
    // dispatch
    {
        id request = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if (![request isKindOfClass:[NSDictionary class]]) {
            NSLog(@"invalid inspector request format");
            return nil;
        }
        id method = request[@"method"];
        if (![method isKindOfClass:[NSString class]]) {
            NSLog(@"invalid inspector method format");
            return nil;
        }
        
        NSString *errorMessage = nil;
        do {
            NSArray *inspectorMethodNameComponents = [method componentsSeparatedByString:@"."];
            if ([inspectorMethodNameComponents count] != 2) {
                errorMessage = [NSString stringWithFormat:@"invalid/unexpected inspector method name format %@", method];
                break;
            }
            
            NSString *klassName = [NSString stringWithFormat:@"%@%@", [self class], [inspectorMethodNameComponents objectAtIndex:0]];
            Class klass = NSClassFromString(klassName);
            if (!klass) {
                errorMessage = [NSString stringWithFormat:@"class not found %@", klassName];
                break;
            }

            id klassInstance;
            @synchronized(self.methodCache) {
                if ([self.methodCache objectForKey:klassName]) {
                    klassInstance = [self.methodCache objectForKey:klassName];
                } else {
                    klassInstance = [[klass alloc] init];
                    [self.methodCache setObject:klassInstance forKey:klassName];
                }
            }
            
            NSString *selectorName = [NSString stringWithFormat:@"%@:", [inspectorMethodNameComponents objectAtIndex:1]];
            SEL selector = NSSelectorFromString(selectorName);
            if (![klassInstance respondsToSelector:selector]) {
                errorMessage = [NSString stringWithFormat:@"method not implemented %@", method];
                break;
            }
            
            id params = request[@"params"];
            id response;

            SuppressPerformSelectorLeakWarning(
                response = [klassInstance performSelector:selector withObject:params];
            );
            
            response = [response mutableCopy];
            response[@"id"] = request[@"id"];
            response[@"method"] = request[@"method"];
            
            NSData *reply = [NSJSONSerialization dataWithJSONObject:response options:0 error:nil];
//            NSString *json = [[NSString alloc] initWithData:reply encoding:NSUTF8StringEncoding];
            
            return reply;
        } while (NO);
        
        NSLog(@"%@", errorMessage);
        NSDictionary *response = @{
                                   @"id": request[@"id"],
                                   @"method": request[@"method"],
                                   @"error": @{
                                           @"code": @(-32700),
                                           @"message":errorMessage
                                           }
                                   };
        NSData *reply = [NSJSONSerialization dataWithJSONObject:response options:0 error:nil];
        return reply;

    }
}

@end

