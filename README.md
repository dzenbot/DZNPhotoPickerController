UIPhotoPickerController
========================

A photo picker for iOS 7 using popular photo services like 500px, Flickr and many others.
This framework tries to mimic as close as possible the native UIImagePickerController API for iOS7, in terms of features, appearance and behavior.

### Features
* Search photos on mutiple service providers (Only 500px and Flickr for now)
* Present the photo picker with a pre-defined search term to automatically start searching.
* Exact same UI layouts and behavious than UIImagePickerController.
* Edit photo selections with manual cropping.
* Circular crop (like Contacts app) and custom crop size support.
* Support for custom edition mode while using UIImagePickerController.

![UIPhotoPickerController](https://dl.dropboxusercontent.com/u/2452151/Permalink/UIPhotoPickerController.png)


## Installation

Available in [Cocoa Pods](http://cocoapods.org/?q=UIPhotoPickerController)
```
pod 'UIPhotoPickerController', '~> 1.0'
```

## How to use
[Online documentation and API reference](http://cocoadocs.org/docsets/UIPhotoPickerController/1.0/)

### Step 1

```
Import "UIPhotoPickerController.h" to your Application Delegate class.
```

### Step 2
Before even creating a new instance of UIPhotoPickerController, it is recommended that you register to the photo services APIs on the +[NSObject initialize] method, like so:
```
+ (void)initialize
{
    [UIPhotoPickerController registerForServiceType:UIPhotoPickerControllerServiceType500px
                                    withConsumerKey:YOUR_500px_KEY
                                  andConsumerSecret:YOUR_500px_SECRET];
    
    [UIPhotoPickerController registerForServiceType:UIPhotoPickerControllerServiceTypeFlickr
                                    withConsumerKey:YOUR_Flickr_KEY
                                  andConsumerSecret:YOUR_Flickr_SECRET];
}
```

### Step 3
Calling a UIPhotoPickerController is very similar to calling UIImagePickerController:
```
UIPhotoPickerController *_controller = [[UIPhotoPickerController alloc] init];
_controller.allowsEditing = YES;
_controller.serviceType = UIPhotoPickerControllerServiceType500px | UIPhotoPickerControllerServiceTypeFlickr;
_controller.delegate = self;
    
[self presentViewController:_controller animated:YES completion:NO];
````

You can additionally set more properties:
```
_controller.initialSearchTerm = @"Surf";
_controller.editingMode = UIPhotoEditViewControllerCropModeCircular;
````

### Sample project
Take a look into the sample project. Everything is there.<br>


## License
(The MIT License)

Copyright (c) 2012 Ignacio Romero Zurbuchen <iromero@dzen.cl>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the 'Software'), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
