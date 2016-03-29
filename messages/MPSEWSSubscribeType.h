#import <Foundation/Foundation.h>
#import "MPSEWSBaseRequestType.h"



@class MPSEWSPullSubscriptionRequestType;
@class MPSEWSPushSubscriptionRequestType;



/* SubscribeType */
@interface MPSEWSSubscribeType : MPSEWSBaseRequestType

+ (void) initialize;

- (id) init;
- (Class) handlerClass;
- (NSString*) description;

@property (strong) MPSEWSPullSubscriptionRequestType* pullSubscriptionRequest;
@property (strong) MPSEWSPushSubscriptionRequestType* pushSubscriptionRequest;


@end
