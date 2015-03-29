//
//  ViewController.m
//  KiernanTest
//
//  Created by Matthew Kiernan on 3/27/15.
//  Copyright (c) 2015 Matt Kiernan. All rights reserved.
//

#import "ViewController.h"
#import <DropboxSDK/DropboxSDK.h>

@interface ViewController () <DBRestClientDelegate, CLLocationManagerDelegate>
@property (nonatomic, strong) DBRestClient *restClient;
@end

@implementation ViewController{
    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
   // MKPointAnnotation *point;// = [[MKPointAnnotation alloc] init];
}

NSData *data;
NSString *file;
NSString *city;
NSString *takenAt;
NSString *text;

float longcoord, latcoord;

CLLocation *userLocation;
CLLocationCoordinate2D coordinate;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    self.restClient.delegate = self;
    
    //maps
    locationManager = [[CLLocationManager alloc] init];
    geocoder = [[CLGeocoder alloc] init];
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.delegate = self;
    
    if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [locationManager requestWhenInUseAuthorization];
    }
    
    [locationManager requestWhenInUseAuthorization];
    [locationManager requestAlwaysAuthorization];
    
    if (![[DBSession sharedSession] isLinked]) {
    
    login.hidden = NO;
    upload.hidden = YES;
    browse.hidden = YES;
    TakePhoto.hidden = YES;
    CameraRoll.hidden = YES;
    }
    else
        login.hidden = YES;
    
    [self getlocation];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - GPS

- (NSString *)deviceLocation {
    return [NSString stringWithFormat:@"latitude: %f longitude: %f", locationManager.location.coordinate.latitude, locationManager.location.coordinate.longitude];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    
    
    if (currentLocation != nil) {
        [locationManager stopUpdatingLocation];
        
        
    }
    
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager setDistanceFilter:kCLDistanceFilterNone];
    
    [locationManager startUpdatingLocation];

    coordinate = [userLocation coordinate];
    
    
    //REVERSE LOOKUP
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        
        if(error == nil && [placemarks count]>0){
            placemark = [placemarks lastObject];
            city = placemark.locality;
            NSLog(@"THIS IS THE CITY: %@",city);
            takenAt = [NSString stringWithFormat:@"Mobile Upload, %@.png",city];
        }
        else
            NSLog(@"%@",error.debugDescription);
    }];
    
}

-(void)getlocation
{
//NSA
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusNotDetermined) {
        NSLog(@"Requesting when in use auth");
        [locationManager requestWhenInUseAuthorization];
    }
    
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager setDistanceFilter:kCLDistanceFilterNone];
    
    [locationManager startUpdatingLocation];
    
    coordinate = [userLocation coordinate];
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

//Assume physical camera code works, can't test
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
        
        data = UIImagePNGRepresentation(_imageView.image);
        file = [NSTemporaryDirectory() stringByAppendingPathComponent:takenAt];
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
        file = [NSTemporaryDirectory() stringByAppendingPathComponent:takenAt];
    }
} //// *************  MAKE SURE TO CHANGE THIS ALONG WITH THE PHYSICAL CAMERA *********************//

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

#pragma mark - Upload
-(IBAction)upload:(id)sender{
    
    //Trying to leave coordinates as note w/ pic
    text = [NSString stringWithFormat:@"Latitude: %f \nLongitude: %f", locationManager.location.coordinate.latitude, locationManager.location.coordinate.longitude];
    
NSString *filename = text;
NSString *localDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
NSString *localPath = [localDir stringByAppendingPathComponent:filename];
[text writeToFile:localPath atomically:YES encoding:NSUTF8StringEncoding error:nil];

    [data writeToFile:file atomically:YES];
    
// Upload file to Dropbox
    NSString *destDir = @"/";
    [self.restClient uploadFile:takenAt toPath:destDir withParentRev:nil fromPath:file];
 //   [self.restClient uploadFile:text toPath:destDir withParentRev:nil fromPath:file];

}

- (void)restClient:(DBRestClient *)client uploadedFile:(NSString *)destPath
              from:(NSString *)srcPath metadata:(DBMetadata *)metadata {
    NSLog(@"File uploaded successfully to path: %@", metadata.path);
}

- (void)restClient:(DBRestClient *)client uploadFileFailedWithError:(NSError *)error {
    NSLog(@"File upload failed with error: %@", error);
}

#pragma mark - Browse DropBox

//-(IBAction)browse:(id)sender{
//    [locationManager stopUpdatingLocation];
//}
////-(IBAction)browse:(id)sender{
////    
////    [self.restClient loadMetadata:@"/"];
////    
////}
////
////- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
////    if (metadata.isDirectory) {
////        NSLog(@"Folder '%@' contains:", metadata.path);
////        for (DBMetadata *file in metadata.contents) {
////            NSLog(@"	%@", file.filename);
////        }
////    }
////}
////
////- (void)restClient:(DBRestClient *)client
////loadMetadataFailedWithError:(NSError *)error {
////    NSLog(@"Error loading metadata: %@", error);
////}

@end
