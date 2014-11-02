//
//  WhiteboardViewController.h
//  Drawing
//
//  Created by Dustin Schie on 10/22/14.
//  Copyright (c) 2014 Dustin Schie. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SettingsTableViewController.h"
#import "VBFPopFlatButton.h"
#import "WhiteboardView.h"
#import "MoreTableViewController.h"

@interface WhiteboardViewController : UIViewController
<UIActionSheetDelegate, SettingsTableViewControllerDelegate, MoreTableViewControllerDelegate, WhiteBoardDelegate>
{
    CGPoint lastPoint;
    BOOL mouseSwiped;
}
- (void)settings:(id)sender;

//@property (weak, nonatomic) IBOutlet VBFPopFlatButton *settingsButton;
@property (weak, nonatomic) IBOutlet WhiteboardView *whiteBoardView;
@property (weak, nonatomic) IBOutlet UIView *settingsVCView;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *visualEffectsView;
@end
