#import <Foundation/Foundation.h>



@class MPSEWSArrayOfStringsType;
@class MPSEWSBodyType;
@class MPSEWSEffectiveRightsType;
@class MPSEWSExtendedPropertyType;
@class MPSEWSFolderIdType;
@class MPSEWSItemIdType;
@class MPSEWSMimeContentType;
@class MPSEWSNonEmptyArrayOfAttachmentsType;
@class MPSEWSNonEmptyArrayOfInternetHeadersType;
@class MPSEWSNonEmptyArrayOfResponseObjectsType;



/* ItemType */
@interface MPSEWSItemType : NSObject

+ (void) initialize;

- (id) init;
- (Class) handlerClass;
- (NSString*) description;

@property (strong) MPSEWSMimeContentType*                       mimeContent;
@property (strong) MPSEWSItemIdType*                            itemId;
@property (strong) MPSEWSFolderIdType*                          parentFolderId;
@property (strong) NSString*                                    itemClass                   /* MPSEWSItemClassType */;
@property (strong) NSString*                                    subject                     /* xs:string */;
@property (strong) NSString*                                    sensitivity                 /* MPSEWSSensitivityChoicesType */;
@property (strong) MPSEWSBodyType*                              body;
@property (strong) MPSEWSNonEmptyArrayOfAttachmentsType*        attachments;
@property (strong) NSString*                                    dateTimeReceived            /* xs:dateTime */;
@property (strong) NSNumber*                                    size                        /* xs:int */;
@property (strong) MPSEWSArrayOfStringsType*                    categories;
@property (strong) NSString*                                    importance                  /* MPSEWSImportanceChoicesType */;
@property (strong) NSString*                                    inReplyTo                   /* xs:string */;
@property (strong) NSNumber*                                    isSubmitted                 /* xs:boolean */;
@property (strong) NSNumber*                                    isDraft                     /* xs:boolean */;
@property (strong) NSNumber*                                    isFromMe                    /* xs:boolean */;
@property (strong) NSNumber*                                    isResend                    /* xs:boolean */;
@property (strong) NSNumber*                                    isUnmodified                /* xs:boolean */;
@property (strong) MPSEWSNonEmptyArrayOfInternetHeadersType*    internetMessageHeaders;
@property (strong) NSString*                                    dateTimeSent                /* xs:dateTime */;
@property (strong) NSString*                                    dateTimeCreated             /* xs:dateTime */;
@property (strong) MPSEWSNonEmptyArrayOfResponseObjectsType*    responseObjects;
@property (strong) NSString*                                    reminderDueBy               /* xs:dateTime */;
@property (strong) NSNumber*                                    reminderIsSet               /* xs:boolean */;
@property (strong) NSNumber*                                    reminderMinutesBeforeStart  /* MPSEWSReminderMinutesBeforeStartType */;
@property (strong) NSString*                                    displayCc                   /* xs:string */;
@property (strong) NSString*                                    displayTo                   /* xs:string */;
@property (strong) NSNumber*                                    hasAttachments              /* xs:boolean */;
@property (strong) NSMutableArray<MPSEWSExtendedPropertyType*>* extendedProperty;
@property (strong) NSString*                                    culture                     /* xs:language */;
@property (strong) MPSEWSEffectiveRightsType*                   effectiveRights;
@property (strong) NSString*                                    lastModifiedName            /* xs:string */;
@property (strong) NSString*                                    lastModifiedTime            /* xs:dateTime */;


- (void) addExtendedProperty:(MPSEWSExtendedPropertyType*) elem;
@end
