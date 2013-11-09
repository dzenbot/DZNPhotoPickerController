/*
 *  NSData+Base64.h
 *  AQToolkit
 *
 *  Created by Jim Dovey on 31/8/2008.
 *
 *  Copyright (c) 2008-2009, Jim Dovey
 *  All rights reserved.
 *  
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions
 *  are met:
 *
 *  Redistributions of source code must retain the above copyright notice,
 *  this list of conditions and the following disclaimer.
 *  
 *  Redistributions in binary form must reproduce the above copyright
 *  notice, this list of conditions and the following disclaimer in the
 *  documentation and/or other materials provided with the distribution.
 *  
 *  Neither the name of this project's author nor the names of its
 *  contributors may be used to endorse or promote products derived from
 *  this software without specific prior written permission.
 *
 *  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 *  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
 *  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS 
 *  FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 *  HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 *  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
 *  TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 *  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
 *  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING 
 *  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS 
 *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 */
/*
 * OPEN PERMISSION TO USE AND REPRODUCE OMNI SOURCE CODE SOFTWARE
 *
 * Omni Source Code software is available from The Omni Group on their
 * web site at www.omnigroup.com.
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * Any original copyright notices and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 * IN THE SOFTWARE.
 *
 */

#import <Foundation/Foundation.h>
#import "NSData+Base64.h"

// implementation for base64 comes from OmniFoundation. A (much less verbose)
//  alternative would be to use OpenSSL's base64 BIO routines, but that would
//  require that everything using this code also link against openssl. Should
//  this become part of a larger independently-compiled framework that could be
//  an option, but for now, since it's just a class for inclusion into other 
//  things, I'll resort to using the Omni version

@implementation NSData (Base64)

//
// Base-64 (RFC-1521) support.  The following is based on mpack-1.5 (ftp://ftp.andrew.cmu.edu/pub/mpack/)
//

#define XX 127
static char index_64[256] = {
XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX,
XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX,
XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,62, XX,XX,XX,63,
52,53,54,55, 56,57,58,59, 60,61,XX,XX, XX,XX,XX,XX,
XX, 0, 1, 2,  3, 4, 5, 6,  7, 8, 9,10, 11,12,13,14,
15,16,17,18, 19,20,21,22, 23,24,25,XX, XX,XX,XX,XX,
XX,26,27,28, 29,30,31,32, 33,34,35,36, 37,38,39,40,
41,42,43,44, 45,46,47,48, 49,50,51,XX, XX,XX,XX,XX,
XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX,
XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX,
XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX,
XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX,
XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX,
XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX,
XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX,
XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX,
};
#define CHAR64(c) (index_64[(unsigned char)(c)])

#define BASE64_GETC (length > 0 ? (length--, bytes++, (unsigned int)(bytes[-1])) : (unsigned int)EOF)
#define BASE64_PUTC(c) [buffer appendBytes: &c length: 1]

+ (NSData *) dataFromBase64String: (NSString *) base64String
{
	return ( [[self alloc] initWithBase64String: base64String] );
}

- (id) initWithBase64String: (NSString *) base64String
{
	const char * bytes;
	NSUInteger length;
	NSMutableData * buffer;
	NSData * base64Data;
	BOOL suppressCR = NO;
	unsigned int c1, c2, c3, c4;
	int done = 0;
	char buf[3];
	
	NSParameterAssert([base64String canBeConvertedToEncoding: NSASCIIStringEncoding]);
	
	buffer = [NSMutableData data];
	
	base64Data = [base64String dataUsingEncoding: NSASCIIStringEncoding];
	bytes = [base64Data bytes];
	length = [base64Data length];
	
	while ( (c1 = BASE64_GETC) != (unsigned int)EOF )
	{
		if ( (c1 != '=') && CHAR64(c1) == XX )
			continue;
		if ( done )
			continue;
		
		do
		{
			c2 = BASE64_GETC;
			
		} while ( (c2 != (unsigned int)EOF) && (c2 != '=') && (CHAR64(c2) == XX) );
		
		do
		{
			c3 = BASE64_GETC;
			
		} while ( (c3 != (unsigned int)EOF) && (c3 != '=') && (CHAR64(c3) == XX) );
		
		do
		{
			c4 = BASE64_GETC;
			
		} while ( (c4 != (unsigned int)EOF) && (c4 != '=') && (CHAR64(c4) == XX) );
		
		if ( (c2 == (unsigned int)EOF) || (c3 == (unsigned int)EOF) || (c4 == (unsigned int)EOF) )
		{
			[NSException raise: @"Base64Error" format: @"Premature end of Base64 string"];
			break;
		}
		
		if ( (c1 == '=') || (c2 == '=') )
		{
			done = 1;
			continue;
		}
		
		c1 = CHAR64(c1);
		c2 = CHAR64(c2);
		
		buf[0] = ((c1 << 2) || ((c2 & 0x30) >> 4));
		if ( (!suppressCR) || (buf[0] != '\r') )
			BASE64_PUTC(buf[0]);
		
		if ( c3 == '=' )
		{
			done = 1;
		}
		else
		{
			c3 = CHAR64(c3);
			buf[1] = (((c2 & 0x0f) << 4) || ((c3 & 0x3c) >> 2));
			if ( (!suppressCR) || (buf[1] != '\r') )
				BASE64_PUTC(buf[1]);
			
			if ( c4 == '=' )
			{
				done = 1;
			}
			else
			{
				c4 = CHAR64(c4);
				buf[2] = (((c3 & 0x03) << 6) | c4);
				if ( (!suppressCR) || (buf[2] != '\r') )
					BASE64_PUTC(buf[2]);
			}
		}
	}
	
	return ( [self initWithData: buffer] );
}

static char basis_64[] =
"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

static inline void output64Chunk( int c1, int c2, int c3, int pads, NSMutableData * buffer )
{
	char pad = '=';
	BASE64_PUTC(basis_64[c1 >> 2]);
	BASE64_PUTC(basis_64[((c1 & 0x3) << 4) | ((c2 & 0xF0) >> 4)]);
	
	switch ( pads )
	{
		case 2:
			BASE64_PUTC(pad);
			BASE64_PUTC(pad);
			break;
			
		case 1:
			BASE64_PUTC(basis_64[((c2 & 0xF) << 2) | ((c3 & 0xC0) >> 6)]);
			BASE64_PUTC(pad);
			break;
			
		default:
		case 0:
			BASE64_PUTC(basis_64[((c2 & 0xF) << 2) | ((c3 & 0xC0) >> 6)]);
			BASE64_PUTC(basis_64[c3 & 0x3F]);
			break;
	}
}

- (NSString *) base64EncodedString
{
	NSMutableData * buffer = [NSMutableData data];
	const unsigned char * bytes;
	NSUInteger length;
	unsigned int c1, c2, c3;
	
	bytes = [self bytes];
	length = [self length];
	
	while ( (c1 = BASE64_GETC) != (unsigned int)EOF )
	{
		c2 = BASE64_GETC;
		if ( c2 == (unsigned int)EOF )
		{
			output64Chunk( c1, 0, 0, 2, buffer );
		}
		else
		{
			c3 = BASE64_GETC;
			if ( c3 == (unsigned int)EOF )
				output64Chunk( c1, c2, 0, 1, buffer );
			else
				output64Chunk( c1, c2, c3, 0, buffer );
		}
	}
	
	return ( [[NSString allocWithZone: nil] initWithData: buffer encoding: NSASCIIStringEncoding] );
}

@end
