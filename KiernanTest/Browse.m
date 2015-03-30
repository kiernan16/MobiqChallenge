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


NSMutableArray *pathArray;
int i;

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
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 250, 250)];
    i=0;
    pathArray = [[NSMutableArray alloc] init];//WithCapacity:0];

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
                
            }
        }
    }
}


- (void)restClient:(DBRestClient *)client loadedFile:(NSString *)localPath
       contentType:(NSString *)contentType metadata:(DBMetadata *)metadata {
    NSLog(@"File loaded into path: %@", localPath);
    local = localPath;
   // [pathArray addObject:local];
    [pathArray insertObject:local atIndex:i];
    i++;
//    NSLog(@"BIRDY: %@",pathArray);
    
[self performSelector:@selector(secondMethod) withObject:nil afterDelay:9.0 ];
    //[self.tableView reloadData];
}

-(void) secondMethod{
    [self.tableView reloadData];
}

-(void) DBdownload
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents directory
    filePath = [documentsDirectory stringByAppendingPathComponent:@"/"];
    
    NSString *thisthing = [NSString stringWithFormat:@"/%@", pathcomp];
    
    if (filePath) { // check if file exists - if so load it:
        
        [self.restClient loadFile:thisthing intoPath:filePath];
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

#pragma mark - TableView Data 

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
    static NSString *CellIdentifier = @"DropboxBrowserCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
        /// Show TITLE, NOTES, PREVIEW in table view
    
    /// paths are messed up *** FIX!!! ***
    
   cell.textLabel.text = [dropboxURLs objectAtIndex:indexPath.row];
    
    cell.detailTextLabel.text = [[NSNumber numberWithLong:indexPath.row] stringValue];
   // cell.imageView.image = [UIImage imageNamed: [pathArray objectAtIndex:indexPath.row]]; //local
   // cell.imageView.image = [pathArray objectAtIndex:indexPath.row];
    

        cell.imageView.image = [UIImage imageNamed: pathArray[indexPath.row]];
    
    
 //   cell.imageView.image = [UIImage imageNamed: local];
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    UITableViewCell *cell = tableView.visibleCells[indexPath.row];
    
    imageView.hidden = NO;
    imageView.image = [UIImage imageNamed: pathArray[indexPath.row]];
    imageView.userInteractionEnabled=YES;
    imageView.center = self.view.center;
    [self.view addSubview:imageView];
    
  //  cell.imageView.image = [UIImage imageNamed:local];
 //   cell.imageView.image = [UIImage imageNamed: pathArray[indexPath.row]];
    
    //clear pic
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(imageTouched:)];
    lpgr.minimumPressDuration = 0.05;
    [imageView addGestureRecognizer:lpgr];
    
    
}

- (void)imageTouched:(UILongPressGestureRecognizer *)gestureRecognizer {
    
    imageView.hidden=YES;
    
}

@end