//
//  FKDUStreamUtil.m
//  FlickrKit
//
//  Created by David Casserly on 10/06/2013.
//  Copyright (c) 2013 DevedUp Ltd. All rights reserved. http://www.devedup.com
//

#import "FKDUStreamUtil.h"

@implementation FKDUStreamUtil

+ (void) writeMultipartStartString:(NSString *)startString imageStream:(NSInputStream *)imageInputStream toOutputStream:(NSOutputStream *)outputStream closingString:(NSString *)closingString {
    const char *UTF8String;
    size_t writeLength;
    UTF8String = [startString UTF8String];
    writeLength = strlen(UTF8String);
	
	size_t __unused actualWrittenLength;
	actualWrittenLength = [outputStream write:(uint8_t *)UTF8String maxLength:writeLength];
    NSAssert(actualWrittenLength == writeLength, @"Start string not writtern");
	
    // open the input stream
    const size_t bufferSize = 65536;
    size_t readSize = 0;
    uint8_t *buffer = (uint8_t *)calloc(1, bufferSize);
    NSAssert(buffer, @"Buffer not created");
	
    [imageInputStream open];
    while ([imageInputStream hasBytesAvailable]) {
        if (!(readSize = [imageInputStream read:buffer maxLength:bufferSize])) {
            break;
        }        
		
		size_t __unused actualWrittenLength;
		actualWrittenLength = [outputStream write:buffer maxLength:readSize];
        NSAssert (actualWrittenLength == readSize, @"Image stream not written");
    }
    
    [imageInputStream close];
    free(buffer);
    
    
    UTF8String = [closingString UTF8String];
    writeLength = strlen(UTF8String);
	actualWrittenLength = [outputStream write:(uint8_t *)UTF8String maxLength:writeLength];
    NSAssert(actualWrittenLength == writeLength, @"Closing string not written");
    [outputStream close];    
}

@end
