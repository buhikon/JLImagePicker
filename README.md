# JLImagePicker

[![CI Status](http://img.shields.io/travis/Joey Lee/JLImagePicker.svg?style=flat)](https://travis-ci.org/Joey Lee/JLImagePicker)
[![Version](https://img.shields.io/cocoapods/v/JLImagePicker.svg?style=flat)](http://cocoapods.org/pods/JLImagePicker)
[![License](https://img.shields.io/cocoapods/l/JLImagePicker.svg?style=flat)](http://cocoapods.org/pods/JLImagePicker)
[![Platform](https://img.shields.io/cocoapods/p/JLImagePicker.svg?style=flat)](http://cocoapods.org/pods/JLImagePicker)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

JLImagePicker is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "JLImagePicker"
```

## Usage
```
[JLImagePicker takePhotoOnViewController:self.viewController
                                  camera:JLImagePickerCameraFront
                           allowsEditing:YES
                              completion:^(BOOL success, UIImage *image, AVAuthorizationStatus authStatus) {
                                  if(success) {
                                      // do something with the image
                                  }
                                  else {
                                      if(authStatus == AVAuthorizationStatusRestricted) {
                                          // alert
                                      }
                                      else if(authStatus == AVAuthorizationStatusDenied) {
                                          // alert + go to Settings app
                                      }
                                  }
                              }];
```

## Author

Joey Lee, slarinz@gmail.com

## License

JLImagePicker is available under the MIT license. See the LICENSE file for more info.
