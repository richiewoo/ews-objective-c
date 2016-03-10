#import <Foundation/Foundation.h>

#import "../handlers/EWSSimpleTypeHandler.h"


/** DaysOfWeekType is a list ofcan be one of the following:
 *       1 Sunday
 *       2 Monday
 *       3 Tuesday
 *       4 Wednesday
 *       5 Thursday
 *       6 Friday
 *       7 Saturday
 *       8 Day
 *       9 Weekday
 *       10 WeekendDay
 */
@interface EWSDaysOfWeekType : EWSSimpleTypeHandler 

/** Register a handler to parse DaysOfWeekType */
+ (void) initialize;

/** Initialize the handler */
- (id) init;
- (id) initWithClass:(Class) cls;

/** construct an empty list */
- (NSMutableArray*) construct;

/** Process the characters */
- (NSMutableArray *) updateObject:(NSMutableArray *)obj withCharacters:(NSString*)s;

/** Write to the buffer the string value */
- (void) writeXmlInto:(NSMutableString*)buffer forObject:(NSMutableArray *) object;

@end

