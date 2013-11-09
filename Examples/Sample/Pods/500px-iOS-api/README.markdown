Writing a wrapper for the 500px API in Objective-C to make it easier for developers to write apps against this awesome service.

Stil a work in progress; I'm only working on this in my spare time. It currently supports reading from the 500px API and retrieving photos, users, favourites, followers, etc. Check out the [API Documentation](https://github.com/500px/api-documentation) for more information.

## Requirements

This project requires LLVM 4.0+ and Xcode 4.5+, and is compiled with ARC.

## How to use:

Go to your Xocde project directory and type the following:

    git submodule init
    git submodule add git://github.com/500px/500px-iOS-api.git

Once the submodule has finished downloading, drag and drop the new Xcode project into your existing project.

![Drag and drop subproject](http://static.ashfurrow.com.s3.amazonaws.com/github/subproject.png)

Now that the subproject is added, we need to link against it. Expand the subproject's Products folder and drag the `libPXAPI.a` file into your projects "Link Binary With libraries" list in the project details editor.

![Drag and drop the library to be linked against](http://static.ashfurrow.com.s3.amazonaws.com/github/linking.png)

Under "Build Settings", add an additional Linker flag of `-ObjC`.

![Additional linker flag](http://static.ashfurrow.com.s3.amazonaws.com/github/linkerflag.png)

Now that you're linking against the library, you're almost done! Wherever you want to use the 500px API, make sure you import the `PXAPI.h` file:

    #import <PXAPI/PXAPI.h>

Also in your project's build settings, find "Header Search Paths" and add `$(SRCROOT)` and check the box indicating a recurisve search.

**NOTE**: If the path to your project contains spaces, you *must* put `$(SRCROOT)` (and all other custom search paths) in quotes.

![Header Search Path](http://static.ashfurrow.com/github/headerpath.png)

In your application delegate's `application:didFinishLaunchingWithOptions:` method, add this line to set your consumer key and consumer secret:

    [PXRequest setConsumerKey:@"__CHANGE_ME__" consumerSecret:@"__CHANGE_ME__"];

Got to the [500px Applications Page](http://500px.com/settings/applications?from=developers) to register for your consumer key and secret.

There are two ways to use this library. The first is to use the `PXAPIHelper` class methods to generate `NSURLRequest` objects to use directly (either with `NSURLConnection` or [`ASIHTTPRequest`](https://github.com/pokeb/asi-http-request/tree). The other way is to use the built-in `PXRequest` class methods to create requests against the 500px API; they provide a completion block that is executed after the request returns, and they also post notifications to the default `NSNotificationCenter`.

## Tests

The library currently has a suite of integration tests that run against the live 500px API. In order to run these tests, you *must* replace the following values in `PXIntegrationTests.h`.

    #define kUserNameForAuthentication  @"__CHANGE_ME__"
    #define kPasswordForAuthentication  @"__CHANGE_ME__"
    
    #define kPXAPIConsumerKey       @"__CHANGE_ME__"
    #define kPXAPIConsumerSecret    @"__CHANGE_ME__"

There are also some unit tests. OCMock tragically does not allow us to test class methods, so the unit tests are unforunately limited in their scope. However, between the unit tests and the integration tests, coverage is pretty solid.
