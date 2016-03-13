#import <Foundation/Foundation.h>
#import "generator.h"


@implementation Element
{
}

static char dns = 't';
static NSMutableArray* array;
+ (NSMutableArray*) ignore
{
    if (array == nil)
    {
        array = [[NSMutableArray alloc] init];
        [array addObject:@"annotation"];
    }
    return array;
}

- (NSMutableArray*) m_children
{
    return children;
}

-(NSString*) description
{
    return [NSString stringWithFormat:@"%@ %@ of type (%@)  with %lu children", _tagName, _name ? _name : @"-", [self type] ? [self type] : @".", [[self children] count]];
}

- (id) initWithParent:(Element*) parent andName:(NSString*) name
{
    self = [super init];
    children = [[NSMutableArray alloc] init];

    [ self setParent : parent ];
    [ self setTagName: name   ];

    if (parent) {
        if (![[Element ignore] containsObject:name]) {
            [[parent m_children] addObject:self];
        }
    }
    else {
        [ self setParent : self];
    }
    _ns  = dns;
    return self;
}

 - (NSArray*) children 
 {
    return children;
 }

@end

@implementation Generator
{
    NSXMLParser* parser;
    Element*     current;
    Element*     types;
}

static const char * dir;

- (void)parser:(NSXMLParser*)parser didStartElement:(NSString*)elementName namespaceURI:(NSString*)namespaceURI qualifiedName:(NSString*)qName attributes:(NSDictionary *) attributeDict
{
    current = [[Element alloc] initWithParent: current andName:elementName];
    for (NSString *attr in attributeDict) {
        [current setValue:[attributeDict objectForKey: attr] forKey:attr];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
     //   NSLog(@"%@", string);
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    current = [current parent];
}

- (void) parser:(NSXMLParser *)parser didStartMappingPrefix:(NSString *)prefix toURI:(NSString *)namespaceURI 
{
    NSLog (@"Start mapping %@ %@", prefix, namespaceURI);
}

- (void)parser:(NSXMLParser *)parser didEndMappingPrefix:(NSString *)prefix
{
    NSLog (@"End mapping %@", prefix);
}

- (id) initWithFile:(NSString*) filename
{
    self = [super init];

    dir = "types";
    current = nil;
    parser  = [[NSXMLParser alloc] initWithStream: [[NSInputStream alloc] initWithFileAtPath: filename]];

    [parser setShouldProcessNamespaces:TRUE];
    [parser setShouldReportNamespacePrefixes:TRUE];

    [parser setDelegate: self];
    [self parse];
    [self generate];

    return self;
}

- (void) parse
{
    [parser parse];
}

- (BOOL) forElement:(Element*) elem areChildren:(NSString*) list
{
    BOOL result = false;
    NSArray *names = [list componentsSeparatedByString:@","];
    for (Element *e in [elem children]) {
        result = TRUE;
        bool found = FALSE;
        for (NSString* n in names) {
            found = found || [[e tagName] isEqual:n];
        }
        if (!found) 
        {
            return FALSE;
        }
    }
    return result;
}

static const char* prefix = "EWS";

- (void) patternString:(Element*) elem
{
    char const* returnType = "NSString *";
    NSString* pattern = nil;

    Element* child = [[elem children] objectAtIndex: 0];
    for (Element *e in [child children])
    {
        pattern = [e value];
    }

    const char* name = [[elem name] UTF8String];

    char filename[1024];
    sprintf (filename, "%s/%s%s.h", dir, prefix, name);
    
    FILE* file = fopen (filename, "w");
    fprintf (file, "#import <Foundation/Foundation.h>\n\n"); 
    fprintf (file, "#import \"../handlers/%sSimpleTypeHandler.h\"", prefix);
    fprintf (file, "\n\n\n");
    fprintf (file, "/** SimpleType: %s is a regex %s string */\n", name, [pattern UTF8String]);

    fprintf (file, "@interface %s%s : %sSimpleTypeHandler \n\n", prefix, name, prefix);
   
    fprintf (file, "/** Register a handler to parse %s */\n", name);
    fprintf (file, "+ (void) initialize;\n\n");

    fprintf (file, "/** Initialize the handler */\n");
    fprintf (file, "- (id) init;\n");
    fprintf (file, "- (id) initWithClass:(Class) cls;\n\n");

    fprintf (file, "/** Construct the object */\n");
    fprintf (file, "- (%s) construct;\n\n", returnType);

    fprintf (file, "/** Process the characters */\n");
    fprintf (file, "- (%s) updateObject:(%s)obj withCharacters:(NSString*)s;\n\n", returnType, returnType);
    
    fprintf (file, "/** Write to the buffer the string value */\n");
    fprintf (file, "- (void) writeXmlInto:(NSMutableString*)buffer for:(%s) object;\n\n", returnType);
    
    fprintf (file, "@end\n\n");
    fclose (file);

    sprintf (filename, "%s/%s%s.m", dir,  prefix, name);
    
    file = fopen (filename, "w");
    fprintf (file, "#import <Foundation/Foundation.h>\n\n"); 
    fprintf (file, "#import \"%s%s.h\"", prefix, name);
    fprintf (file, "\n");
    fprintf (file, "@implementation %s%s /* SimpleType */\n\n", prefix, name);

    fprintf (file, "static NSString* pattern = nil;\n\n");
    
    fprintf (file, "+ (void) initialize\n");
    fprintf (file, "{\n");
    fprintf (file, "    pattern = @\"%s\";\n", [pattern UTF8String]);
    fprintf (file, "    [[[%s%s alloc] init] register];\n", prefix, name);
    fprintf (file, "}\n\n");

    fprintf (file, "- (id) init\n");
    fprintf (file, "{\n");
    fprintf (file, "    self = [super initWithClass:[%s%s class]];\n", prefix, name);
    fprintf (file, "    return self;\n");
    fprintf (file, "}\n\n");

    fprintf (file, "- (id) initWithClass:(Class) cls\n");
    fprintf (file, "{\n");
    fprintf (file, "    self = [super initWithClass:cls];\n");
    fprintf (file, "    return self;\n");
    fprintf (file, "}\n\n");

    fprintf (file, "- (%s) construct\n", returnType);
    fprintf (file, "{\n");
    fprintf (file, "    return [[NSString alloc] init];\n");
    fprintf (file, "}\n\n");

    fprintf (file, "- (%s) updateObject:(%s)obj withCharacters:(NSString*) s\n", returnType, returnType);
    fprintf (file, "{\n");
    fprintf (file, "    s = [s stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];\n");
    fprintf (file, "    return [s length] > 0 ? s : obj;\n");
    fprintf (file, "}\n\n");

    fprintf (file, "- (BOOL) string:(NSString*) str hasPattern:(NSString*) p\n");
    fprintf (file, "{\n");
    fprintf (file, "    return TRUE;\n");
    fprintf (file, "}\n\n");
   
    fprintf (file, "- (void) writeXmlInto:(NSMutableString*)buffer for:(%s) object\n", returnType);
    fprintf (file, "{\n");
    fprintf (file, "    NSString* obj = ((NSString*) object);\n");
    fprintf (file, "    NSAssert([self string:obj hasPattern:pattern], @\"String should have a pattern\");\n");
    fprintf (file, "    [buffer appendString:obj];\n"); 
    fprintf (file, "}\n\n");
    
    fprintf (file, "@end\n\n");
    fclose (file);
}

-(void) simpleString:(Element*) elem
{
    char const* returnType = "NSString *";
    const char* name = [[elem name] UTF8String];

    char filename[1024];
    sprintf (filename, "%s/%s%s.h", dir, prefix, name);
    
    FILE* file = fopen (filename, "w");
    fprintf (file, "#import <Foundation/Foundation.h>\n\n"); 
    fprintf (file, "#import \"../handlers/%sSimpleTypeHandler.h\"", prefix);
    fprintf (file, "\n\n\n");
    fprintf (file, "/** SimpleType: %s is string  */\n", name);

    fprintf (file, "@interface %s%s : %sSimpleTypeHandler \n\n", prefix, name, prefix);
   
    fprintf (file, "/** Register a handler to parse %s */\n", name);
    fprintf (file, "+ (void) initialize;\n\n");

    fprintf (file, "/** Initialize the handler */\n");
    fprintf (file, "- (id) init;\n");
    fprintf (file, "- (id) initWithClass:(Class) cls;\n\n");

    fprintf (file, "/** Process the characters */\n");
    fprintf (file, "- (%s) updateObject:(%s)obj withCharacters:(NSString*)s;\n\n", returnType, returnType);
    
    fprintf (file, "/** Write to the buffer the string value */\n");
    fprintf (file, "- (void) writeXmlInto:(NSMutableString*)buffer for:(%s) object;\n\n", returnType);
    
    fprintf (file, "@end\n\n");
    fclose (file);

    sprintf (filename, "%s/%s%s.m", dir, prefix, name);
    
    file = fopen (filename, "w");
    fprintf (file, "#import <Foundation/Foundation.h>\n\n"); 
    fprintf (file, "#import \"%s%s.h\"", prefix, name);
    fprintf (file, "\n");
    fprintf (file, "@implementation %s%s /* SimpleType */\n\n", prefix, name);

    
    fprintf (file, "+ (void) initialize\n");
    fprintf (file, "{\n");
    fprintf (file, "    [[[%s%s alloc] init] register];\n", prefix, name);
    fprintf (file, "}\n\n");

    fprintf (file, "- (id) init\n");
    fprintf (file, "{\n");
    fprintf (file, "    self = [super initWithClass:[%s%s class]];\n", prefix, name);
    fprintf (file, "    return self;\n");
    fprintf (file, "}\n\n");

    fprintf (file, "- (id) initWithClass:(Class) cls\n");
    fprintf (file, "{\n");
    fprintf (file, "    self = [super initWithClass:cls];\n");
    fprintf (file, "    return self;\n");
    fprintf (file, "}\n\n");

    fprintf (file, "- (%s) construct\n", returnType);
    fprintf (file, "{\n");
    fprintf (file, "    return [[NSString alloc] init];\n");
    fprintf (file, "}\n\n");

    fprintf (file, "- (%s) updateObject:(%s)obj withCharacters:(NSString*) s\n", returnType, returnType);
    fprintf (file, "{\n");
    fprintf (file, "    s = [s stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];\n");
    fprintf (file, "    return [s length] > 0 ? s : obj;\n");
    fprintf (file, "}\n\n");
   
    fprintf (file, "- (void) writeXmlInto:(NSMutableString*)buffer for:(%s) object\n", returnType);
    fprintf (file, "{\n");
    fprintf (file, "    NSString* obj = ((NSString*) object);\n");
    fprintf (file, "    [buffer appendString:obj];\n"); 
    fprintf (file, "}\n\n");
    
    fprintf (file, "@end\n\n");
    fclose (file);
}

- (void) simpleMinMaxInt:(Element*) elem
{
    char const* returnType = "NSNumber *";
    NSString* min = nil;
    NSString* max = nil;

    Element* child = [[elem children] objectAtIndex: 0];
    for (Element *e in [child children])
    {
        min = [[e tagName] isEqual:@"minInclusive"] ? [e value] : min;
        max = [[e tagName] isEqual:@"maxInclusive"] ? [e value] : max;
    }

    const char* name = [[elem name] UTF8String];

    char filename[1024];
    sprintf (filename, "%s/%s%s.h", dir, prefix, name);
    
    FILE* file = fopen (filename, "w");
    fprintf (file, "#import <Foundation/Foundation.h>\n\n"); 
    fprintf (file, "#import \"../handlers/%sSimpleTypeHandler.h\"", prefix);
    fprintf (file, "\n\n\n");
    fprintf (file, "/** SimpleType: %s is a int between [%s, %s] */\n", name, min ? [min UTF8String] : "-Inf", max ? [max  UTF8String] : "+Inf");

    fprintf (file, "@interface %s%s : %sSimpleTypeHandler \n\n", prefix, name, prefix);
   
    fprintf (file, "/** Register a handler to parse %s */\n", name);
    fprintf (file, "+ (void) initialize;\n\n");

    fprintf (file, "/** Initialize the handler */\n");
    fprintf (file, "- (id) init;\n");
    fprintf (file, "- (id) initWithClass:(Class) cls;\n\n");

    fprintf (file, "/** Process the characters */\n");
    fprintf (file, "- (%s) updateObject:(%s)obj withCharacters:(NSString*)s;\n\n", returnType, returnType);
    
    fprintf (file, "/** Write to the buffer the string value */\n");
    fprintf (file, "- (void) writeXmlInto:(NSMutableString*)buffer for:(%s) object;\n\n", returnType);
    
    fprintf (file, "@end\n\n");
    fclose (file);

    sprintf (filename, "%s/%s%s.m", dir, prefix, name);
    
    file = fopen (filename, "w");
    fprintf (file, "#import <Foundation/Foundation.h>\n\n"); 
    fprintf (file, "#import \"%s%s.h\"", prefix, name);
    fprintf (file, "\n");
    fprintf (file, "@implementation %s%s /* SimpleType */\n\n", prefix, name);

    if (min) fprintf (file, "static int minInclusive = %s;\n\n", [min UTF8String]);
    if (max) fprintf (file, "static int maxInclusive = %s;\n\n", [max UTF8String]);

    
    fprintf (file, "+ (void) initialize\n");
    fprintf (file, "{\n");
    fprintf (file, "    [[[%s%s alloc] init] register];\n", prefix, name);
    fprintf (file, "}\n\n");

    fprintf (file, "- (id) init\n");
    fprintf (file, "{\n");
    fprintf (file, "    self = [super initWithClass:[%s%s class]];\n", prefix, name);
    fprintf (file, "    return self;\n");
    fprintf (file, "}\n\n");

    fprintf (file, "- (id) initWithClass:(Class) cls\n");
    fprintf (file, "{\n");
    fprintf (file, "    self = [super initWithClass:cls];\n");
    fprintf (file, "    return self;\n");
    fprintf (file, "}\n\n");

    fprintf (file, "- (%s) construct\n", returnType);
    fprintf (file, "{\n");
    fprintf (file, "    return nil;\n");
    fprintf (file, "}\n\n");

    fprintf (file, "- (%s) updateObject:(%s)obj withCharacters:(NSString*) s\n", returnType, returnType);
    fprintf (file, "{\n");
    fprintf (file, "    s = [s stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];\n");
    fprintf (file, "    return [s length] > 0 ? [NSNumber numberWithInteger:[s integerValue]] : obj;\n");
    fprintf (file, "}\n\n");
   
    fprintf (file, "- (void) writeXmlInto:(NSMutableString*)buffer for:(%s) object\n", returnType);
    fprintf (file, "{\n");
    fprintf (file, "    NSNumber* obj = ((NSNumber*) object);\n");
    fprintf (file, "    NSInteger val = [obj integerValue];\n");
    if (min) fprintf (file, "    NSAssert(val >= minInclusive, @\"Value is smaller than min\");\n");
    if (max) fprintf (file, "    NSAssert(val <= maxInclusive, @\"Value is bigger than min\");\n");
    fprintf (file, "    [buffer appendFormat:@\"%%ld\", val];\n"); 
    fprintf (file, "}\n\n");
    
    fprintf (file, "@end\n\n");
    fclose (file);
}
   

- (void) simpleMinLengthString:(Element*) elem
{
    const char* returnType = "NSString *";
    NSString* min = nil;

    Element* child = [[elem children] objectAtIndex: 0];
    for (Element *e in [child children])
    {
        min = [e value];
    }

    const char* name = [[elem name] UTF8String];

    char filename[1024];
    sprintf (filename, "%s/%s%s.h", dir, prefix, name);
    
    FILE* file = fopen (filename, "w");
    fprintf (file, "#import <Foundation/Foundation.h>\n\n"); 
    fprintf (file, "#import \"../handlers/%sSimpleTypeHandler.h\"", prefix);
    fprintf (file, "\n\n\n");
    fprintf (file, "/** SimpleType: %s is a min length string of size %s */\n", name, [min UTF8String]);

    fprintf (file, "@interface %s%s : %sSimpleTypeHandler \n\n", prefix, name, prefix);
   
    fprintf (file, "/** Register a handler to parse %s */\n", name);
    fprintf (file, "+ (void) initialize;\n\n");

    fprintf (file, "/** Initialize the handler */\n");
    fprintf (file, "- (id) init;\n");
    fprintf (file, "- (id) initWithClass:(Class) cls;\n\n");

    fprintf (file, "/** Process the characters */\n");
    fprintf (file, "- (%s) updateObject:(%s)obj withCharacters:(NSString*)s;\n\n", returnType, returnType);
    
    fprintf (file, "/** Write to the buffer the string value */\n");
    fprintf (file, "- (void) writeXmlInto:(NSMutableString*)buffer for:(%s) object;\n\n", returnType);
    
    fprintf (file, "@end\n\n");
    fclose (file);

    sprintf (filename, "%s/%s%s.m", dir,  prefix, name);
    
    file = fopen (filename, "w");
    fprintf (file, "#import <Foundation/Foundation.h>\n\n"); 
    fprintf (file, "#import \"%s%s.h\"", prefix, name);
    fprintf (file, "\n");
    fprintf (file, "@implementation %s%s /* SimpleType */\n\n", prefix, name);

    fprintf (file, "static int minLength = %s;\n\n", [min UTF8String]);

    
    fprintf (file, "+ (void) initialize\n");
    fprintf (file, "{\n");
    fprintf (file, "    [[[%s%s alloc] init] register];\n", prefix, name);
    fprintf (file, "}\n\n");

    fprintf (file, "- (id) init\n");
    fprintf (file, "{\n");
    fprintf (file, "    self = [super initWithClass:[%s%s class]];\n", prefix, name);
    fprintf (file, "    return self;\n");
    fprintf (file, "}\n\n");

    fprintf (file, "- (id) initWithClass:(Class) cls\n");
    fprintf (file, "{\n");
    fprintf (file, "    self = [super initWithClass:cls];\n");
    fprintf (file, "    return self;\n");
    fprintf (file, "}\n\n");

    fprintf (file, "- (%s) construct\n", returnType);
    fprintf (file, "{\n");
    fprintf (file, "    return [[NSString alloc] init];\n");
    fprintf (file, "}\n\n");

    fprintf (file, "- (%s) updateObject:(%s)obj withCharacters:(NSString*) s\n", returnType, returnType);
    fprintf (file, "{\n");
    fprintf (file, "    s = [s stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];\n");
    fprintf (file, "    return [s length] > 0 ? s : obj;\n");
    fprintf (file, "}\n\n");
   
    fprintf (file, "- (void) writeXmlInto:(NSMutableString*)buffer for:(%s) object\n", returnType);
    fprintf (file, "{\n");
    fprintf (file, "    NSString* obj = ((NSString*) object);\n");
    fprintf (file, "    NSAssert([obj length] >= minLength, @\"String should have a min length\");\n");
    fprintf (file, "    [buffer appendString:obj];\n"); 
    fprintf (file, "}\n\n");
    
    fprintf (file, "@end\n\n");
    fclose (file);
}

- (void) simpleEnumeratedString:(Element*) elem
{
    const char* returnType = "NSString *";
    Element* child = [[elem children] objectAtIndex: 0];

    const char* name = [[elem name] UTF8String];

    char filename[1024];
    sprintf (filename, "%s/%s%s.h", dir, prefix, name);
    
    FILE* file = fopen (filename, "w");
    fprintf (file, "#import <Foundation/Foundation.h>\n\n"); 
    fprintf (file, "#import \"../handlers/%sSimpleTypeHandler.h\"", prefix);
    fprintf (file, "\n\n\n");
    fprintf (file, "/** SimpleType: %s can be one of the following:\n", name);

    int idx = 1;
    for (Element *e in [child children])
    {
        const char* v = [[e value] UTF8String];
        fprintf (file, " *       %d %s\n", idx++, v);
    }
    fprintf (file, " */\n");
    fprintf (file, "@interface %s%s : %sSimpleTypeHandler \n\n", prefix, name, prefix);
   
    fprintf (file, "/** Register a handler to parse %s */\n", name);
    fprintf (file, "+ (void) initialize;\n\n");

    fprintf (file, "/** Initialize the handler */\n");
    fprintf (file, "- (id) init;\n");
    fprintf (file, "- (id) initWithClass:(Class) cls;\n\n");

    fprintf (file, "/** Process the characters */\n");
    fprintf (file, "- (%s) updateObject:(%s)obj withCharacters:(NSString*)s;\n\n", returnType, returnType);
    
    fprintf (file, "/** Write to the buffer the string value */\n");
    fprintf (file, "- (void) writeXmlInto:(NSMutableString*)buffer for:(%s) object;\n\n", returnType);
    

    fprintf (file, "\n/* Valid values */\n");
    for (Element *e in [child children])
    {
        const char* v = [[[e value] stringByReplacingOccurrencesOfString:@":" withString:@"_"] UTF8String];
        fprintf (file, "+ (NSString *) %s;\n", v);
    }
    fprintf (file, "@end\n\n");
    fclose (file);

    sprintf (filename, "%s/%s%s.m", dir, prefix, name);
    
    file = fopen (filename, "w");
    fprintf (file, "#import <Foundation/Foundation.h>\n\n"); 
    fprintf (file, "#import \"%s%s.h\"", prefix, name);
    fprintf (file, "\n");
    fprintf (file, "@implementation %s%s /* SimpleType */\n\n", prefix, name);

    fprintf (file, "static NSSet* enumerations = nil;\n\n");

    
    fprintf (file, "+ (void) initialize\n");
    fprintf (file, "{\n");
    fprintf (file, "    enumerations = [NSSet setWithObjects:");
    for (Element *e in [child children])
    {
        const char* v = [[[e value] stringByReplacingOccurrencesOfString:@":" withString:@"_"] UTF8String];
        fprintf (file, "\n                                         [%s%s %s], ", prefix, name, v);
    }
    fprintf (file, "nil];\n");
    fprintf (file, "    [[[%s%s alloc] init] register];\n", prefix, name);
    fprintf (file, "}\n\n");

    fprintf (file, "- (id) init\n");
    fprintf (file, "{\n");
    fprintf (file, "    self = [super initWithClass:[%s%s class]];\n", prefix, name);
    fprintf (file, "    return self;\n");
    fprintf (file, "}\n\n");

    fprintf (file, "- (id) initWithClass:(Class) cls\n");
    fprintf (file, "{\n");
    fprintf (file, "    self = [super initWithClass:cls];\n");
    fprintf (file, "    return self;\n");
    fprintf (file, "}\n\n");

    fprintf (file, "- (%s) updateObject:(%s)obj withCharacters:(NSString*) s\n", returnType, returnType);
    fprintf (file, "{\n");
    fprintf (file, "    s = [s stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];\n");
    fprintf (file, "    return [enumerations containsObject:s] ? [enumerations member:s] : obj;\n");
    fprintf (file, "}\n\n");
   
    fprintf (file, "- (void) writeXmlInto:(NSMutableString*)buffer for:(%s) object\n", returnType);
    fprintf (file, "{\n");
    fprintf (file, "    NSString* obj = ((NSString*) object);\n");
    fprintf (file, "    NSAssert([enumerations containsObject:obj], @\"String is a enumerated list\");\n");
    fprintf (file, "    [buffer appendString:((NSString*) object)];\n"); 
    fprintf (file, "}\n\n");

    for (Element *e in [child children])
    {
        const char* v = [[[e value] stringByReplacingOccurrencesOfString:@":" withString:@"_"] UTF8String];
        fprintf (file, "+ (NSString *) %s { return @\"%s\"; }\n", v, [[e value] UTF8String]);
    }
    
    fprintf (file, "@end\n\n");
    fclose (file);
}

-(void) extendNonEmptyStringType:(Element*) elem
{
    const char* name = [[elem name] UTF8String];

    char filename[1024];
    sprintf (filename, "%s/%s%s.h", dir, prefix, name);
    
    FILE* file = fopen (filename, "w");
    fprintf (file, "#import <Foundation/Foundation.h>\n\n"); 
    fprintf (file, "#import \"%sNonEmptyStringType.h\"", prefix);
    fprintf (file, "\n\n\n");
    fprintf (file, "/** SimpleType: %s is string  */\n", name);

    fprintf (file, "@interface %s%s : %sNonEmptyStringType \n\n", prefix, name, prefix);
   
    fprintf (file, "/** Register a handler to parse %s */\n", name);
    fprintf (file, "+ (void) initialize;\n\n");

    fprintf (file, "/** Initialize the handler */\n");
    fprintf (file, "- (id) init;\n");
    fprintf (file, "- (id) initWithClass:(Class) cls;\n\n");

    fprintf (file, "@end\n\n");
    fclose (file);

    sprintf (filename, "%s/%s%s.m", dir, prefix, name);
    
    file = fopen (filename, "w");
    fprintf (file, "#import <Foundation/Foundation.h>\n\n"); 
    fprintf (file, "#import \"%s%s.h\"", prefix, name);
    fprintf (file, "\n");
    fprintf (file, "@implementation %s%s /* SimpleType */\n\n", prefix, name);

    
    fprintf (file, "+ (void) initialize\n");
    fprintf (file, "{\n");
    fprintf (file, "    [[[%s%s alloc] init] register];\n", prefix, name);
    fprintf (file, "}\n\n");

    fprintf (file, "- (id) init\n");
    fprintf (file, "{\n");
    fprintf (file, "    self = [super initWithClass:[%s%s class]];\n", prefix, name);
    fprintf (file, "    return self;\n");
    fprintf (file, "}\n\n");

    fprintf (file, "- (id) initWithClass:(Class) cls\n");
    fprintf (file, "{\n");
    fprintf (file, "    self = [super initWithClass:cls];\n");
    fprintf (file, "    return self;\n");
    fprintf (file, "}\n\n");

    fprintf (file, "@end\n\n");
    fclose (file);
}

- (BOOL) isSimpleType:(Element*) e
{
    return [[e tagName] isEqual:@"simpleType"];
}

- (void) generateForSimpleType
{
    NSString* simpleType = @"simpleType";

    for (Element* elem in [current children])
    {
        if ([[elem tagName] isEqual:simpleType]) {
            if ([[elem name] isEqual:@"PropertyTagType"] || [[elem name] isEqual:@"ReminderMinutesBeforeStartType"]) 
            {
                [elem setResultType:@"NSNumber*"];
            }
            else if ([[elem name] isEqual:@"DaysOfWeekType"] || [[elem name] isEqual:@"FreeBusyViewType"])
            {
                [elem setResultType:@"NSMutableArray<NSString*>*"];
            }
            else if ([[elem children] count] == 1)
            {
                Element* child = [[elem children] objectAtIndex: 0];
                if ([[child tagName] isEqual:@"restriction"]) {
                    if ([[child base] isEqual:@"xs:string"]) {
                        if ([[child children] count] == 0) 
                        {
                            [self simpleString:elem];
                            [elem setResultType:@"NSString*"];
                        }
                        else if ([self forElement:child areChildren:@"enumeration"]) {

                            [self simpleEnumeratedString:elem];
                            [elem setResultType:@"NSString*"];
                        }
                        else if ([self forElement:child areChildren:@"minLength"]) {
                            [self simpleMinLengthString:elem];
                            [elem setResultType:@"NSString*"];
                        }
                        else if ([self forElement:child areChildren:@"pattern"]) {
                            [self patternString:elem];
                            [elem setResultType:@"NSString*"];
                        }
                        else NSLog(@"string type is not enumeration %@ %@", [elem tagName], [elem name]);
                    }
                    else if ([[child base] isEqual:@"xs:int"]) {
                        if ([self forElement:child areChildren:@"minInclusive,maxInclusive"]) {
                            [self simpleMinMaxInt:elem];
                            [elem setResultType:@"NSNumber*"];
                        }
                        else NSLog (@"unknown int type %@ %@", [elem tagName], [elem name]);
                    }
                    else if ([[child base] isEqual:@"t:NonEmptyStringType"]) {
                        if ([[child children] count] == 0)
                        {
                            [self extendNonEmptyStringType:elem];
                            [elem setResultType:@"NSString*"];
                        }
                        else NSLog (@"extension has children string %@ %@", [elem tagName], [elem name]);
                    }
                    else NSLog(@"restriction is not of type string %@ %@", [elem tagName], [elem name]);
                }
                else NSLog(@"restriction is not the child %@ %@", [elem tagName], [elem name]);
            }
            else {
                NSLog(@"Unprocessed %@ %@", [elem tagName], [elem name]);
            }
        }
    }
}

- (BOOL) isResolved:(Element*) elem
{
    return [elem resultType] ? TRUE : FALSE;
}

- (BOOL) isArrayType:(Element*) elem checkResolved:(BOOL) r
{
    return [self isSimpleArrayType:elem checkResolved: r] || [self isChoiceArrayType:elem checkResolved: r];
}

- (BOOL) isChoiceArrayType:(Element*) elem checkResolved:(BOOL) r
{
    if (![[elem tagName] isEqual:@"complexType"]) return false;
    if ([[elem children] count] != 1) return false;

    Element* child = [[elem children] objectAtIndex: 0];

    if (![[child tagName] isEqual:@"choice"]) return false;

    if (![self forElement:child areChildren:@"element"]) return false;
    if ([[child children] count] == 0) return false;

    for (Element *e in [child children]) {
        if ([[e children] count] != 0) return false;
        if (![e maxOccurs]) return false;
        if (![[e maxOccurs] isEqual:@"unbounded"]) return false;
        if (r) { if (![self objectType:[e type]]) return false; }
    }
    return true;
}

- (BOOL) isSimpleArrayType:(Element*) elem checkResolved:(BOOL) r
{
    if (![[elem tagName] isEqual:@"complexType"]) return false;
    if ([[elem children] count] != 1) return false;

    Element* child = [[elem children] objectAtIndex: 0];

    if (![[child tagName] isEqual:@"sequence"]) return false;

    if (![self forElement:child areChildren:@"element"]) return false;
    if ([[child children] count] != 1) return false;

    for (Element *e in [child children]) {
        if ([[e children] count] != 0) return false;
        if (![e maxOccurs]) return false;
        if (![[e maxOccurs] isEqual:@"unbounded"]) return false;
        if (r) { if (![self objectType:[e type]]) return false; }
    }
    return true;
}

-(void) generateForArrayElement:(Element*) elem
{
    Element* sequence = [[elem children] objectAtIndex: 0]; // sequence or choice

    const char* name = [[elem name] UTF8String];

    char filename[1024];
    sprintf (filename, "%s/%s%s.h", dir, prefix, name);
    
    FILE* file = fopen (filename, "w");
    fprintf (file, "#import <Foundation/Foundation.h>\n\n"); 
    fprintf (file, "\n\n\n");
    fprintf (file, "#import \"../handlers/%sArrayTypeHandler.h\"\n", prefix);
    NSMutableSet<NSString*>* includes = [[NSMutableSet<NSString*> alloc] init];
    for  (Element* e in [sequence children]) {
        [includes addObject:[self includeFile:[e type]]];
    }
    for  (NSString* i in includes) {
        fprintf (file, "#import \"%s\"\n", [i UTF8String]);
    }
    fprintf (file, "\n\n\n");
    fprintf (file, "/* %s */\n", name);

    fprintf (file, "@interface %s%s : EWSArrayTypeHandler\n\n", prefix, name);


    if ([[sequence children] count] == 1)
    {
        Element* f = [[sequence children] objectAtIndex:0];
        NSString* type = [self objectType:[f type]];
        [elem setResultType:[@"NSArray<" stringByAppendingString:[type stringByAppendingString:@">*"]]];   
    }
    else
    {
        [elem setResultType:@"NSArray*"];   
    }
   
    fprintf (file, "+ (void) initialize;\n\n");

    fprintf (file, "- (id) init;\n");

    fprintf (file, "@end\n\n");
    fclose (file);

    sprintf (filename, "%s/%s%s.m", dir, prefix, name);
    
    file = fopen (filename, "w");

    fprintf (file, "\n#import \"%s%s.h\"\n", prefix, name);
    fprintf (file, "\n\n");
    fprintf (file, "@implementation %s%s \n\n", prefix, name);

    
    fprintf (file, "+ (void) initialize\n");
    fprintf (file, "{\n");
    fprintf (file, "    %sArrayTypeHandler* handler = [[%s%s alloc] initWithClass:[%s%s class]];\n\n", prefix, prefix, name, prefix, name);

    for  (Element* e in [sequence children])
    {
        fprintf (file, "    [handler elementName   : @\"%s\"\n", [[e name] UTF8String]);
        fprintf (file, "             withNamespace : '%c'", [e ns]);
        fprintf (file, "             withHandler   : [%s%s class]];\n\n", prefix, [[self handler:[e type]] UTF8String]);
    }
    fprintf (file, "    [handler register];\n");
    fprintf (file, "}\n\n");

    fprintf (file, "- (id) init\n");
    fprintf (file, "{\n");
    fprintf (file, "    return [super init];\n");
    fprintf (file, "}\n\n");

    fprintf (file, "@end\n\n");
    fclose (file);
}

- (void) generateForArray
{
    for (Element* elem in [current children])
    {
        if ([self isArrayType:elem checkResolved:TRUE]) {
            NSLog(@"array %@ %@",  [elem tagName], [elem name]);
            [self generateForArrayElement:elem];
        }
    }
}


- (BOOL) isSimpleStruct:(Element*) elem
{
    if ([self isArrayType:elem checkResolved:FALSE]) return false;
    if (![[elem tagName] isEqual:@"complexType"]) return false;
    if ([[elem children] count] == 0) return false;

    Element* child = [[elem children] objectAtIndex: 0];
    if (![[child tagName] isEqual:@"sequence"]) return false;
    if (![self forElement:child areChildren:@"element"]) return false;

    for (int i = 1; i < [[elem children] count]; i++)
    {
        Element* e = [[elem children] objectAtIndex:i];
        if (![[e tagName] isEqual:@"attribute"])
            return false;
        if (![self objectType:[e type]]) return false;
    }
    for (Element *e in [child children]) {
        if ([[e children] count] != 0) return false;
        if (![self objectType:[e type]]) return false;
    }
    return true;
}

- (NSString*) pad:(NSString*)s toLength:(int) l
{
    while ([s length] < l)
    {
        s = [s stringByAppendingString:@" "];
    }
    return s;
}

- (NSString*) trimTypeName:(NSString*)s
{
    if ([s hasPrefix:@"t:"]) {
        return [s stringByReplacingOccurrencesOfString:@"t:" withString:@"EWS"];
    }
    return s;
}

- (NSString*) trimNS:(NSString*)s
{
    if ([s hasPrefix:@"t:"]) {
        return [s stringByReplacingOccurrencesOfString:@"t:" withString:@""];
    }
    if ([s hasPrefix:@"m:"]) {
        return [s stringByReplacingOccurrencesOfString:@"m:" withString:@""];
    }
    if ([s hasPrefix:@"xs:"]) {
        return [s stringByReplacingOccurrencesOfString:@"xs" withString:@""];
    }
    return s;
}

-(void) generateStructForElement:(Element*) elem
           withAttributes:(NSArray*) attributes withElements:(NSArray*) elements 
           withSuperAttributes:(NSArray*) s_attributes withSuperElements:(NSArray*)s_elements andBaseClass:(NSString*) base
           simpleContentHandlerClass:(NSString*) contentHandlerClass
{
    NSLog(@"Generating struct for %@", [elem name]);
    const char* name = [[elem name] UTF8String];

    char filename[1024];
    sprintf (filename, "%s/%s%s.h", dir,  prefix, name);
    
    FILE* file = fopen (filename, "w");
    fprintf (file, "#import <Foundation/Foundation.h>\n\n"); 
    fprintf (file, "\n\n\n");
    NSMutableSet<NSString*>* includes = [[NSMutableSet<NSString*> alloc] init];
    for  (Element* e in elements) {
        [includes addObject:[self includeFile:[e type]]];
    }
    for (Element* e in attributes) {
        if ([[e tagName] isEqual:@"attribute"])
        {
            [includes addObject:[self includeFile:[e type]]];
        }
    }
    for  (NSString* i in includes) {
        fprintf (file, "#import \"%s\"\n", [i UTF8String]);
    }
    if (![base isEqual:@"NSObject"]) {
        fprintf (file, "#import \"%s.h\"\n", [base UTF8String]);
    }
    fprintf (file, "\n\n\n");
    fprintf (file, "/* %s */\n", name);

    fprintf (file, "@interface %s%s : %s\n\n", prefix, name, [base UTF8String]);


    [elem setResultType:[@"EWS" stringByAppendingString:[[elem name] stringByAppendingString:@"*"]]];
   
    fprintf (file, "+ (void) initialize;\n\n");

    fprintf (file, "- (id) init;\n");
    fprintf (file, "- (Class) handlerClass;\n");
    fprintf (file, "- (NSString*) description;\n\n");

    unsigned int tlength = 8;
    unsigned int nlength = 5;
    // Attributes
    for (Element* e in attributes) 
    {
            tlength = [[self objectType:[e type]] length] > tlength ? [[self objectType:[e type]] length] : tlength;
            nlength = [[e name] length] > nlength ? [[e name] length] : nlength;
    }
    for  (Element* e in elements)
    {
        nlength = [[e name] length] > nlength ? [[e name] length] : nlength;
        if (![e maxOccurs] || [[e maxOccurs] isEqual:@"1"]) 
        {
            tlength = [[self objectType:[e type]] length] > tlength ? [[self objectType:[e type]] length] : tlength;
        }
        else
        {
            tlength = ([[self objectType:[e type]] length] + 17) > tlength ? ([[self objectType:[e type]] length] + 17) : tlength;
        }
    }

    for (Element* e in attributes)
    {
            NSString* t = [self objectType:[e type]];

            if ([t hasPrefix:@"NS"])
                fprintf (file, "@property (retain) %s %s  /* %s */;\n", [[self pad:[self objectType:[e type]] toLength:tlength] UTF8String], [[self pad:[self propertyName:[e name]] toLength:nlength] UTF8String], [[self trimTypeName:[e type]] UTF8String]);
            else
                fprintf (file, "@property (retain) %s %s;\n", [[self pad:[self objectType:[e type]] toLength:tlength] UTF8String], [[self propertyName:[e name]] UTF8String]);
    }
    for  (Element* e in elements)
    {
        NSString* t = [self objectType:[e type]];

        if (![e maxOccurs] || [[e maxOccurs] isEqual:@"1"]) {
            if ([t hasPrefix:@"NS"])
                fprintf (file, "@property (retain) %s %s  /* %s */;\n", [[self pad:[self objectType:[e type]] toLength:tlength] UTF8String], [[self pad:[self propertyName:[e name]] toLength:nlength] UTF8String], [[self trimTypeName:[e type]] UTF8String]);
            else
                fprintf (file, "@property (retain) %s %s;\n", [[self pad:[self objectType:[e type]] toLength:tlength] UTF8String], [[self propertyName:[e name]] UTF8String]);
        }
        else if ([[e maxOccurs] isEqual:@"unbounded"])
        {
            NSString* str = [[NSString alloc] initWithFormat:@"NSMutableArray<%@>*", [self objectType:[e type]]];
            if ([t hasPrefix:@"NS"])
                fprintf (file, "@property (retain) %s %s /* %s */;\n", [[self pad:str toLength:tlength] UTF8String], [[self pad:[self propertyName:[e name]] toLength:nlength] UTF8String], [[self trimTypeName:[e type]] UTF8String]);
            else
                fprintf (file, "@property (retain) %s %s;\n", [[self pad:str toLength:tlength] UTF8String], [[self propertyName:[e name]] UTF8String]);
        }
        else
        {
            NSLog (@"maxOccurs is %@", [e maxOccurs]);
            exit (-1);
        }
    }

    fprintf (file, "\n\n");
    for  (Element* e in elements)
    {
        if ([e maxOccurs] && [[e maxOccurs] isEqual:@"unbounded"])
        {
            fprintf (file, "- (void) add%s:(%s) elem;\n", [[e name] UTF8String], [[self objectType:[e type]] UTF8String]);
        }
    }

    fprintf (file, "@end\n\n");
    fclose (file);

    sprintf (filename, "%s/%s%s.m", dir,  prefix, name);
    
    file = fopen (filename, "w");
    fprintf (file, "#import <Foundation/Foundation.h>\n\n"); 
    fprintf (file, "#import \"../handlers/%sObjectTypeHandler.h\"\n", prefix);
    fprintf (file, "\n#import \"%s%s.h\"\n", prefix, name);
    fprintf (file, "\n\n");
    fprintf (file, "@implementation %s%s \n\n", prefix, name);

    
    fprintf (file, "+ (void) initialize\n");
    fprintf (file, "{\n");

    if (contentHandlerClass)
    {
        fprintf (file, "    %sObjectTypeHandler* handler = [[%sObjectTypeHandler alloc] initWithClass:[%s%s class] andContentHandlerClass:[%s class]];\n\n", prefix, prefix, prefix, name, [contentHandlerClass UTF8String]);
    }
    else
    {
        fprintf (file, "    %sObjectTypeHandler* handler = [[%sObjectTypeHandler alloc] initWithClass:[%s%s class]];\n\n", prefix, prefix, prefix, name);
    }

    for (Element* e in s_attributes)
    {
        bool required = [e use] && [[e use] isEqual:@"required"];
        fprintf (file, "    [handler property    : @\"%s\"\n", [[self propertyName:[e name]] UTF8String]);
        fprintf (file, "             isRequired  : %s\n", required ? "TRUE" : "FALSE");
        fprintf (file, "             withAttrTag : @\"%s\"\n", [[e name] UTF8String]);
        fprintf (file, "             withHandler : [%s%s class]];\n\n", prefix, [[self handler:[e type]] UTF8String]);
    }

    for (Element* e in attributes)
    {
        bool required = [e use] && [[e use] isEqual:@"required"];
        fprintf (file, "    [handler property    : @\"%s\"\n", [[self propertyName:[e name]] UTF8String]);
        fprintf (file, "             isRequired  : %s\n", required ? "TRUE" : "FALSE");
        fprintf (file, "             withAttrTag : @\"%s\"\n", [[e name] UTF8String]);
        fprintf (file, "             withHandler : [%s%s class]];\n\n", prefix, [[self handler:[e type]] UTF8String]);
    }

    for  (Element* e in s_elements)
    {
        bool required = ![e minOccurs] || ![[e minOccurs] isEqual:@"0"];
        if (![e maxOccurs] || [[e maxOccurs] isEqual:@"1"]) {
            fprintf (file, "    [handler property      : @\"%s\"\n", [[self propertyName:[e name]] UTF8String]);
            fprintf (file, "             isRequired    : %s\n", required ? "TRUE" : "FALSE");
            fprintf (file, "             withNamespace : '%c'\n", [e ns]);
            fprintf (file, "             withXmlTag    : @\"%s\"\n", [[e name] UTF8String]);
            fprintf (file, "             withHandler   : [%s%s class]];\n\n", prefix, [[self handler:[e type]] UTF8String]);
        }
        else if ([[e maxOccurs] isEqual:@"unbounded"])
        {
            fprintf (file, "    [handler listProperty  : @\"%s\"\n", [[self propertyName:[e name]] UTF8String]);
            fprintf (file, "             isNonEmpty    : %s\n", required ? "TRUE" : "FALSE");
            fprintf (file, "             useSelector   : @\"add%s\"\n", [[e name] UTF8String]);
            fprintf (file, "             withNamespace : '%c'\n", [e ns]);
            fprintf (file, "             withXmlTag    : @\"%s\"\n", [[e name] UTF8String]);
            fprintf (file, "             withHandler   : [%s%s class]];\n\n", prefix, [[self handler:[e type]] UTF8String]);
        }
        else
        {
            NSLog (@"maxOccurs is %@", [e maxOccurs]);
            exit (-1);
        }
    }

    for  (Element* e in elements)
    {
        bool required = ![e minOccurs] || ![[e minOccurs] isEqual:@"0"];
        if (![e maxOccurs] || [[e maxOccurs] isEqual:@"1"]) {
            fprintf (file, "    [handler property      : @\"%s\"\n", [[self propertyName:[e name]] UTF8String]);
            fprintf (file, "             isRequired    : %s\n", required ? "TRUE" : "FALSE");
            fprintf (file, "             withNamespace : '%c'\n", [e ns]);
            fprintf (file, "             withXmlTag    : @\"%s\"\n", [[e name] UTF8String]);
            fprintf (file, "             withHandler   : [%s%s class]];\n\n", prefix, [[self handler:[e type]] UTF8String]);
        }
        else if ([[e maxOccurs] isEqual:@"unbounded"])
        {
            fprintf (file, "    [handler listProperty  : @\"%s\"\n", [[self propertyName:[e name]] UTF8String]);
            fprintf (file, "             isNonEmpty    : %s\n", required ? "TRUE" : "FALSE");
            fprintf (file, "             useSelector   : @\"add%s\"\n", [[e name] UTF8String]);
            fprintf (file, "             withNamespace : '%c'\n", [e ns]);
            fprintf (file, "             withXmlTag    : @\"%s\"\n", [[e name] UTF8String]);
            fprintf (file, "             withHandler   : [%s%s class]];\n\n", prefix, [[self handler:[e type]] UTF8String]);
        }
        else
        {
            NSLog (@"maxOccurs is %@", [e maxOccurs]);
            exit (-1);
        }
    }
    fprintf (file, "    [handler register];\n");
    fprintf (file, "}\n\n");

    fprintf (file, "- (id) init\n");
    fprintf (file, "{\n");
    fprintf (file, "    return [super init];\n");
    fprintf (file, "}\n\n");
    fprintf (file, "- (Class) handlerClass\n");
    fprintf (file, "{\n");
    fprintf (file, "    return [%s%s class];\n", prefix, name);
    fprintf (file, "}\n\n");

    fprintf (file, "- (NSString*) description\n");
    fprintf (file, "{\n");
    fprintf (file, "    return [NSString stringWithFormat:@\"%s:", name);
    for (Element* e in attributes)
    {
        fprintf (file, " %s=%%@", [[e name] UTF8String]);
    }
    for  (Element* e in elements)
    {
        fprintf (file, " %s=%%@", [[e name] UTF8String]);
    }
    if (![base isEqual:@"NSObject"])
    {
        fprintf (file, " super=%%@");
    }
    fprintf (file, "\"");
    for (Element* e in attributes)
    {
        fprintf (file, ", _%s", [[self propertyName:[e name]] UTF8String]);
    }
    for  (Element* e in elements)
    {
        fprintf (file, ", _%s", [[self propertyName:[e name]] UTF8String]);
    }
    if (![base isEqual:@"NSObject"])
    {
        fprintf (file, ", [super description]");
    }
    fprintf (file, "];\n");
    fprintf (file, "}\n\n");

    for  (Element* e in elements)
    {
        if ([e maxOccurs] && [[e maxOccurs] isEqual:@"unbounded"])
        {
            fprintf (file, "- (void) add%s:(%s) elem\n", [[e name] UTF8String], [[self objectType:[e type]] UTF8String]);
            fprintf (file, "{\n");
            fprintf (file, "    [_%s addObject:elem];\n", [[self propertyName:[e name]] UTF8String]);
            fprintf (file, "}\n\n");
        }
    }

    fprintf (file, "@end\n\n");
    fclose (file);
}

-(void) generateStructForElement:(Element*) elem
           withAttributes:(NSArray*) attributes withElements:(NSArray*) elements 
           withSuperAttributes:(NSArray*) s_attributes withSuperElements:(NSArray*)s_elements andBaseClass:(NSString*) base
{
    [self generateStructForElement:elem withAttributes:attributes withElements:elements
           withSuperAttributes:s_attributes withSuperElements:s_elements andBaseClass:base
           simpleContentHandlerClass:nil];
}
-(void) generateStructForElement:(Element*) elem
           withAttributes:(NSArray*) attributes withElements:(NSArray*) elements 
{
     [self generateStructForElement:elem
           withAttributes:attributes withElements:elements 
           withSuperAttributes:[[NSArray alloc] init] withSuperElements:[[NSArray alloc] init] andBaseClass:@"NSObject"];
}


-(void) generateForSimpleStructForElement:(Element*) elem
{
    Element* sequence = [[elem children] objectAtIndex: 0];


    NSMutableArray* elements   = [[NSMutableArray alloc] init];
    NSMutableArray* attributes = [[NSMutableArray alloc] init];

    for  (Element* e in [sequence children]) {
        [elements addObject:e];
    }
    for (Element* e in [elem children]) {
        if ([[e tagName] isEqual:@"attribute"])
        {
            [attributes addObject:e];
        }
    }
    [self generateStructForElement:elem withAttributes:attributes withElements:elements];
}

- (NSString*) propertyName:(NSString*) name
{
    if ([name hasPrefix:@"New"])
    {
        name = [NSString stringWithFormat:@"p%@", name];
    }
    NSString* first = [[name substringToIndex:1] lowercaseString];
    NSString* rest  = [name substringFromIndex:1];


    return [first stringByAppendingString:rest];
}

- (void) generateForSimpleStruct
{
    for (Element* elem in [current children])
    {
        [self generateStructForElement:elem];
    /*
        if ([self isSimpleStruct:elem]) {
            NSLog(@"Simple struct %@ %@",  [elem tagName], [elem name]);
            [self generateForSimpleStructForElement:elem];
        }
    */
    }
}

- (NSString*) objectType:(NSString*)nm
{
    if ([nm hasPrefix:@"xs:"] || [nm hasPrefix:@"xml:"])
    {
        if ([nm isEqual:@"xs:string"])        return @"NSString*";
        if ([nm isEqual:@"xs:dateTime"])      return @"NSString*";
        if ([nm isEqual:@"xs:date"])          return @"NSString*";
        if ([nm isEqual:@"xs:anyURI"])        return @"NSString*";
        if ([nm isEqual:@"xs:base64Binary"])  return @"NSData*";
        if ([nm isEqual:@"xs:duration"])      return @"NSString*";
        if ([nm isEqual:@"xs:language"])      return @"NSString*";
        if ([nm isEqual:@"xml:lang"])         return @"NSString*";
        if ([nm isEqual:@"xs:time"])          return @"NSString*";
        if ([nm isEqual:@"xs:short"])         return @"NSNumber*";
        if ([nm isEqual:@"xs:int"])           return @"NSNumber*";
        if ([nm isEqual:@"xs:double"])        return @"NSNumber*";
        if ([nm isEqual:@"xs:boolean"])       return @"NSNumber*";
        if ([nm isEqual:@"xs:unsignedInt"])   return @"NSNumber*";
        if ([nm isEqual:@"xs:unsignedShort"]) return @"NSNumber*";


        NSLog(@"Unknown type %@", nm);
        NSAssert(NO, @"Unknown type");
    }

    if ([nm hasPrefix:@"t:"])
    {
        nm = [nm stringByReplacingOccurrencesOfString:@"t:" withString:@""];

        for (Element* elem in [current children])
        {
            if ([[elem name] isEqual:nm])
            {
                return [elem resultType];
            }
        }
        NSLog(@"Unknown type %@", nm);
    }
    NSLog(@"Unknown type %@", nm);
    return nil;
}

- (NSString*) includeFile:(NSString*)nm
{
    if ([nm hasPrefix:@"xs:"] || [nm hasPrefix:@"xml:"])
    {
        if ([nm isEqual:@"xs:string"])        return @"../handlers/EWSStringTypeHandler.h";
        if ([nm isEqual:@"xs:int"])           return @"../handlers/EWSIntegerTypeHandler.h";
        if ([nm isEqual:@"xs:boolean"])       return @"../handlers/EWSBooleanTypeHandler.h";
        if ([nm isEqual:@"xs:dateTime"])      return @"../handlers/EWSDateTimeTypeHandler.h";
        if ([nm isEqual:@"xs:date"])          return @"../handlers/EWSDateTypeHandler.h";
        if ([nm isEqual:@"xs:anyURI"])        return @"../handlers/EWSAnyUriTypeHandler.h";
        if ([nm isEqual:@"xs:base64Binary"])  return @"../handlers/EWSBase64BinaryTypeHandler.h";
        if ([nm isEqual:@"xs:double"])        return @"../handlers/EWSDoubleTypeHandler.h";
        if ([nm isEqual:@"xs:duration"])      return @"../handlers/EWSDurationTypeHandler.h";
        if ([nm isEqual:@"xs:language"])      return @"../handlers/EWSLanguageTypeHandler.h";
        if ([nm isEqual:@"xml:lang"])         return @"../handlers/EWSXmlLanguageTypeHandler.h";
        if ([nm isEqual:@"xs:short"])         return @"../handlers/EWSShortTypeHandler.h";
        if ([nm isEqual:@"xs:time"])          return @"../handlers/EWSTimeTypeHandler.h";
        if ([nm isEqual:@"xs:unsignedInt"])   return @"../handlers/EWSUnsignedIntTypeHandler.h";
        if ([nm isEqual:@"xs:unsignedShort"]) return @"../handlers/EWSUnsignedShortTypeHandler.h";

        NSLog(@"Unknown type %@", nm);
        NSAssert(NO, @"Unknown type");
    }

    if ([nm hasPrefix:@"t:"])
    {
        nm = [nm stringByReplacingOccurrencesOfString:@"t:" withString:@""];

        for (Element* elem in [current children])
        {
            if ([[elem name] isEqual:nm])
            {
                NSString * r = @"EWS";

                return [[r stringByAppendingString:[elem name]] stringByAppendingString:@".h"];
            }
        }
        NSLog(@"Unknown type %@", nm);
        assert (false);
    }
    NSLog(@"Unknown type %@", nm);
    exit(-1);

    return nil;
}

- (NSString*) handler:(NSString*)nm
{
    if ([nm hasPrefix:@"xs:"] || [nm hasPrefix:@"xml:"])
    {
        if ([nm isEqual:@"xs:string"])        return @"StringTypeHandler";
        if ([nm isEqual:@"xs:int"])           return @"IntegerTypeHandler";
        if ([nm isEqual:@"xs:boolean"])       return @"BooleanTypeHandler";
        if ([nm isEqual:@"xs:dateTime"])      return @"DateTimeTypeHandler";
        if ([nm isEqual:@"xs:date"])          return @"DateTypeHandler";
        if ([nm isEqual:@"xs:anyURI"])        return @"AnyUriTypeHandler";
        if ([nm isEqual:@"xs:base64Binary"])  return @"Base64BinaryTypeHandler";
        if ([nm isEqual:@"xs:double"])        return @"DoubleTypeHandler";
        if ([nm isEqual:@"xs:duration"])      return @"DurationTypeHandler";
        if ([nm isEqual:@"xml:lang"])         return @"XmlLanguageTypeHandler";
        if ([nm isEqual:@"xs:language"])      return @"LanguageTypeHandler";
        if ([nm isEqual:@"xs:short"])         return @"ShortTypeHandler";
        if ([nm isEqual:@"xs:time"])          return @"TimeTypeHandler";
        if ([nm isEqual:@"xs:unsignedInt"])   return @"UnsignedIntTypeHandler";
        if ([nm isEqual:@"xs:unsignedShort"]) return @"UnsignedShortTypeHandler";

        NSLog(@"Unknown type %@", nm);
        NSAssert(NO, @"Unknown type");
    }

    if ([nm hasPrefix:@"t:"])
    {
        nm = [nm stringByReplacingOccurrencesOfString:@"t:" withString:@""];

        for (Element* elem in [current children])
        {
            if ([[elem name] isEqual:nm])
            {
                return [elem name];
            }
        }
        NSLog(@"Unknown type %@", nm);
        assert (false);
    }
    NSLog(@"Unknown type %@", nm);
    exit(-1);

    return nil;
}

- (int) resolved
{
    int result = 0;
    for (Element* elem in [current children])
    {
        if ([self isResolved:elem]) result++;
    }
    return result;
}

- (void) generate
{
    [self generateForSimpleType];

    while (TRUE)
    {
        int r = [self resolved];

        [self generateForSimpleStruct];
        [self generateForArray];

        if (r == [self resolved])
            break;
    }

    for (Element* elem in [current children])
    {
        if ([[elem tagName] isEqual:@"complexType"] && ![self isResolved:elem])
        {
            NSLog(@"Fix me %@", elem);
            //NSLog(@"Attributes %@", [self attributes:[elem name] getSuper:TRUE]);
            //NSLog(@"Elements   %@", [self elements:[elem name] getSuper:TRUE]);
            //NSLog(@"BaseClass  %@", [self baseClass:[elem name]]);
            //NSLog(@"Content Handler  %@", [self contentHandlerClass:[elem name]]);
            exit (-1);
        }
    }
}

- (Element*) complexTypeElement:(NSString*) name
{
    if ([name hasPrefix:@"t:"])
    {
        name = [name stringByReplacingOccurrencesOfString:@"t:" withString:@""];
    }
    for (Element* elem in [current children])
    {
        if ([[elem tagName] isEqual:@"complexType"])
        {
            if ([name isEqual:[elem name]]) return elem;
        }
    }
    return nil;
}

- (NSMutableArray*) elementsFromGroup:(NSString*)name
{
    name = [self trimNS:name];
    for (Element* elem in [current children])
    {
        if ([[elem tagName] isEqual:@"group"])
        {
            if ([name isEqual:[elem name]])
            {
                NSMutableArray *result = [[NSMutableArray alloc] init];

                for (Element* e in  [[[[[elem children] objectAtIndex:0] children] objectAtIndex:0] children])
                {
                    [e setGroup:name];
                    [result addObject:e];
                }
                return result;
            }
        }
    }
    NSAssert(NO, @"group not found");
    return nil;
}

- (Element*) baseClassElement:(NSString*) elem
{
    Element* e = [self complexTypeElement:elem];
    if (e)
    {
        if ([self forElement:e areChildren:@"complexContent"])
        {
            Element* complexContent = [[e children] objectAtIndex:0];
            NSAssert ([[e children] count] == 1, @"complexContent should be the only element");
            NSAssert ([[complexContent children] count] == 1, @"complexContent should have only element");

            Element* extension = [[complexContent children] objectAtIndex:0];
            NSAssert ([extension base], @"extension should have base spec");

            return [self complexTypeElement:[extension base]];
        }
     }
     return nil;
}

- (NSString*) baseClass:(NSString*) elem
{
    Element* e = [self complexTypeElement:elem];
    if ([self baseClassElement:elem])
    {
        e = [self baseClassElement:elem];
        return [[e resultType] stringByReplacingOccurrencesOfString:@"*" withString:@""];
    }

    if (e)
    {
        if ([[e children] count] == 0)
        {
            return @"NSObject";
        }
        if ([self forElement:e areChildren:@"simpleContent"])
        {
            Element* simpleContent = [[e children] objectAtIndex:0];
            NSAssert ([[e children] count] == 1, @"simpleContent should be the only element");
            NSAssert ([[simpleContent children] count] == 1, @"simpleContent should have only element");

            Element* extension = [[simpleContent children] objectAtIndex:0];
            NSAssert ([[extension tagName] isEqual:@"extension"], @"Only extension should be there");

            if ([[extension base] isEqual:@"xs:string"])
            {
                return @"EWSStringType";
            }
            if ([[extension base] isEqual:@"xs:base64Binary"])
            {
                return @"EWSBase64BinaryType";
            }
            NSAssert (NO, @"base extension can be string or base64Binary");
        }
    }
    return @"NSObject";
}

- (NSString*) contentHandlerClass:(NSString*) elem
{
    Element* e = [self complexTypeElement:elem];
    if (e)
    {
        if ([[e children] count] == 0)
        {
            return nil;
        }
        if ([self forElement:e areChildren:@"simpleContent"])
        {
            Element* simpleContent = [[e children] objectAtIndex:0];
            NSAssert ([[e children] count] == 1, @"simpleContent should be the only element");
            NSAssert ([[simpleContent children] count] == 1, @"simpleContent should have only element");

            Element* extension = [[simpleContent children] objectAtIndex:0];
            NSAssert ([[extension tagName] isEqual:@"extension"], @"Only extension should be there");

            if ([[extension base] isEqual:@"xs:string"])
            {
                return @"EWSStringTypeHandler";
            }
            if ([[extension base] isEqual:@"xs:base64Binary"])
            {
                return @"EWSBase64BinaryTypeHandler";
            }
            NSAssert (NO, @"base extension can be string or base64Binary");
        }
        else if ([self forElement:e areChildren:@"complexContent"])
        {
            Element* complexContent = [[e children] objectAtIndex:0];
            NSAssert ([[e children] count] == 1, @"complexContent should be the only element");
            NSAssert ([[complexContent children] count] == 1, @"complexContent should have only element");

            Element* extension = [[complexContent children] objectAtIndex:0];

            NSAssert ([extension base], @"extension should have base spec");
            return [self contentHandlerClass:[extension base]];
        }
    }
    return nil;
}

- (NSMutableArray*) attributes:(NSString*) elem getSuper:(BOOL)r
{

    NSMutableArray* result = [[NSMutableArray alloc] init];

    Element* e = [self complexTypeElement:elem];
    if (e)
    {
        if ([[e children] count] == 0)
        {
            return result;
        }
        if ([self forElement:e areChildren:@"sequence,attribute"])
        {
            for (Element * a in [e children])
            {
                if ([[a tagName] isEqual:@"attribute"] && [a name]) {
                    [result addObject:a];
                }
            }
            return result;
        }
        else if ([self forElement:e areChildren:@"simpleContent"])
        {
            Element* simpleContent = [[e children] objectAtIndex:0];
            NSAssert ([[e children] count] == 1, @"simpleContent should be the only element");
            NSAssert ([[simpleContent children] count] == 1, @"simpleContent should have only element");

            Element* extension = [[simpleContent children] objectAtIndex:0];
            NSAssert ([[extension tagName] isEqual:@"extension"], @"Only extension should be there");

            for (Element * a in [extension children])
            {
                if ([[a tagName] isEqual:@"attribute"] && [a name]) {
                    [result addObject:a];
                }
            }
            return result;
        }
        else if ([self forElement:e areChildren:@"complexContent"])
        {
            Element* complexContent = [[e children] objectAtIndex:0];
            NSAssert ([[e children] count] == 1, @"complexContent should be the only element");
            NSAssert ([[complexContent children] count] == 1, @"complexContent should have only element");

            Element* extension = [[complexContent children] objectAtIndex:0];

            if ([[extension tagName] isEqual:@"restriction"]) {
                if (r) {
                    [result addObjectsFromArray:[self attributes:[extension base] getSuper:r]];
                }
                return result;
            }

            NSAssert ([[extension tagName] isEqual:@"extension"], @"Only extension should be there");

            NSAssert ([extension base], @"extension should have base spec");

            if (r) {
                [result addObjectsFromArray:[self attributes:[extension base] getSuper:r]];
            }

            for (Element * a in [extension children]) {
                if ([[a tagName] isEqual:@"attribute"] && [a name]) {
                    [result addObject:a];
                }
            }
            return result;
        }
        else return nil;
    }
    return nil;
}

- (Element*) resolved:(Element*) elem
{
    if (![elem ref]) return elem;

    for (Element* e in [current children])
    {
        if ([[e tagName] isEqual:@"element"] && [[e name] isEqual:[self trimNS:[elem ref]]])
            return [self resolved:e];
    }
    NSAssert (NO, @"can't resolve");
    return nil;
}

- (NSMutableArray*) elements:(NSString*) elem getSuper:(BOOL)r
{
    int grp = 0;

    NSMutableArray* result = [[NSMutableArray alloc] init];

    Element* e = [self complexTypeElement:elem];
    if (e)
    {
        if ([[e children] count] == 0)
        {
            return result;
        }
        if ([self forElement:e areChildren:@"sequence,attribute"])
        {
            for (Element * a in [e children])
            {
                if ([[a tagName] isEqual:@"sequence"]) {
                    for (Element * x in [a children])
                    {
                        if ([[x tagName] isEqual:@"element"])
                        {
                            [result addObject:[self resolved:x]];
                        }
                        else if ([[x tagName] isEqual:@"group"])
                        {
                            [result addObjectsFromArray:[self elementsFromGroup:[x ref]]];
                        }
                    }
                }
            }
            return result;
        }
        else if ([self forElement:e areChildren:@"complexContent"])
        {
            Element* complexContent = [[e children] objectAtIndex:0];
            NSAssert ([[e children] count] == 1, @"complexContent should be the only element");
            NSAssert ([[complexContent children] count] == 1, @"complexContent should have only element");

            Element* extension = [[complexContent children] objectAtIndex:0];

            if ([[extension tagName] isEqual:@"restriction"])
            {
                if (r) {
                    [result addObjectsFromArray:[self elements:[extension base] getSuper:r]];
                }
                return result;
            }
            NSAssert ([[extension tagName] isEqual:@"extension"], @"Only extension should be there");

            NSAssert ([extension base], @"extension should have base spec");

            if (r) {
                [result addObjectsFromArray:[self elements:[extension base] getSuper:r]];
            }
            if ([[extension children] count] == 0) {
                return result;
            }
            NSAssert([self forElement:extension areChildren:@"choice,sequence,attribute"], @"extension has sequence or choice");

            for (Element * a in [extension children]) {
                if ([[a tagName] isEqual:@"choice"]) {
                    for (Element * x in [a children])
                    {
                        NSAssert ([[x tagName] isEqual:@"element"], @"choice can only have element");
                        [x setGroup:[[NSString alloc] initWithFormat:@"%@-%d", elem, ++grp]];
                        [result addObject:[self resolved:x]];
                    }
                }
                if ([[a tagName] isEqual:@"sequence"]) {
                    for (Element * x in [a children])
                    {
                        if ([[x tagName] isEqual:@"element"])
                        {
                            [result addObject:[self resolved:x]];
                        }
                        else if ([[x tagName] isEqual:@"group"])
                        {
                            [result addObjectsFromArray:[self elementsFromGroup:[x name]]];
                        }
                    }
                }
            }
            return result;
        }
        else  {
          return nil;
        }
    }
    return nil;
}

- (BOOL) allResolved:(NSArray*) elements
{
    for (Element* e in elements)
    {
        if (![self objectType:[e type]])
        {
            NSLog(@"Unresolved element %@", e);
            return FALSE;
        }
    }
    return TRUE;
}

- (void) generateStructForElement:(Element*) elem
{
    if ([self isArrayType:elem checkResolved:FALSE]) return;
    if (![[elem tagName] isEqual:@"complexType"])    return;

    NSString* name = [elem name];
    if (!name) return;

    NSLog(@"Testing struct %@", [elem name]);

    Element* base = [self baseClassElement:name];
    if (base && ![self resolved:base]) return;

    NSString* baseClassName = [self baseClass:name];

    NSArray* attributes = [self attributes:name getSuper:FALSE];
    NSArray* elements   = [self elements:name getSuper:FALSE];

    NSArray* s_attributes = base ? [self attributes:[base name] getSuper:TRUE] : [[NSArray alloc] init];
    NSArray* s_elements   = base ? [self elements:[base name]   getSuper:TRUE] : [[NSArray alloc] init];

    if ([self allResolved:attributes] &&
        [self allResolved:elements]   &&
        [self allResolved:s_attributes] &&
        [self allResolved:s_elements])
    {
        [self generateStructForElement:elem
              withAttributes:attributes withElements:elements 
              withSuperAttributes:s_attributes withSuperElements:s_elements andBaseClass:baseClassName
              simpleContentHandlerClass:[self contentHandlerClass:name]];
    }
}

@end


