//
//  ViewController.m
//  KiernanTest
//
//  Created by Matthew Kiernan on 3/27/15.
//  Copyright (c) 2015 Matt Kiernan. All rights reserved.
//

#import "ViewController.h"
#import <DropboxSDK/DropboxSDK.h>

@interface ViewController () <DBRestClientDelegate>
@property (nonatomic, strong) DBRestClient *restClient;
@end

@implementation ViewController

NSData *data;
NSString *file;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    self.restClient.delegate = self;
    
    login.hidden = NO;
    upload.hidden = YES;
    browse.hidden = YES;
    TakePhoto.hidden = YES;
    CameraRoll.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Login
-(IBAction)login:(id)sender{
    if (![[DBSession sharedSession] isLinked]) {
        [[DBSession sharedSession] linkFromController:self];
    }
    login.hidden = YES;
    upload.hidden = NO;
    browse.hidden = NO;
    TakePhoto.hidden = NO;
    CameraRoll.hidden = NO;
}

#pragma mark - Take Photo

-(IBAction)TakePhoto:(id)sender{
    
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *imagePicker =
        [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType =
        UIImagePickerControllerSourceTypeCamera;
        imagePicker.mediaTypes = @[(NSString *) kUTTypeImage];
        imagePicker.allowsEditing = NO;
        [self presentViewController:imagePicker
                           animated:YES completion:nil];
        _newMedia = YES;
    }
    
}

-(IBAction)CameraRoll:(id)sender{
    
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeSavedPhotosAlbum])
    {
        UIImagePickerController *imagePicker =
        [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType =
        UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.mediaTypes = @[(NSString *) kUTTypeImage];
        imagePicker.allowsEditing = NO;
        [self presentViewController:imagePicker
                           animated:YES completion:nil];
        _newMedia = NO;
    }
    
}

//For using camera roll
-(void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        
        _imageView.image = image;
        if (_newMedia)
            UIImageWriteToSavedPhotosAlbum(image,
                                           self,
                                           @selector(image:finishedSavingWithError:contextInfo:),
                                           nil);
        
        // ADDED ******************
        data = UIImagePNGRepresentation(_imageView.image);
        //        file = [NSTemporaryDirectory() stringByAppendingPathComponent:@"upload.png"];
        file = [NSTemporaryDirectory() stringByAppendingPathComponent:@"upload.png"];
    }
}

-(void)image:(UIImage *)image
finishedSavingWithError:(NSError *)error
 contextInfo:(void *)contextInfo
{
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Save failed"
                              message: @"Failed to save image"
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
}

//if user cancels taking pic
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)upload:(id)sender{
NSString *text = @"Hello world pt2.";
NSString *filename = @"working-draft2.txt";
NSString *localDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
NSString *localPath = [localDir stringByAppendingPathComponent:filename];
//[text writeToFile:localPath atomically:YES encoding:NSUTF8StringEncoding error:nil];

    [data writeToFile:file atomically:YES];
    //[DBRestClient uploadFile:@"upload.png" toPath:@"Dropbox/Path" fromPath:file];
    
// Upload file to Dropbox
NSString *destDir = @"/";
//[self.restClient uploadFile:filename toPath:destDir withParentRev:nil fromPath:localPath];
   [self.restClient uploadFile:@"upload.png" toPath:destDir withParentRev:nil fromPath:file];

}

- (void)restClient:(DBRestClient *)client uploadedFile:(NSString *)destPath
              from:(NSString *)srcPath metadata:(DBMetadata *)metadata {
    NSLog(@"File uploaded successfully to path: %@", metadata.path);
}

- (void)restClient:(DBRestClient *)client uploadFileFailedWithError:(NSError *)error {
    NSLog(@"File upload failed with error: %@", error);
}

#pragma mark - Browse DropBox

-(IBAction)browse:(id)sender{
    
}

@end
