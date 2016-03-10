#import <Foundation/Foundation.h>

@protocol EWSHandlerProtocol <NSObject>
/** Object construction from XML document */
- (id) constructWithAttributes: (NSDictionary *)attributes;

/** Handling of characters in the XML document. */
- (id) updateObject:(id)obj withCharacters:(NSString*)s;

/** Handling of subelements */
- (id) updateObject:(id)obj forKey:(NSString*)tag withValue:(id)v;

/** The handler for a sub tag. */
- (id<EWSHandlerProtocol>) handlerForElement:(NSString*) elementName;


/** XML String generation from Object representation */
- (void) writeXmlInto:(NSMutableString*)buffer for:(id) object withIndentationDepth:(int) depth;

/** During pretty print, is the element inlined */
- (BOOL) isInline;
@end

