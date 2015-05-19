//
//  Y6ImagePicker.h
//
//
//  Created by Ysix on 28/04/2015.
//  
//

#import <Foundation/Foundation.h>

@class  UIImage;
@class  UIViewController;

@interface Y6ImagePicker : NSObject

@property BOOL allowEditing;

+ (void)requestPictureFromViewController:(UIViewController *)viewController andOnCompletion:(void (^)(UIImage *picture))completionBlock;

- (void)requestPictureFromViewController:(UIViewController *)viewController andOnCompletion:(void (^)(UIImage *picture))completionBlock;

@end
