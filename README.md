DZNPhotoPickerController
========================

A photo search/picker for iPhone using popular providers like 500px, Flickr, Intagram, Google Images, etc. This control tries to mimic as close as possible iOS7's UIImagePickerController in terms of features, appearance and behaviour.

### Features
* Search photos on mutiple service providers (500px, Flickr, Intagram & Google Images)
* Auto-completed typing for easier search (using Flickr's API as a common denominator).
* Present the photo picker with a pre-defined search term to automatically start searching.
* Exact same UI layouts and behaviours than UIImagePickerController.
* Edit photo selections with cropping guides (square and circular, like the Contacts app).
* Circular cropping mode for using with UIImagePickerController (check on UIImagePickerController+Edit).
* Creative Commons licences optional filtering.
* App Store safe. Innapropriate content disabled for all services.
* Disable photo selection downloads and retrieve metadata instead.
* iPhone (3.5" & 4") and iPad support.
* ARC & 64bits support.

![screenshots](https://dl.dropboxusercontent.com/u/2452151/Permalink/DZNPhotoPickerController_screenshots.png)
![services](https://dl.dropboxusercontent.com/u/2452151/Permalink/DZNPhotoPickerController_services.png)

## Installation

Available in [Cocoa Pods](http://cocoapods.org/?q=DZNPhotoPickerController)
```
pod 'DZNPhotoPickerController', '~> 1.2'
```

## How to use

### Step 1

```
Import "DZNPhotoPickerController.h"
```

### Step 2
Before even creating a new instance of DZNPhotoPickerController, it is recommended that you register to the photo services APIs on the NSObject's calss method +initialize, like so:
```
+ (void)initialize
{
    [DZNPhotoPickerController registerForServiceType:DZNPhotoPickerControllerService500px
                                    withConsumerKey:YOUR_500px_KEY
                                  andConsumerSecret:YOUR_500px_SECRET
                                  subscription:DZNPhotoPickerControllerSubscriptionFree];
    
    [DZNPhotoPickerController registerForServiceType:DZNPhotoPickerControllerServiceFlickr
                                    withConsumerKey:YOUR_Flickr_KEY
                                  andConsumerSecret:YOUR_Flickr_SECRET
                                  subscription:DZNPhotoPickerControllerSubscriptionFree];
}
```

### Step 3
Creating a new instance of DZNPhotoPickerController is very similar to what you would do with UIImagePickerController:
```
DZNPhotoPickerController *picker = [[DZNPhotoPickerController alloc] init];
picker.supportedServices = DZNPhotoPickerControllerService500px | DZNPhotoPickerControllerServiceFlickr;
picker.allowsEditing = YES;
picker.delegate = self;
    
[self presentViewController:picker animated:YES completion:NO];
````

You can additionally set more properties:
```
picker.initialSearchTerm = @"Surf";
picker.editingMode = DZNPhotoEditViewControllerCropModeCircular;
picker.enablePhotoDownload = YES;
picker.supportedLicenses = DZNPhotoPickerControllerCCLicenseBY_ALL;
````

### UIImagePickerController extension
Another great feature of DZNPhotoPickerController is to allow circular edit mode when using UIImagePickerController, just like the Contact app when editing a user's avatar image.<br>
Its use is really straightforward: on the delegate's method -imagePickerController:didFinishPickingMediaWithInfo: just call DZNPhotoEditViewController's class method +editImage:cropMode:inNavigationController. This will push the controller to the edit mode, and will then call -imagePickerController:didFinishPickingMediaWithInfo: once more, after user's interaction, but with a different editingMode value.

```
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if (picker.editingMode == DZNPhotoEditViewControllerCropModeCircular) {
        
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        [DZNPhotoEditViewController editImage:image cropMode:picker.editingMode inNavigationController:picker];
    }
}
```

### Sample project
Take a look into the sample project. Everything is there.<br>

### Collaboration
Feel free to collaborate with this project! Big thanks to:
- [SJ Singh](https://github.com/SJApps): Google Images search support.
- [Felipe Saint-Jean](https://github.com/fsaint): 64bits fix of the editing guides.


## Apps using DZNPhotoPickerController
Are you using this control in your apps? Let me know at [iromero@dzen.cl](mailto:iromero@dzen.cl).<br>

- [Epiclist](https://itunes.apple.com/us/app/id789778193/)


## License
(The MIT License)

Copyright (c) 2014 Ignacio Romero Zurbuchen <iromero@dzen.cl>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the 'Software'), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
