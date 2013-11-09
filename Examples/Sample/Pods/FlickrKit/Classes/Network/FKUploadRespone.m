//
//  FKUploadRespone.m
//  FlickrKit
//
//  Created by David Casserly on 06/06/2013.
//  Copyright (c) 2013 DevedUp Ltd. All rights reserved. http://www.devedup.com
//

#import "FKUploadRespone.h"
#import "FKDataTypes.h"

@interface FKUploadRespone ()
@property (nonatomic, strong) NSMutableString *currentElementContent;
@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) NSString *photoID;
@property (nonatomic, strong) NSError *error;
@end

@implementation FKUploadRespone

- (id) initWithData:(NSData *)data {
    self = [super init];
    if (self) {
        self.data = data;
        
#ifdef DEBUG
        NSString *dataString = [NSString.alloc initWithData:self.data encoding:NSUTF8StringEncoding];
        NSLog(@"%@", dataString);
#endif
    }
    return self;
}

- (BOOL) parse {
	NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:self.data];
	xmlParser.delegate = self;
	return [xmlParser parse];
}

#pragma mark - Parser delegate methods

- (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
	
	self.currentElementContent = nil;
	
	BOOL success = NO;
	if ([elementName isEqualToString:@"rsp"]) {
		NSString *status = [attributeDict objectForKey:@"stat"];
		if ([status isEqualToString:@"ok"]) {
			success = YES;
		} else if ([status isEqualToString:@"fail"]) {
			success = NO;
		}
	}
	
	if ([elementName isEqualToString:@"err"]) {
		NSString *errorCodeString = [attributeDict objectForKey:@"code"];
		NSString *errorDescription = [attributeDict objectForKey:@"msg"];
		
		NSInteger errorCode = [errorCodeString integerValue];
		NSDictionary *userInfo = @{NSLocalizedDescriptionKey: errorDescription};
		NSError *error = [NSError errorWithDomain:FKFlickrAPIErrorDomain code:errorCode userInfo:userInfo];
		self.error = error;
	}
	
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (!self.currentElementContent) {
        // currentStringValue is an NSMutableString instance variable
        self.currentElementContent = [[NSMutableString alloc] initWithCapacity:50];
    }
    [self.currentElementContent appendString:string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	if ([elementName isEqualToString:@"photoid"]) {
		self.photoID = [self.currentElementContent copy];
	}	
}

@end
