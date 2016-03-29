#import <Foundation/Foundation.h>

#import "../handlers/MPSEWSObjectTypeHandler.h"

#import "MPSEWSDailyRecurrencePatternType.h"
#import "../handlers/MPSEWSIntegerTypeHandler.h"


@implementation MPSEWSDailyRecurrencePatternType 

+ (void) initialize
{
    MPSEWSObjectTypeHandler* handler = [[MPSEWSObjectTypeHandler alloc] initWithClass:[MPSEWSDailyRecurrencePatternType class]];

    [handler property      : @"interval"
             withNamespace : 't'
             withXmlTag    : @"Interval"
             withHandler   : [MPSEWSIntegerTypeHandler class]];

    [handler register];
}

- (id) init
{
    return [super init];
}

- (Class) handlerClass
{
    return [MPSEWSDailyRecurrencePatternType class];
}

- (NSString*) description
{
    return [NSString stringWithFormat:@"DailyRecurrencePatternType: super=%@", [super description]];
}

@end
