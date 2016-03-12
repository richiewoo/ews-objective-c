#import <Foundation/Foundation.h>

#import "EWSGuidType.h"
@implementation EWSGuidType /* SimpleType */

static NSString* pattern = nil;

+ (void) initialize
{
    pattern = @"[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}";
    [[[EWSGuidType alloc] init] register];
}

- (id) init
{
    self = [super initWithClass:[EWSGuidType class]];
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

- (BOOL) string:(NSString*) str hasPattern:(NSString*) p
{
    return TRUE;
}

- (void) writeXmlInto:(NSMutableString*)buffer for:(NSString *) object
{
    NSString* obj = ((NSString*) object);
    NSAssert([self string:obj hasPattern:pattern], @"String should have a pattern");
    [buffer appendString:obj];
}

@end

