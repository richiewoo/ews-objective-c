#import <Foundation/Foundation.h>

#import "../handlers/MPSEWSObjectTypeHandler.h"

#import "MPSEWSPushSubscriptionRequestType.h"
#import "../handlers/MPSEWSStringTypeHandler.h"
#import "../types/MPSEWSNonEmptyArrayOfBaseFolderIdsType.h"
#import "../types/MPSEWSNonEmptyArrayOfNotificationEventTypesType.h"
#import "../types/MPSEWSSubscriptionStatusFrequencyType.h"
#import "../types/MPSEWSWatermarkType.h"


@implementation MPSEWSPushSubscriptionRequestType 

+ (void) initialize
{
    MPSEWSObjectTypeHandler* handler = [[MPSEWSObjectTypeHandler alloc] initWithClass:[MPSEWSPushSubscriptionRequestType class]];

    [handler property      : @"folderIds"
             withNamespace : 't'
             withXmlTag    : @"FolderIds"
             withHandler   : [MPSEWSNonEmptyArrayOfBaseFolderIdsType class]];

    [handler property      : @"eventTypes"
             withNamespace : 't'
             withXmlTag    : @"EventTypes"
             withHandler   : [MPSEWSNonEmptyArrayOfNotificationEventTypesType class]];

    [handler property      : @"watermark"
             withNamespace : 't'
             withXmlTag    : @"Watermark"
             withHandler   : [MPSEWSWatermarkType class]];

    [handler property      : @"statusFrequency"
             withNamespace : 't'
             withXmlTag    : @"StatusFrequency"
             withHandler   : [MPSEWSSubscriptionStatusFrequencyType class]];

    [handler property      : @"uRL"
             withNamespace : 't'
             withXmlTag    : @"URL"
             withHandler   : [MPSEWSStringTypeHandler class]];

    [handler register];
}

- (id) init
{
    return [super init];
}

- (Class) handlerClass
{
    return [MPSEWSPushSubscriptionRequestType class];
}

- (NSString*) description
{
    return [NSString stringWithFormat:@"PushSubscriptionRequestType: StatusFrequency=%@ URL=%@ super=%@", _statusFrequency, _uRL, [super description]];
}

@end
