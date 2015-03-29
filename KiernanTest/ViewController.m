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
    
    //[self.GPSMap addGestureRecognizer:lpgr];
    
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
    
//    userLocation= [[CLLocation alloc]
//                   initWithLatitude:GPSMap.userLocation.coordinate.latitude
//                   longitude:GPSMap.userLocation.coordinate.longitude];
    coordinate = [userLocation coordinate];
    
    
  //  NSLog(@"COORDINATES: %@",coordinate);
    
    
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        
        if(error == nil && [placemarks count]>0){
            placemark = [placemarks lastObject];
            city = placemark.locality;
            NSLog(@"THIS IS THE CITY: %@",city);
        }
        else
            NSLog(@"%@",error.debugDescription);
    }];
    
}

-(void)getlocation
{
    // [CLLocationManager requestWhenInUseAuthorization];
    // [CLLocationManager requestAlwaysAuthorization];
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusNotDetermined) {
        NSLog(@"Requesting when in use auth");
        [locationManager requestWhenInUseAuthorization];
    }
    
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager setDistanceFilter:kCLDistanceFilterNone];
    
    [locationManager startUpdatingLocation];
    
    coordinate = [userLocation coordinate];
   // NSLog(@"COORDINATES: %@",coordinate);
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
        
        data = UIImagePNGRepresentation(_imageView.image);
        //        file = [NSTemporaryDirectory() stringByAppendingPathComponent:@"upload.png"];
        file = [NSTemporaryDirectory() stringByAppendingPathComponent:@"this.png"];
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
        file = [NSTemporaryDirectory() stringByAppendingPathComponent:@"this.png"];
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

-(IBAction)upload:(id)sender{
//NSString *text = @"Hello world pt2.";
//NSString *filename = @"working-draft2.txt";
//NSString *localDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
//NSString *localPath = [localDir stringByAppendingPathComponent:filename];
//[text writeToFile:localPath atomically:YES encoding:NSUTF8StringEncoding error:nil];

    [data writeToFile:file atomically:YES];
    
// Upload file to Dropbox
    NSString *destDir = @"/";
    [self.restClient uploadFile:@"this.png" toPath:destDir withParentRev:nil fromPath:file];

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
//    
//    [self.restClient loadMetadata:@"/"];
//    
//}
//
//- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
//    if (metadata.isDirectory) {
//        NSLog(@"Folder '%@' contains:", metadata.path);
//        for (DBMetadata *file in metadata.contents) {
//            NSLog(@"	%@", file.filename);
//        }
//    }
//}
//
//- (void)restClient:(DBRestClient *)client
//loadMetadataFailedWithError:(NSError *)error {
//    NSLog(@"Error loading metadata: %@", error);
//}

@end
