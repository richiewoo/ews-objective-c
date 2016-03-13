
#import "EWSImAddressDictionaryType.h"


@implementation EWSImAddressDictionaryType 

+ (void) initialize
{
    EWSArrayTypeHandler* handler = [[EWSImAddressDictionaryType alloc] initWithClass:[EWSImAddressDictionaryType class]];

    [handler elementName : @"Entry"
             withHandler : [EWSImAddressDictionaryEntryType class]];

    [handler register];
}

- (id) init
{
    return [super init];
}

@end
