//
//  ViewController.h
//  KiernanTest
//
//  Created by Matthew Kiernan on 3/27/15.
//  Copyright (c) 2015 Matt Kiernan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController{
    IBOutlet UIButton *login;
    IBOutlet UIButton *upload;
    IBOutlet UIButton *TakePhoto;
//    IBOutlet UIButton *CameraRoll;
    IBOutlet UIButton *browse;
}

@property BOOL newMedia;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;

-(IBAction)didPressLink:(id)sender;
-(IBAction)upload:(id)sender;
-(IBAction)TakePhoto:(id)sender;
//-(IBAction)CameraRoll:(id)sender);
-(IBAction)browse:(id)sender;

@end

