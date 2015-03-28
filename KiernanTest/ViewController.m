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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    self.restClient.delegate = self;
    
    login.hidden = NO;
    upload.hidden = YES;
    browse.hidden = YES;
    TakePhoto.hidden =YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)didPressLink:(id)sender{
    if (![[DBSession sharedSession] isLinked]) {
        [[DBSession sharedSession] linkFromController:self];
    }
    login.hidden = YES;
    upload.hidden = NO;
    browse.hidden = NO;
    TakePhoto.hidden =NO;
}

-(IBAction)upload:(id)sender{
NSString *text = @"Hello world pt2.";
NSString *filename = @"working-draft2.txt";
NSString *localDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
NSString *localPath = [localDir stringByAppendingPathComponent:filename];
[text writeToFile:localPath atomically:YES encoding:NSUTF8StringEncoding error:nil];

// Upload file to Dropbox
NSString *destDir = @"/";
[self.restClient uploadFile:filename toPath:destDir withParentRev:nil fromPath:localPath];

}

- (void)restClient:(DBRestClient *)client uploadedFile:(NSString *)destPath
              from:(NSString *)srcPath metadata:(DBMetadata *)metadata {
    NSLog(@"File uploaded successfully to path: %@", metadata.path);
}

- (void)restClient:(DBRestClient *)client uploadFileFailedWithError:(NSError *)error {
    NSLog(@"File upload failed with error: %@", error);
}

@end
