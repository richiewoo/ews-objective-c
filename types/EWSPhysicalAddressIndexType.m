#import <Foundation/Foundation.h>

#import "EWSPhysicalAddressIndexType.h"
@implementation EWSPhysicalAddressIndexType /* SimpleType */

static NSSet* enumerations = nil;

+ (void) initialize
{
    enumerations = [NSSet setWithObjects:
                                         [EWSPhysicalAddressIndexType None], 
                                         [EWSPhysicalAddressIndexType Business], 
                                         [EWSPhysicalAddressIndexType Home], 
                                         [EWSPhysicalAddressIndexType Other], nil];
    [[[EWSPhysicalAddressIndexType alloc] init] register];
}

- (id) init
{
    self = [super initWithClass:[EWSPhysicalAddressIndexType class]];
    return self;
}

- (id) initWithClass:(Class) cls
{
    self = [super initWithClass:cls];
    return self;
}

- (NSString *) updateObject:(NSString *)obj withCharacters:(NSString*) s
{
    s = [s stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return [enumerations containsObject:s] ? [enumerations member:s] : obj;
}

- (void) writeXmlInto:(NSMutableString*)buffer for:(NSString *) object
{
    NSString* obj = ((NSString*) object);
    NSAssert([enumerations containsObject:obj], @"String is a enumerated list");
    [buffer appendString:((NSString*) object)];
}

+ (NSString *) None { return @"None"; }
+ (NSString *) Business { return @"Business"; }
+ (NSString *) Home { return @"Home"; }
+ (NSString *) Other { return @"Other"; }
@end

