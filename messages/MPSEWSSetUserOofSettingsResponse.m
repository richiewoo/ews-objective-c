#import <Foundation/Foundation.h>

#import "../handlers/MPSEWSObjectTypeHandler.h"

#import "MPSEWSSetUserOofSettingsResponse.h"
#import "../messages/MPSEWSResponseMessageType.h"


@implementation MPSEWSSetUserOofSettingsResponse 

+ (void) initialize
{
    MPSEWSObjectTypeHandler* handler = [[MPSEWSObjectTypeHandler alloc] initWithClass:[MPSEWSSetUserOofSettingsResponse class]];

    [handler property      : @"responseMessage"
             withNamespace : 'm'
             withXmlTag    : @"ResponseMessage"
             withHandler   : [MPSEWSResponseMessageType class]];

    [handler register];
}

- (id) init
{
    return [super init];
}

- (Class) handlerClass
{
    return [MPSEWSSetUserOofSettingsResponse class];
}

- (NSString*) description
{
    return [NSString stringWithFormat:@"SetUserOofSettingsResponse: ResponseMessage=%@", _responseMessage];
}

@end
