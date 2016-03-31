#import <Foundation/Foundation.h>

#import "../handlers/MPSEWSObjectTypeHandler.h"

#import "MPSEWSEmailAddressDictionaryEntryType.h"
#import "../handlers/MPSEWSStringTypeHandler.h"
#import "../types/MPSEWSEmailAddressKeyType.h"
#import "../types/MPSEWSMailboxTypeType.h"


@implementation MPSEWSEmailAddressDictionaryEntryType 

+ (void) initialize
{
    MPSEWSObjectTypeHandler* handler = [[MPSEWSObjectTypeHandler alloc] initWithClass:[MPSEWSEmailAddressDictionaryEntryType class] andContentHandlerClass:[MPSEWSStringTypeHandler class]];

    [handler property    : @"key"
             withAttrTag : @"Key"
             withHandler : [MPSEWSEmailAddressKeyType class]];

    [handler property    : @"name"
             withAttrTag : @"Name"
             withHandler : [MPSEWSStringTypeHandler class]];

    [handler property    : @"routingType"
             withAttrTag : @"RoutingType"
             withHandler : [MPSEWSStringTypeHandler class]];

    [handler property    : @"mailboxType"
             withAttrTag : @"MailboxType"
             withHandler : [MPSEWSMailboxTypeType class]];

    [handler register];
}

+ (BOOL) isValid:(MPSEWSEmailAddressDictionaryEntryType*) val
{   (void) val;
    if (![MPSEWSStringType isValid:val]) return FALSE;
    if ([val key ] && ![MPSEWSEmailAddressKeyType isValid:[val key ]]) return FALSE;
    if ([val name] && ![MPSEWSStringTypeHandler isValid:[val name]]) return FALSE;
    if ([val routingType] && ![MPSEWSStringTypeHandler isValid:[val routingType]]) return FALSE;
    if ([val mailboxType] && ![MPSEWSMailboxTypeType isValid:[val mailboxType]]) return FALSE;
    return TRUE;
}

- (id) init
{
    return [super init];
}

- (Class) handlerClass
{
    return [MPSEWSEmailAddressDictionaryEntryType class];
}

- (NSString*) description
{
    return [NSString stringWithFormat:@"EmailAddressDictionaryEntryType: Key=%@ Name=%@ RoutingType=%@ MailboxType=%@ super=%@", _key, _name, _routingType, _mailboxType, [super description]];
}

@end

