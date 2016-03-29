#import <Foundation/Foundation.h>
#import "MPSEWSBaseRequestType.h"



@class MPSEWSNonEmptyArrayOfBaseFolderIdsType;
@class MPSEWSTargetFolderIdType;



/* BaseMoveCopyFolderType */
@interface MPSEWSBaseMoveCopyFolderType : MPSEWSBaseRequestType

+ (void) initialize;

- (id) init;
- (Class) handlerClass;
- (NSString*) description;

@property (strong) MPSEWSTargetFolderIdType*               toFolderId;
@property (strong) MPSEWSNonEmptyArrayOfBaseFolderIdsType* folderIds;


@end
