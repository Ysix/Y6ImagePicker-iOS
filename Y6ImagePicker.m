//
//  Y6ImagePicker.m
//
//
//  Created by Ysix on 28/04/2015.
//
//

#import "Y6ImagePicker.h"
#import <UIKit/UIKit.h>

@interface Y6ImagePicker () <UIImagePickerControllerDelegate, UIAlertViewDelegate, UINavigationControllerDelegate>
{
	UIViewController *sourceViewController;
	UIAlertView *requestPictureAV;
	void (^theCompletionBlock)(UIImage *);
}

@end

@implementation Y6ImagePicker

#pragma mark - picture selection methods

+ (id)sharedPicker
{
	static Y6ImagePicker *sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self alloc] init];
	});
	return sharedInstance;
}

+ (void)requestPictureFromViewController:(UIViewController *)viewController andOnCompletion:(void (^)(UIImage *picture))completionBlock
{
	[[Y6ImagePicker sharedPicker] requestPictureFromViewController:viewController andOnCompletion:completionBlock];
}

- (void)requestPictureFromViewController:(UIViewController *)viewController andOnCompletion:(void (^)(UIImage *picture))completionBlock
{
//	_allowEditing = YES;

	theCompletionBlock = completionBlock;
	sourceViewController = viewController;

	requestPictureAV = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"RequestPicture_alert_title", @"Y6ImagePicker", nil)
												  message:NSLocalizedStringFromTable(@"RequestPicture_alert_message", @"Y6ImagePicker", nil)
												 delegate:self
										cancelButtonTitle:NSLocalizedStringFromTable(@"RequestPicture_alert_existingPictureChoice", @"Y6ImagePicker", nil)
										otherButtonTitles:NSLocalizedStringFromTable(@"RequestPicture_alert_newPictureChoice", @"Y6ImagePicker", nil), nil];
	[requestPictureAV show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (requestPictureAV == alertView)
	{
		UIImagePickerControllerSourceType sourceType;

		if (buttonIndex == 1) // new picture
		{
			sourceType = UIImagePickerControllerSourceTypeCamera;
		}
		else if (buttonIndex == 0) // existing picture
		{
			sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
		}
		else
		{
			return;
		}

		if ([UIImagePickerController isSourceTypeAvailable:sourceType])
		{
			UIImagePickerController *imagePickerController;
			imagePickerController = [[UIImagePickerController alloc] init];
			imagePickerController.allowsEditing = _allowEditing;
			imagePickerController.delegate = self;
			imagePickerController.sourceType = sourceType;
			[sourceViewController presentViewController:imagePickerController animated:YES completion:nil];
		}
		else
		{
			[[[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"Common_alert_title_error", @"Y6ImagePicker", nil) message:NSLocalizedStringFromTable(@"RequestPicture_SourceUnavailable_alert_message", @"Y6ImagePicker", nil) delegate:nil cancelButtonTitle:NSLocalizedStringFromTable(@"Common_alert_button_text_ok", @"Y6ImagePicker", nil) otherButtonTitles:nil] show];
		}
	}
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	theCompletionBlock(nil);
	[picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	UIImage *image = [info objectForKey:(_allowEditing ? UIImagePickerControllerEditedImage : UIImagePickerControllerOriginalImage)];

	if (image.imageOrientation != UIImageOrientationUp || _allowEditing)
	{
		UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
		[image drawInRect:(CGRect){0, 0, image.size}];
		UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		image = normalizedImage;
	}

	theCompletionBlock(image);
	[picker dismissViewControllerAnimated:YES completion:^{

		sourceViewController = nil;
		theCompletionBlock = nil;
		requestPictureAV = nil;

	}];
}

@end
