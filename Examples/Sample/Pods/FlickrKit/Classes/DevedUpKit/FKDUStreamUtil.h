//
//  FKDUStreamUtil.h
//  FlickrKit
//
//  Created by David Casserly on 10/06/2013.
//  Copyright (c) 2013 DevedUp Ltd. All rights reserved. http://www.devedup.com
//

#import <Foundation/Foundation.h>

@interface FKDUStreamUtil : NSObject

+ (void) writeMultipartStartString:(NSString *)startString imageStream:(NSInputStream *)imageInputStream toOutputStream:(NSOutputStream *)outputStream closingString:(NSString *)closingString;

@end
