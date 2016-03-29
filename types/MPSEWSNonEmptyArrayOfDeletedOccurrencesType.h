#import <Foundation/Foundation.h>



@class MPSEWSDeletedOccurrenceInfoType;



/* NonEmptyArrayOfDeletedOccurrencesType */
@interface MPSEWSNonEmptyArrayOfDeletedOccurrencesType : NSObject

+ (void) initialize;

- (id) init;
- (Class) handlerClass;
- (NSString*) description;

@property (strong) NSMutableArray<MPSEWSDeletedOccurrenceInfoType*>* deletedOccurrence;


- (void) addDeletedOccurrence:(MPSEWSDeletedOccurrenceInfoType*) elem;
@end
