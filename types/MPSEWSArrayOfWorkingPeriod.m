#import <Foundation/Foundation.h>

#import "../handlers/MPSEWSObjectTypeHandler.h"

#import "MPSEWSArrayOfWorkingPeriod.h"
#import "../types/MPSEWSWorkingPeriod.h"


@implementation MPSEWSArrayOfWorkingPeriod 

+ (void) initialize
{
    MPSEWSObjectTypeHandler* handler = [[MPSEWSObjectTypeHandler alloc] initWithClass:[MPSEWSArrayOfWorkingPeriod class]];

    [handler listProperty  : @"workingPeriod"
             useSelector   : @"addWorkingPeriod"
             withNamespace : 't'
             withXmlTag    : @"WorkingPeriod"
             withHandler   : [MPSEWSWorkingPeriod class]];

    [handler register];
}

- (id) init
{
    return [super init];
}

- (Class) handlerClass
{
    return [MPSEWSArrayOfWorkingPeriod class];
}

- (NSString*) description
{
    return [NSString stringWithFormat:@"ArrayOfWorkingPeriod: WorkingPeriod=%@", _workingPeriod];
}

- (void) addWorkingPeriod:(MPSEWSWorkingPeriod*) elem
{
    if (![self workingPeriod]) {
        [self setWorkingPeriod:[[NSMutableArray<MPSEWSWorkingPeriod*> alloc] init]];
    }
    [_workingPeriod addObject:elem];
}

@end
