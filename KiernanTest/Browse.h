//
//  Browse.h
//  KiernanTest
//
//  Created by Matthew Kiernan on 3/28/15.
//  Copyright (c) 2015 Matt Kiernan. All rights reserved.
//

#ifndef KiernanTest_Browse_h
#define KiernanTest_Browse_h

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>

@interface Browse : UITableViewController <UITableViewDataSource, UITableViewDelegate,DBRestClientDelegate>
{
    DBRestClient *restClient;
    NSMutableArray *dropboxURLs;
    NSString *pathcomp;
    NSString *local;
    NSString *filePath;
    UIImageView *imageView;
}
@property (nonatomic, copy, readwrite) NSMutableArray *fileList;
@end

#endif
