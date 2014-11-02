//
//  SettingsTableViewController.h
//  Drawing
//
//  Created by Dustin Schie on 10/23/14.
//  Copyright (c) 2014 Dustin Schie. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ASOTwoStateButton.h"
#import "ASOBounceButtonViewDelegate.h"

#import "SharedSettings.h"
#import "BounceButtonView.h"

@protocol SettingsTableViewControllerDelegate;

@interface SettingsTableViewController : UITableViewController <ASOBounceButtonViewDelegate>
@property (weak, nonatomic) IBOutlet UISlider *brushControl;
@property (weak, nonatomic) IBOutlet UISlider *opacityControl;
@property (weak, nonatomic) IBOutlet UISlider *redControl;
@property (weak, nonatomic) IBOutlet UISlider *greenControl;
@property (weak, nonatomic) IBOutlet UISlider *blueControl;

@property (weak, nonatomic) IBOutlet UILabel* brushLabel;
@property (weak, nonatomic) IBOutlet UILabel* opacityLabel;
@property (weak, nonatomic) IBOutlet UILabel* redLabel;
@property (weak, nonatomic) IBOutlet UILabel* greenLabel;
@property (weak, nonatomic) IBOutlet UILabel* blueLabel;
@property (weak, nonatomic) IBOutlet UIView *strokePreview;
@property (weak, nonatomic) IBOutlet UIView *spacerView;


@property (strong, nonatomic) IBOutlet ASOTwoStateButton *menuButton;

@property (strong, nonatomic) BounceButtonView *menuItemView;


- (IBAction)menuButtonAction:(id)sender;
- (IBAction)sliderChanged:(UISlider *)sender;
- (IBAction)done:(id)sender;
- (IBAction)resetButtonPressed:(id)sender;
- (IBAction)eraserButtonPressed:(id)sender;

@property (strong, nonatomic) id<SettingsTableViewControllerDelegate> delegate;

@end

@protocol SettingsTableViewControllerDelegate <NSObject>
@required
- (void) settingsTableViewControllerIsDone: (SettingsTableViewController *)stvc;
- (void) settingsTableViewController:(SettingsTableViewController *)stvc
                  resetButtonPressed: (UIButton *)resetButton;
@end
