////
////  Browse.m
////  KiernanTest
////
////  Created by Matthew Kiernan on 3/28/15.
////  Copyright (c) 2015 Matt Kiernan. All rights reserved.
////
//
//#import <Foundation/Foundation.h>
//#import "Browse.h"
////#import <DropboxSDK/DropboxSDK.h>
//
//@interface Browse ()
//
//@end
//
//
//@implementation Browse
//
//
////    - (void)viewDidLoad {
////        [super viewDidLoad];
////        
////        self->restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
////        self->restClient.delegate = self;
////        
////        [self->restClient loadMetadata:@"/"];
////    }
//
//- (id)initWithStyle:(UITableViewStyle)style
//{
//    self.tableView.delegate = self;
//
//    self = [super initWithStyle:style];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}
//
//
//- (DBRestClient *)restClient {
//    if (!restClient) {
//        restClient =
//        [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
//        restClient.delegate = self;
//    }
//    return restClient;
//}
//
//- (void)viewDidLoad
//{
//    self.tableView.delegate = self;
////    self.tableView.datasource = self;
//
//    [super viewDidLoad];
//    dropboxURLs = [[NSMutableArray alloc] init];
//    [[self restClient] loadMetadata:@"/"];
//    [self.tableView reloadData];
//}
//
//
//- (void)didReceiveMemoryWarning
//{
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}
//
//- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
//    if (metadata.isDirectory) {
//        NSLog(@"Folder '%@' contains:", metadata.path);
//        for (DBMetadata *file in metadata.contents) {
//            NSLog(@"	%@", file.filename);
//        }
//        [self.tableView reloadData];
//    }
//}
//
//- (void)restClient:(DBRestClient *)client
//loadMetadataFailedWithError:(NSError *)error {
//    NSLog(@"Error loading metadata: %@", error);
//}
//
////- (void)restClient:(DBRestClient*)client loadedMetadata:(DBMetadata*)metadata {
////    
////    for (DBMetadata *file in metadata.contents) {
////        NSLog(@"\t%@", file.filename);
////        [dropBoxArray addObject:file.filename];
////    }
////    NSLog(@"%@", dropBoxArray);
////    
////    [self.tableView reloadData];
////
////}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *CellIdentifier = @"Cell";
//    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//    }
//    
//   // cell.textLabel.text = [dropBoxArray objectAtIndex:indexPath.row];
//    NSLog(@"%@", cell.textLabel.text);
//    
//    return cell;
//}
//
//
//
//@end
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>


#import "Browse.h"

@interface Browse ()

@end




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
                [dropboxURLs addObject:file.filename];
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
            }
        }
    }
}


- (void)restClient:(DBRestClient *)client
loadMetadataFailedWithError:(NSError *)error {
    
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
    
    [self.tableView reloadData];
    return cell;
}

@end