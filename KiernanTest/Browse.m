////
////  Browse.m
////  KiernanTest
////
////  Created by Matthew Kiernan on 3/28/15.
////  Copyright (c) 2015 Matt Kiernan. All rights reserved.
////


#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>


#import "Browse.h"

@interface Browse ()

@end

NSString *pathcomp;
@implementation Browse

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (DBRestClient *)restClient {
    if (!restClient) {
        restClient =
        [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
    }
    return restClient;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    dropboxURLs = [[NSMutableArray alloc] init];
    [[self restClient] loadMetadata:@"/"];
}

- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
    if (metadata.isDirectory) {
        for (DBMetadata *file in metadata.contents) {
            if (!file.isDirectory)
            {
                NSLog(@"%@", file.filename);
                pathcomp = file.filename;
                [dropboxURLs addObject:file.filename];
                [self DBdownload];
                
             //   [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
            }
        }
    }
    [self.tableView reloadData];
}

- (void)restClient:(DBRestClient *)client loadedFile:(NSString *)localPath
       contentType:(NSString *)contentType metadata:(DBMetadata *)metadata {
    NSLog(@"File loaded into path: %@", localPath);
}

-(void) DBdownload//:(id)sender
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents directory
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"/"];
    NSError *error;
        
    [self.restClient loadFile:@"/KiernanTest/" intoPath:filePath];
    
    if (filePath) { // check if file exists - if so load it:
        NSString *tempTextOut = [NSString stringWithContentsOfFile:pathcomp
                                                          encoding:NSUTF8StringEncoding
                                                             error:&error];
    }
}


- (void)restClient:(DBRestClient *)client loadMetadataFailedWithError:(NSError *)error {
    
    NSLog(@"Error loading metadata: %@", error);
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return dropboxURLs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FileCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [dropboxURLs objectAtIndex:indexPath.row];
    
    return cell;
}


@end