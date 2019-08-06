//
//  JLImagePicker.m
//  Version 0.1.2
//
//  Created by Joey L. on Aug/11/16.
//  Copyright © 2016 Joey L. All rights reserved.
//
//  https://github.com/buhikon/JLImagePicker
//

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Either turn on ARC for the project or use -fobjc-arc flag
#endif


#import "JLImagePicker.h"


@interface JLImagePicker () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (copy, nonatomic) JLImagePickerCameraCompletion cameraCompletion;
@property (copy, nonatomic) JLImagePickerAlbumCompletion albumCompletion;
@property (assign, nonatomic) AVAuthorizationStatus cameraStatus;
@property (assign, nonatomic) PHAuthorizationStatus albumStatus;
@property (weak, nonatomic) UIViewController *viewController;
@end

@implementation JLImagePicker

static JLImagePicker *instance = nil;

#pragma mark -
#pragma mark singleton

+ (JLImagePicker *)sharedInstance
{
    @synchronized(self)
    {
        if (!instance)
            instance = [[JLImagePicker alloc] init];
        
        return instance;
    }
}

#pragma mark - public methods

// take photo from camera
+ (void)takePhotoOnViewController:(UIViewController *)viewController
                           camera:(JLImagePickerCamera)camera
                    allowsEditing:(BOOL)allowsEditing
                       completion:(JLImagePickerCameraCompletion)completion {
    [[JLImagePicker sharedInstance] takePhotoOnViewController:viewController
                                                allowsEditing:allowsEditing
                                                       camera:camera
                                                   completion:completion];
}

// pick photo from album
+ (void)pickPhotoOnViewController:(UIViewController *)viewController
                    allowsEditing:(BOOL)allowsEditing
                       completion:(JLImagePickerAlbumCompletion)completion {
    [[JLImagePicker sharedInstance] pickPhotoOnViewController:viewController
                                                allowsEditing:allowsEditing
                                                   completion:completion];
}

#pragma mark - private methods

- (void)requestCameraPermissions:(void(^)(BOOL granted, AVAuthorizationStatus status))block {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    self.cameraStatus = authStatus;
    
    if(authStatus == AVAuthorizationStatusAuthorized) {
        block(YES, authStatus);
    } else if(authStatus == AVAuthorizationStatusDenied) {
        block(NO, authStatus);
    } else if(authStatus == AVAuthorizationStatusRestricted) {
        block(NO, authStatus);
    } else if(authStatus == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
                self.cameraStatus = authStatus;
                block(granted, authStatus);
            });
        }];
    } else {
        block(NO, authStatus);
    }
}

- (void)requestAlbumPermissions:(void(^)(BOOL granted, PHAuthorizationStatus status))block
{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    self.albumStatus = status;
    
    switch (status) {
        case PHAuthorizationStatusAuthorized:
            block(YES, status);
            break;
        case PHAuthorizationStatusNotDetermined: {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus authorizationStatus) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.albumStatus = authorizationStatus;
                    if (authorizationStatus == PHAuthorizationStatusAuthorized) {
                        block(YES, authorizationStatus);
                    }
                    else {
                        block(NO, authorizationStatus);
                    }
                });
            }];
            break;
        }
        default:
            block(NO, status);
            break;
    }
}

- (void)takePhotoOnViewController:(UIViewController *)viewController
                    allowsEditing:(BOOL)allowsEditing
                           camera:(JLImagePickerCamera)camera
                       completion:(JLImagePickerCameraCompletion)completion {
    
    [self requestCameraPermissions:^(BOOL granted, AVAuthorizationStatus status) {
        if(granted) {
            if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
                self.cameraCompletion = completion;
                UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
                imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                imagePickerController.delegate = self;
                imagePickerController.allowsEditing = allowsEditing;
                imagePickerController.cameraDevice = (camera == JLImagePickerCameraFront) ? UIImagePickerControllerCameraDeviceFront : UIImagePickerControllerCameraDeviceRear;
                [viewController presentViewController:imagePickerController animated:YES completion:nil];
            }
            else {
                // no cameras detected (e.g. simulator)
                if(completion) {
                    completion(NO, nil, status);
                }
            }
        }
        else {
            if(completion) {
                completion(NO, nil, status);
            }
        }
    }];
}

- (void)pickPhotoOnViewController:(UIViewController *)viewController
                    allowsEditing:(BOOL)allowsEditing
                       completion:(JLImagePickerAlbumCompletion)completion {
    
    [self requestAlbumPermissions:^(BOOL granted, PHAuthorizationStatus status) {
        if(granted) {
            self.albumCompletion = completion;
            
            UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            imagePickerController.delegate = self;
            imagePickerController.allowsEditing = allowsEditing;
            [viewController presentViewController:imagePickerController animated:YES completion:nil];
        }
        else {
            if(completion) {
                completion(NO, nil, nil, status);
            }
        }
    }];
    
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    UIImage *image = [info valueForKey:UIImagePickerControllerEditedImage];
    if(!image) {
        image = [info valueForKey:UIImagePickerControllerOriginalImage];
    }
    NSURL *url = [info valueForKey:UIImagePickerControllerReferenceURL];
    
    [picker dismissViewControllerAnimated:YES completion:^{
        if(self.cameraCompletion) {
            self.cameraCompletion(YES, image, self.cameraStatus);
        }
        self.cameraCompletion = nil;
        
        if(self.albumCompletion) {
            self.albumCompletion(YES, image, url, self.albumStatus);
        }
        self.albumCompletion = nil;
    }];;
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^{
        if(self.cameraCompletion) {
            self.cameraCompletion(NO, nil, self.cameraStatus);
        }
        self.cameraCompletion = nil;
        
        if(self.albumCompletion) {
            self.albumCompletion(NO, nil, nil, self.albumStatus);
        }
        self.albumCompletion = nil;
    }];;
}


@end

