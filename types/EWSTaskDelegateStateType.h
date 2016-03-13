#import <Foundation/Foundation.h>

#import "../handlers/EWSSimpleTypeHandler.h"


/** SimpleType: TaskDelegateStateType can be one of the following:
 *       1 NoMatch
 *       2 OwnNew
 *       3 Owned
 *       4 Accepted
 *       5 Declined
 *       6 Max
 */
@interface EWSTaskDelegateStateType : EWSSimpleTypeHandler 

/** Register a handler to parse TaskDelegateStateType */
+ (void) initialize;

/** Initialize the handler */
- (id) init;
- (id) initWithClass:(Class) cls;

/** Process the characters */
- (NSString *) updateObject:(NSString *)obj withCharacters:(NSString*)s;

/** Write to the buffer the string value */
- (void) writeXmlInto:(NSMutableString*)buffer for:(NSString *) object;


/* Valid values */
+ (NSString *) NoMatch;
+ (NSString *) OwnNew;
+ (NSString *) Owned;
+ (NSString *) Accepted;
+ (NSString *) Declined;
+ (NSString *) Max;
@end
