# FlickrKit

FlickrKit is an iOS Objective-C library for accessing the Flickr API written by David Casserly. It is used by [galleryr pro iPad app](https://itunes.apple.com/gb/app/flickr-gallery-pro/id525519823?mt=8).


Features
--------

Who needs FlickrKit when we have ObjectiveFlickr? Why not? I used ObjectiveFlickr for a long time, and a some of the methods in this libary were born from ObjectiveFlickr. However, I sometimes had problems debugging ObjectiveFlickr as the networking code was custom and not familiar to me - and I provide a little bit more too…

* You have a few ways to call methods - using string method name/dictionary params - or using the Model classes that have been generated for every Flickr API call available! It's up to you - or mix it up!
* All methods return an NSOperation subclass, so you have the ability to cancel requests easily, requests are put onto an operation queue.
* FlickrKit uses latest iOS libraries where possible, and is built with ARC and uses block callbacks. So it's internals should be familiar.
*  Errors are packaged properly into NSError objects, again more familiarity.
*  There is a default disk caching of Flickr responses - you are allowed to cache up to 24 hrs. You can specify the cache time per request.
*  The code is (hopefully) easy to read and debug, as it uses standard iOS networking components in the simplest way possible.
*  It is (partially) unit tested. 
*  There is a demo project to see it's usage.
*  There is a vastly simplified authentication mechanism, which is by far the most complicated part of using Flickr APi - even when using ObjectiveFlickr.
*  The model classes are auto generated and include all error codes, params, validation, documentation. The code generation project is also included in the source if you need to regenerate.
*  Maybe there are more features that i've neglected to mentions… give it a go!
 
###### Limitations 
I don't support Mac OS X (as i've never worked with that ..sorry! - ports welcome!). I don't support the old authentication method or migration - it only uses OAuth - which is almost a year old with Flickr now anyway. It only supports single user authentication - so doesn't support multiple flickr accounts


Requirements
------------
FlickrKit requires iOS 6.0 and above and uses ARC. It may be compatible with older OS's, but I haven't tested this.

If you are using FlickrKit in your non-arc project, you will need to set a `-fobjc-arc` compiler flag on all of the FlickrKit source files. 

To set a compiler flag in Xcode, go to your active target and select the "Build Phases" tab. Now select all FlickrKit source files, press Enter, insert `-fobjc-arc` and then "Done" to enable ARC for FlickrKit.

Installation
-------------
1. Drag FlickrKit.xcodeproj into your project.
2. In your project target, build phases, target dependencies... add FlickrKit as a depenendency
3. In your project target, build phases, link binary with library... add libFlickrKit.a
4. In build settings > header search paths... point to FlickrKit classes directory, recursively
5. Include SystemConfiguration.framework 

Usage
-------------
Inluded in the source is a demo project that shows you how to get started. It has a few example use cases. The UI isn't pretty! - but the important part is the usage of the API in the code.

##### API Notes
 * You need to start the library using initializeWithAPIKey:sharedSecret: which you will get from your flickr account
 * completion callbacks are not called on the main thread, so you must ensure you do any UI related work on the main thread
 * Flickr allow you to cache responses for up to 24 hrs, you can pass the maxCacheAge for the number of minutes you want to cache this for.
 * You can provide your own cache implementation if you want and plug it into FlickrKit. See [FlickrKit.h]
 * You can use either the string/dictionary call methods - or you can use the model api, where you use a model class. The advantage of the model classes are the clarity and the validation/error messaging built into them. They also contain all the flickr documentation. They are auto generated from the flickr API and can be regenerated with FKAPIBuilder class if the API updates.
 
##### Authentication 
 
 * You start auth using beginAuthWithCallbackURL with the url that flickr will call back to your app - completion callback gives you a url that you can present in a webview.
 * Once the user has logged in and flickr calls back to your app, you can pass this to completeAuthWithURL.
 * We store the auth token in NSUserDefaults - so when you launch your app again, you can call checkAuthorizationOnSuccess to see if the user is already validated.
 * Calling logout will remove all stored tokens and the user will have to authenticate again.

#### Startup
You can get an API Key and Secret from your Flickr account. You need these to use the API.

    [[FlickrKit sharedFlickrKit] initializeWithAPIKey:@"YOUR_KEY" sharedSecret:@"YOUR_SECRET"];

#### Load Interesting Photos - Flickr Explore 
This example demonstrates using the generated Flickr API Model classes.

	FlickrKit *fk = [FlickrKit sharedFlickrKit];
	FKFlickrInterestingnessGetList *interesting = [[FKFlickrInterestingnessGetList alloc] init];
	[fk call:interesting completion:^(NSDictionary *response, NSError *error) {
		// Note this is not the main thread!
		if (response) {				
			NSMutableArray *photoURLs = [NSMutableArray array];
			for (NSDictionary *photoData in [response valueForKeyPath:@"photos.photo"]) {
				NSURL *url = [fk photoURLForSize:FKPhotoSizeSmall240 fromPhotoDictionary:photoData];
				[photoURLs addObject:url];
			}
			dispatch_async(dispatch_get_main_queue(), ^{
				// Any GUI related operations here
			});
		}	
	}];
	
#### Your Photostream Photos
This example uses the string/dictionary method of calling FlickrKit, and alternative to using the Model classes. It also demonstrates passing a cache time of one hour, meaning if you call this again withing the hour - it will hit the cache and not the network. Fast!

	[[FlickrKit sharedFlickrKit] call:@"flickr.photos.search" args:@{@"user_id": self.userID, @"per_page": @"15"} maxCacheAge:FKDUMaxAgeOneHour completion:^(NSDictionary *response, NSError *error) {
			dispatch_async(dispatch_get_main_queue(), ^{
				if (response) {
					// extract images from the resonse dictionary	
				} else {
					// show the error
				}
			});			
		}];

#### Uploading a Photo
Uploading a photo and observing it's progress. imagePicked comes from the UIImagePickerControllerDelegate, but could be any UIImage.

	self.uploadOp = [[FlickrKit sharedFlickrKit] uploadImage:imagePicked args:uploadArgs completion:^(NSString *imageID, NSError *error) {
		dispatch_async(dispatch_get_main_queue(), ^{
			if (error) {
				// oops!
			} else {
				// Image is now in flickr!
			}            
        });
	}];    
    [self.uploadOp addObserver:self forKeyPath:@"uploadProgress" options:NSKeyValueObservingOptionNew context:NULL];


Unit Tests
-----------
Unit what? Just kidding. There are a few unit tests - but I'm still working on them - honest!


License and Warranty
--------------------
The license for the code is included with the project; it's basically a BSD license with attribution.

You're welcome to use it in commercial, closed-source, open source, free or any other kind of software, as long as you credit me appropriately.

The FlickrKit code comes with no warranty of any kind. I hope it'll be useful to you (it certainly is to me), but I make no guarantees regarding its functionality or otherwise.

Contact
-------
I can't answer any questions about how to use the code, but I always welcome emails telling me that you're using it, or just saying thanks.

If you create an app which uses the code, I'd also love to hear about it. You can find my contact details on my web site, listed below.

Likewise, if you want to submit a feature request or bug report, feel free to get in touch. Better yet, fork the code and implement the feature/fix yourself, then submit a pull request.

Enjoy!

Thanks,  
David Casserly

Me:      http://www.davidjc.com  
My Work: http://www.devedup.com 
Twitter: http://twitter.com/devedup  
Hire Me: http://linkedin.davidjc.com 