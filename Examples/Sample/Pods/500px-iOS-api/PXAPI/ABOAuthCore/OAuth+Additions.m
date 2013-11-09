//
//  OAuth+Additions.m
//
//  Created by Loren Brichter on 6/9/10.
//  Copyright 2010 Loren Brichter. All rights reserved.
//

#import "OAuth+Additions.h"

@implementation NSString (OAuthAdditions)

- (NSDictionary *)ab_parseURLQueryString
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	NSArray *pairs = [self componentsSeparatedByString:@"&"];
	for(NSString *pair in pairs) {
		NSArray *keyValue = [pair componentsSeparatedByString:@"="];
		if([keyValue count] == 2) {
			NSString *key = [keyValue objectAtIndex:0];
			NSString *value = [keyValue objectAtIndex:1];
			value = [value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			if(key && value)
            {
                if ([key hasSuffix:@"[]"])
                {
                    NSString *keyWithoutArrayBrackets = [key stringByReplacingOccurrencesOfString:@"[]" withString:@""];
                    NSArray *existingArray = [dict valueForKey:keyWithoutArrayBrackets];
                    
                    NSArray *arrayWithNewValue = @[value];
                    
                    if (existingArray)
                    {
                        arrayWithNewValue = [existingArray arrayByAddingObjectsFromArray:arrayWithNewValue];
                    }
                    
                    [dict setObject:arrayWithNewValue forKey:keyWithoutArrayBrackets];
                }
                else
                {
                    [dict setObject:value forKey:key];
                }
            }
		}
	}
	return [NSDictionary dictionaryWithDictionary:dict];
}

- (NSString *)ab_RFC3986EncodedString // UTF-8 encodes prior to URL encoding
{
	NSMutableString *result = [NSMutableString string];
	const char *p = [self UTF8String];
	unsigned char c;
	
	for(; (c = *p); p++)
	{
		switch(c)
		{
            case '0':
            case '1':
            case '2':
            case '3':
            case '4':
            case '5':
            case '6':
            case '7':
            case '8':
            case '9':
            case 'A':
            case 'B':
            case 'C':
            case 'D':
            case 'E':
            case 'F':
            case 'G':
            case 'H':
            case 'I':
            case 'J':
            case 'K':
            case 'L':
            case 'M':
            case 'N':
            case 'O':
            case 'P':
            case 'Q':
            case 'R':
            case 'S':
            case 'T':
            case 'U':
            case 'V':
            case 'W':
            case 'X':
            case 'Y':
            case 'Z':
            case 'a':
            case 'b':
            case 'c':
            case 'd':
            case 'e':
            case 'f':
            case 'g':
            case 'h':
            case 'i':
            case 'j':
            case 'k':
            case 'l':
            case 'm':
            case 'n':
            case 'o':
            case 'p':
            case 'q':
            case 'r':
            case 's':
            case 't':
            case 'u':
            case 'v':
            case 'w':
            case 'x':
            case 'y':
            case 'z':
			case '.':
			case '-':
			case '~':
			case '_':
				[result appendFormat:@"%c", c];
				break;
			default:
				[result appendFormat:@"%%%02X", c];
		}
	}
	return result;
}

+ (NSString *)ab_GUID
{
	CFUUIDRef u = CFUUIDCreate(kCFAllocatorDefault);
	CFStringRef s = CFUUIDCreateString(kCFAllocatorDefault, u);
	CFRelease(u);
	return (__bridge NSString *)s;
}

@end

