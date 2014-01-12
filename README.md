DZNPhotoPickerController
========================

A photo search/picker using popular providers like 500px, Flickr and many others..
This framework tries to mimic as close as possible the native UIImagePickerController API for iOS7, in terms of features, appearance and behavior.

### Features
* Search photos on mutiple service providers (Only 500px and Flickr for now)
* Present the photo picker with a pre-defined search term to automatically start searching.
* Exact same UI layouts and behavious than UIImagePickerController.
* Edit photo selections with manual cropping.
* Circular crop (like Contacts app) and custom crop size support.
* Support for custom edition mode while using UIImagePickerController.

![UIPhotoPickerController](https://dl.dropboxusercontent.com/u/2452151/Permalink/DZNPhotoPickerController.png)


## Installation

Available in [Cocoa Pods](http://cocoapods.org/?q=DZNPhotoPickerController)
```
pod 'DZNPhotoPickerController', '~> 1.0.2'
```

## How to use

### Step 1

```
Import "<DZNPhotoPickerController/DZNPhotoPickerController.h>" on your view controller.
```

### Step 2
Before even creating a new instance of DZNPhotoPickerController, it is recommended that you register to the photo services APIs on the +[NSObject initialize] method, like so:
```
+ (void)initialize
{
    [DZNPhotoPickerController registerForServiceType:DZNPhotoPickerControllerServiceType500px
                                    withConsumerKey:YOUR_500px_KEY
                                  andConsumerSecret:YOUR_500px_SECRET];
    
    [DZNPhotoPickerController registerForServiceType:DZNPhotoPickerControllerServiceTypeFlickr
                                    withConsumerKey:YOUR_Flickr_KEY
                                  andConsumerSecret:YOUR_Flickr_SECRET];
}
```

### Step 3
Instantiating a DZNPhotoPickerController is very similar to instantiate a UIImagePickerController object:
```
DZNPhotoPickerController *_controller = [[DZNPhotoPickerController alloc] init];
_controller.allowsEditing = YES;
_controller.serviceType = DZNPhotoPickerControllerServiceType500px | DZNPhotoPickerControllerServiceTypeFlickr;
_controller.delegate = self;
    
[self presentViewController:_controller animated:YES completion:NO];
````

You can additionally set more properties:
```
_controller.initialSearchTerm = @"Surf";
_controller.editingMode = DZNPhotoEditViewControllerCropModeCircular;
````

### Sample project
Take a look into the sample project. Everything is there.<br>


## License
(The MIT License)

Copyright (c) 2013 Ignacio Romero Zurbuchen <iromero@dzen.cl>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the 'Software'), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
