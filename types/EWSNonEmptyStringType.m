#import <Foundation/Foundation.h>

#import "EWSNonEmptyStringType.h"
@implementation EWSNonEmptyStringType /* SimpleType */

static int minLength = 1;

+ (void) initialize
{
    [[[EWSNonEmptyStringType alloc] init] register];
}

- (id) init
{
    self = [super initWithClass:[EWSNonEmptyStringType class]];
    return self;
}

- (id) initWithClass:(Class) cls
{
    self = [super initWithClass:cls];
    return self;
}

- (NSString *) construct
{
    return [[NSString alloc] init];
}

- (NSString *) updateObject:(NSString *)obj withCharacters:(NSString*) s
{
    s = [s stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return [s length] > 0 ? s : obj;
}

- (void) writeXmlInto:(NSMutableString*)buffer for:(NSString *) object
{
    NSString* obj = ((NSString*) object);
    NSAssert([obj length] >= minLength, @"String should have a min length");
    [buffer appendString:obj];
}

@end
