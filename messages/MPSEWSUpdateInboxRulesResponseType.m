#import <Foundation/Foundation.h>

#import "../handlers/MPSEWSObjectTypeHandler.h"

#import "MPSEWSUpdateInboxRulesResponseType.h"
#import "../handlers/MPSEWSIntegerTypeHandler.h"
#import "../handlers/MPSEWSStringTypeHandler.h"
#import "../messages/MPSEWSResponseCodeType.h"
#import "../types/MPSEWSArrayOfRuleOperationErrorsType.h"
#import "../types/MPSEWSResponseClassType.h"


@implementation MPSEWSUpdateInboxRulesResponseType 

+ (void) initialize
{
    MPSEWSObjectTypeHandler* handler = [[MPSEWSObjectTypeHandler alloc] initWithClass:[MPSEWSUpdateInboxRulesResponseType class]];

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

    [handler property      : @"ruleOperationErrors"
             withNamespace : 'm'
             withXmlTag    : @"RuleOperationErrors"
             withHandler   : [MPSEWSArrayOfRuleOperationErrorsType class]];

    [handler register];
}

+ (BOOL) isValid:(MPSEWSUpdateInboxRulesResponseType*) val
{   (void) val;
    if (![MPSEWSResponseMessageType isValid:val]) return FALSE;
    if ([val ruleOperationErrors] && ![MPSEWSArrayOfRuleOperationErrorsType isValid:[val ruleOperationErrors]]) return FALSE;
    return TRUE;
}

- (id) init
{
    return [super init];
}

- (Class) handlerClass
{
    return [MPSEWSUpdateInboxRulesResponseType class];
}

- (NSString*) description
{
    return [NSString stringWithFormat:@"UpdateInboxRulesResponseType: RuleOperationErrors=%@ super=%@", _ruleOperationErrors, [super description]];
}

@end
