//
//  MoreTableViewController.h
//  Drawing
//
//  Created by Dustin Schie on 10/26/14.
//  Copyright (c) 2014 Dustin Schie. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MoreTableViewControllerDelegate;

@interface MoreTableViewController : UITableViewController
@property (strong, nonatomic) id<MoreTableViewControllerDelegate> delegate;

- (IBAction)savePhoto:(UIButton *)sender;
- (IBAction)snapShot:(UIButton *)sender;

- (IBAction)shareImage:(id)sender;
- (IBAction)done:(id)sender;
- (IBAction)hostSession:(id)sender;
@end

@protocol MoreTableViewControllerDelegate <NSObject>
- (void) moreTableViewControllerIsDone: (MoreTableViewController *) mtvc;
- (void)moreTableViewControllerSavePhoto: (MoreTableViewController *) mtvc;
- (void)moreTableViewController:(MoreTableViewController *) mtvc hostSessionButtonPressed:(UIButton *)hsButton;
@end