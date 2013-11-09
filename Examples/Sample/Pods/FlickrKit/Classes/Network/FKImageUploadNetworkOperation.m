//
//  FKImageUploadNetworkOperation.m
//  FlickrKit
//
//  Created by David Casserly on 06/06/2013.
//  Copyright (c) 2013 DevedUp Ltd. All rights reserved. http://www.devedup.com
//

#import "FKImageUploadNetworkOperation.h"
#import "FlickrKit.h"
#import "FKURLBuilder.h"
#import "FKUtilities.h"
#import "FKUploadRespone.h"
#import "FKDUStreamUtil.h"

@interface FKImageUploadNetworkOperation ()
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, retain) NSString *tempFile;
@property (nonatomic, copy) FKAPIImageUploadCompletion completion;
@property (nonatomic, retain) NSDictionary *args;
@property (nonatomic, assign) CGFloat uploadProgress;
@property (nonatomic, assign) NSUInteger fileSize;
@end

@implementation FKImageUploadNetworkOperation

- (id) initWithImage:(UIImage *)image arguments:(NSDictionary *)args completion:(FKAPIImageUploadCompletion)completion; {
    self = [super init];
    if (self) {
		self.image = image;
		self.args = args;
		self.completion = completion;
    }
    return self;
}

#pragma mark - DUOperation methods

- (void) cancel {
	self.completion = nil;
	[self cleanupTempFile:self.tempFile];
	[super cancel];
}

- (void) finish {
	self.completion = nil;
	[self cleanupTempFile:self.tempFile];
	[super finish];
}

#pragma mark - Create the request

- (void) cleanupTempFile:(NSString *)uploadTempFilename {
    if (uploadTempFilename) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:uploadTempFilename]) {
			BOOL __unused removeResult = NO;
			NSError *error = nil;
			removeResult = [fileManager removeItemAtPath:uploadTempFilename error:&error];
			NSAssert(removeResult, @"Should be able to remove temp file");
        }        
        uploadTempFilename = nil;
    }
}

- (NSMutableURLRequest *) createRequest:(NSError **)error {
	// Setup args
	NSMutableDictionary *newArgs = self.args ? [NSMutableDictionary dictionaryWithDictionary:self.args] : [NSMutableDictionary dictionary];
	newArgs[@"format"] = @"json";

//#ifdef DEBUG
//    [newArgs setObject:@"0" forKey:@"is_public"];
//    [newArgs setObject:@"0" forKey:@"is_friend"];
//    [newArgs setObject:@"0" forKey:@"is_family"];
//    [newArgs setObject:@"2" forKey:@"hidden"];
//#endif
    
    // Build a URL to the upload service
	FKURLBuilder *urlBuilder = [[FKURLBuilder alloc] init];
	NSDictionary *args = [urlBuilder signedArgsFromParameters:newArgs method:FKHttpMethodPOST url:[NSURL URLWithString:@"http://api.flickr.com/services/upload/"]];
	
	// Form multipart needs a boundary 
	NSString *multipartBoundary = FKGenerateUUID();
	
	// File name
	NSString *inFilename = [self.args valueForKey:@"title"];
	if (!inFilename) {
        inFilename = @" "; // Leave space so that the below still uploads a file
    } else {
        inFilename = [inFilename stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
    
    // The multipart opening string
	NSMutableString *multipartOpeningString = [NSMutableString string];
	for (NSString *key in args.allKeys) {
		[multipartOpeningString appendFormat:@"--%@\r\nContent-Disposition: form-data; name=\"%@\"\r\n\r\n%@\r\n", multipartBoundary, key, [args valueForKey:key]];
	}
    [multipartOpeningString appendFormat:@"--%@\r\nContent-Disposition: form-data; name=\"photo\"; filename=\"%@\"\r\n", multipartBoundary, inFilename];
    [multipartOpeningString appendFormat:@"Content-Type: %@\r\n\r\n", @"image/jpeg"];
	
	// The multipart closing string
	NSMutableString *multipartClosingString = [NSMutableString string];
	[multipartClosingString appendFormat:@"\r\n--%@--", multipartBoundary];
    
	// The temp file to write this multipart to
	NSString *tempFileName = [NSTemporaryDirectory() stringByAppendingFormat:@"%@.%@", @"FKFlickrTempFile", FKGenerateUUID()];
	self.tempFile = tempFileName;	
	
	// Output stream is the file... 
    NSOutputStream *outputStream = [NSOutputStream outputStreamToFileAtPath:tempFileName append:NO];
    [outputStream open];
	
	// Input stream is the image
	NSData *imgData = UIImageJPEGRepresentation(self.image, 1.0);
	NSInputStream *inImageStream = [[NSInputStream alloc] initWithData:imgData];
	
	// Write the contents to the streams... don't cross the streams !
	[FKDUStreamUtil writeMultipartStartString:multipartOpeningString imageStream:inImageStream toOutputStream:outputStream closingString:multipartClosingString];

	// Get the file size
    NSDictionary *fileInfo = [[NSFileManager defaultManager] attributesOfItemAtPath:tempFileName error:error];
    NSNumber *fileSize = nil;
    if (fileInfo) {
        fileSize = [fileInfo objectForKey:NSFileSize];
        self.fileSize = [fileSize integerValue];
    } else {
        //we have the error populated
        return nil;
    }	

    // Now the input stream for the request is the file just created
	NSInputStream *inputStream = [NSInputStream inputStreamWithFileAtPath:tempFileName];	
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://api.flickr.com/services/upload/"]];
	[request setHTTPMethod:@"POST"];
	[request setHTTPBodyStream:inputStream];
	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", multipartBoundary];
	[request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    [request setValue:[fileSize stringValue] forHTTPHeaderField:@"Content-Length"];
    
    return request;
}

#pragma mark - NSURLConnection Delegate methods

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	if (self.completion) {
		self.completion(nil, error);
	}
    [self finish];
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		
		FKUploadRespone *response = [[FKUploadRespone alloc] initWithData:self.receivedData];
		BOOL success = [response parse];
		
		if (!success) {
			NSString *errorString = @"Cannot parse response data from image upload";
			NSDictionary *userInfo = @{NSLocalizedDescriptionKey: errorString};
			NSError *error = [NSError errorWithDomain:FKFlickrKitErrorDomain code:FKErrorResponseParsing userInfo:userInfo];
			if (self.completion) {
				self.completion(nil, error);
			}
		} else {
			if (self.completion) {
				self.completion(response.photoID, response.error);
			}
		}
		
	});
}

- (void) connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
	
    // Calculate the progress
    self.uploadProgress = (CGFloat) totalBytesWritten / (CGFloat) self.fileSize;
    
#ifdef DEBUG
    NSLog(@"file size is %i", self.fileSize);
	NSLog(@"Sent %i, total Sent %i, expected total %i", bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
    NSLog(@"Upload progress is %f", self.uploadProgress);
#endif
}

@end



