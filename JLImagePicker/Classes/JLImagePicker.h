//
//  JLImagePicker.h
//
//  Version 0.1.3
//
//  Created by Joey L. on Aug/11/16.
//  Copyright © 2016 Joey L. All rights reserved.
//
//  https://github.com/buhikon/JLImagePicker
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>


typedef void(^JLImagePickerCameraCompletion)(BOOL success, UIImage *image, AVAuthorizationStatus authStatus);
typedef void(^JLImagePickerAlbumCompletion)(BOOL success, UIImage *image, NSURL *url, PHAuthorizationStatus authStatus);

typedef NS_ENUM(NSInteger, JLImagePickerCamera) {
    JLImagePickerCameraFront = 0,
    JLImagePickerCameraRear
};

@interface JLImagePicker : NSObject

// take photo from camera
+ (void)takePhotoOnViewController:(UIViewController *)viewController
                           camera:(JLImagePickerCamera)camera
                    allowsEditing:(BOOL)allowsEditing
                       completion:(JLImagePickerCameraCompletion)completion;

// pick photo from album
+ (void)pickPhotoOnViewController:(UIViewController *)viewController
                    allowsEditing:(BOOL)allowsEditing
                       completion:(JLImagePickerAlbumCompletion)completion;


@end
