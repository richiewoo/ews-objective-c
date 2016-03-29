#import <Foundation/Foundation.h>

#import "MPSEWSNonEmptyStringType.h"


/** SimpleType: WatermarkType is string  */
@interface MPSEWSWatermarkType : MPSEWSNonEmptyStringType 

/** Register a handler to parse WatermarkType */
+ (void) initialize;

/** Initialize the handler */
- (id) init;
- (id) initWithClass:(Class) cls;

@end
