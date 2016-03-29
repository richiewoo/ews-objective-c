#import <Foundation/Foundation.h>

#import "../handlers/MPSEWSObjectTypeHandler.h"

#import "MPSEWSSyncFolderHierarchyResponseMessageType.h"
#import "../handlers/MPSEWSBooleanTypeHandler.h"
#import "../handlers/MPSEWSIntegerTypeHandler.h"
#import "../handlers/MPSEWSStringTypeHandler.h"
#import "../messages/MPSEWSResponseCodeType.h"
#import "../types/MPSEWSResponseClassType.h"
#import "../types/MPSEWSSyncFolderHierarchyChangesType.h"


@implementation MPSEWSSyncFolderHierarchyResponseMessageType 

+ (void) initialize
{
    MPSEWSObjectTypeHandler* handler = [[MPSEWSObjectTypeHandler alloc] initWithClass:[MPSEWSSyncFolderHierarchyResponseMessageType class]];

    [handler property    : @"responseClass"
             withAttrTag : @"ResponseClass"
             withHandler : [MPSEWSResponseClassType class]];

    [handler property      : @"messageText"
             withNamespace : 'm'
             withXmlTag    : @"MessageText"
             withHandler   : [MPSEWSStringTypeHandler class]];

    [handler property      : @"responseCode"
             withNamespace : 'm'
             withXmlTag    : @"ResponseCode"
             withHandler   : [MPSEWSResponseCodeType class]];

    [handler property      : @"descriptiveLinkKey"
             withNamespace : 'm'
             withXmlTag    : @"DescriptiveLinkKey"
             withHandler   : [MPSEWSIntegerTypeHandler class]];

    [handler property      : @"messageXml"
             withNamespace : 'm'
             withXmlTag    : @"MessageXml"
             withHandler   : [MPSEWSStringTypeHandler class]];

    [handler property      : @"syncState"
             withNamespace : 'm'
             withXmlTag    : @"SyncState"
             withHandler   : [MPSEWSStringTypeHandler class]];

    [handler property      : @"includesLastFolderInRange"
             withNamespace : 'm'
             withXmlTag    : @"IncludesLastFolderInRange"
             withHandler   : [MPSEWSBooleanTypeHandler class]];

    [handler property      : @"changes"
             withNamespace : 'm'
             withXmlTag    : @"Changes"
             withHandler   : [MPSEWSSyncFolderHierarchyChangesType class]];

    [handler register];
}

- (id) init
{
    return [super init];
}

- (Class) handlerClass
{
    return [MPSEWSSyncFolderHierarchyResponseMessageType class];
}

- (NSString*) description
{
    return [NSString stringWithFormat:@"SyncFolderHierarchyResponseMessageType: SyncState=%@ IncludesLastFolderInRange=%@ Changes=%@ super=%@", _syncState, _includesLastFolderInRange, _changes, [super description]];
}

@end
