#import <Foundation/Foundation.h>

#import "EWSDayOfWeekIndexType.h"
@implementation EWSDayOfWeekIndexType /* SimpleType */

static NSSet* enumerations = nil;

+ (void) initialize
{
    enumerations = [NSSet setWithObjects:
                                         [EWSDayOfWeekIndexType First], 
                                         [EWSDayOfWeekIndexType Second], 
                                         [EWSDayOfWeekIndexType Third], 
                                         [EWSDayOfWeekIndexType Fourth], 
                                         [EWSDayOfWeekIndexType Last], nil];
    [[[EWSDayOfWeekIndexType alloc] init] register];
}

- (id) init
{
    self = [super initWithClass:[EWSDayOfWeekIndexType class]];
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

+ (NSString *) First { return @"First"; }
+ (NSString *) Second { return @"Second"; }
+ (NSString *) Third { return @"Third"; }
+ (NSString *) Fourth { return @"Fourth"; }
+ (NSString *) Last { return @"Last"; }
@end

