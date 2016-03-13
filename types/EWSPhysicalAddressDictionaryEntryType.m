#import <Foundation/Foundation.h>

#import "../handlers/EWSObjectTypeHandler.h"

#import "EWSPhysicalAddressDictionaryEntryType.h"


@implementation EWSPhysicalAddressDictionaryEntryType 

+ (void) initialize
{
    EWSObjectTypeHandler* handler = [[EWSObjectTypeHandler alloc] initWithClass:[EWSPhysicalAddressDictionaryEntryType class]];

    [handler property    : @"key"
             isRequired  : TRUE
             withAttrTag : @"Key"
             withHandler : [EWSPhysicalAddressKeyType class]];

    [handler property   : @"street"
             isRequired : FALSE
             withXmlTag : @"Street"
             withHandler: [EWSStringTypeHandler class]];

    [handler property   : @"city"
             isRequired : FALSE
             withXmlTag : @"City"
             withHandler: [EWSStringTypeHandler class]];

    [handler property   : @"state"
             isRequired : FALSE
             withXmlTag : @"State"
             withHandler: [EWSStringTypeHandler class]];

    [handler property   : @"countryOrRegion"
             isRequired : FALSE
             withXmlTag : @"CountryOrRegion"
             withHandler: [EWSStringTypeHandler class]];

    [handler property   : @"postalCode"
             isRequired : FALSE
             withXmlTag : @"PostalCode"
             withHandler: [EWSStringTypeHandler class]];

    [handler register];
}

- (id) init
{
    return [super init];
}

- (Class) handlerClass
{
    return [EWSPhysicalAddressDictionaryEntryType class];
}

- (NSString*) description
{
    return [NSString stringWithFormat:@"PhysicalAddressDictionaryEntryType: Key=%@ Street=%@ City=%@ State=%@ CountryOrRegion=%@ PostalCode=%@", _key, _street, _city, _state, _countryOrRegion, _postalCode];
}

@end
