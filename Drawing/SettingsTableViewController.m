//
//  SettingsTableViewController.m
//  Drawing
//
//  Created by Dustin Schie on 10/23/14.
//  Copyright (c) 2014 Dustin Schie. All rights reserved.
//

#import "SettingsTableViewController.h"
struct StrokeTempContainer
{
    CGFloat red, blue, green, brush, opacity;
    
};

@interface SettingsTableViewController ()
{
    CGFloat cellHeight;
    CGPoint previewCenter;
    struct StrokeTempContainer strokeContainer;
}

@property (strong, nonatomic) SharedSettings *sharedSettings;
@property (strong, nonatomic) NSIndexPath *enlargingCellIndexPath;
@property (strong, nonatomic) NSIndexPath *pencilSelectPath;
@property (strong, nonatomic) NSIndexPath *eraserSelectPath;

@end

@implementation SettingsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setSharedSettings:[SharedSettings sharedSettings]];
    [[self sharedSettings] setSettingsTapped:NO];
    [self setPencilSelectPath:[NSIndexPath indexPathForRow:3 inSection:3]];
    [self setEraserSelectPath:[NSIndexPath indexPathForRow:4 inSection:3]];
    [self.menuButton initAnimationWithFadeEffectEnabled:YES];
    
    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController* menuItemsVC = (UIViewController *)[mainStoryBoard instantiateViewControllerWithIdentifier:@"ExpandMenu"];
    [self setMenuItemView:(BounceButtonView *)[menuItemsVC view]];
    NSArray *arrMenuItemButtons = [[NSArray alloc] initWithObjects: self.menuItemView.menuItem0,
                                   self.menuItemView.menuItem1,
                                   self.menuItemView.menuItem2,
                                   self.menuItemView.menuItem3,
                                   self.menuItemView.menuItem4,
                                   self.menuItemView.menuItem5,
                                   self.menuItemView.menuItem6,
                                   self.menuItemView.menuItem7,
                                   self.menuItemView.menuItem8,
                                   self.menuItemView.menuItem9,
                                   nil];
    [[self menuItemView] addBounceButtons:arrMenuItemButtons];
    [[self menuItemView] setBouncingDistance:[NSNumber numberWithFloat:0.0f]];
    [[self menuItemView] setSpeed:[NSNumber numberWithFloat:0.1f]];
    [[self menuItemView] setDelegate:self];
    
    [[[self strokePreview] layer] setMasksToBounds:YES];
    
    CGRect frame = [[self spacerView] frame];
    frame.size.height = 50;
    [[self spacerView] setFrame:frame];
    
}
//--------------------------------------------------------------------
- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateColors) name:@"settingsTapped" object:nil];
    [self updateColors];
    cellHeight =  45.0f;
}
//--------------------------------------------------------------------
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//--------------------------------------------------------------------
- (IBAction)sliderChanged:(UISlider *)sender
{
    if(sender == self.brushControl)
    {
        self.sharedSettings.brush = self.brushControl.value;
        self.brushLabel.text = [NSString stringWithFormat:@"%.1f", self.sharedSettings.brush];
        
    }
    else if(sender == self.opacityControl)
    {
        self.sharedSettings.opacity = self.opacityControl.value;
        self.opacityLabel.text = [NSString stringWithFormat:@"%.1f", self.sharedSettings.opacity];
        
    }
    else if(sender == self.redControl)
    {
        self.sharedSettings.red = self.redControl.value/255.0;
        self.redLabel.text = [NSString stringWithFormat:@"R: %d", (int)self.redControl.value];
        
    }
    else if(sender == self.greenControl)
    {
        self.sharedSettings.green = self.greenControl.value/255.0;
        self.greenLabel.text = [NSString stringWithFormat:@"G: %d", (int)self.greenControl.value];
    }
    else if (sender == self.blueControl)
    {
        self.sharedSettings.blue = self.blueControl.value/255.0;
        self.blueLabel.text = [NSString stringWithFormat:@"B: %d", (int)self.blueControl.value];
    }
    
    [self updatePreview];
}
//--------------------------------------------------------------------
- (IBAction)done:(id)sender
{
    [[self delegate] settingsTableViewControllerIsDone:self];
}
//--------------------------------------------------------------------
- (IBAction)resetButtonPressed:(id)sender
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Deleting Image"
                                                                             message:@"Are you sure?"
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionYes = [UIAlertAction actionWithTitle:@"Yes"
                                                        style:UIAlertActionStyleDestructive
                                                      handler:^(UIAlertAction *action){
            [[self delegate] settingsTableViewController:self
                                      resetButtonPressed:sender];
    }];
    UIAlertAction *actionNo = [UIAlertAction actionWithTitle:@"No"
                                                       style:UIAlertActionStyleCancel
                                                     handler:nil];
    [alertController addAction:actionYes];
    [alertController addAction:actionNo];
    [self presentViewController:alertController
                       animated:YES
                     completion:nil];
}
//--------------------------------------------------------------------
- (IBAction)eraserButtonPressed:(id)sender
{
    static BOOL shouldErase = YES;
    UIButton *button = (UIButton *)sender;
    if (shouldErase)
    {

        [button setTitle:@"click to dismiss eraser"
                forState:UIControlStateNormal];
        strokeContainer.red = self.sharedSettings.red;
        strokeContainer.blue = self.sharedSettings.blue;
        strokeContainer.green = self.sharedSettings.green;
        strokeContainer.brush = self.sharedSettings.brush;
        strokeContainer.opacity = self.sharedSettings.opacity;
        [[self sharedSettings] setOpacity:1.0f];
        
        [self setColor:-1];
    }
    else
    {
        [button setTitle:@""
                forState:UIControlStateNormal];
        self.sharedSettings.red = strokeContainer.red;
        self.sharedSettings.blue = strokeContainer.blue;
        self.sharedSettings.green = strokeContainer.green;
        self.sharedSettings.brush = strokeContainer.brush;
        self.sharedSettings.opacity = strokeContainer.opacity;
    }
    [self updateColors];
    shouldErase = !shouldErase;

}
//--------------------------------------------------------------------
- (void) updatePreview
{
    //  set stroke preview view
    CGRect frame = self.strokePreview.bounds;
    UIColor *color = [UIColor colorWithRed:self.sharedSettings.red
                                     green:self.sharedSettings.green
                                      blue:self.sharedSettings.blue
                                     alpha:self.sharedSettings.opacity];
    frame.size.height = frame.size.width = self.sharedSettings.brush;
    [self.strokePreview setFrame:frame];
    [self.strokePreview setCenter:previewCenter];
    [self.strokePreview setBackgroundColor:color];
    [[[self strokePreview] layer] setCornerRadius: self.sharedSettings.brush / 2.0];
    [[self strokePreview] setNeedsDisplay];
}
//--------------------------------------------------------------------
- (void) updateColors
{
     int redIntValue = self.sharedSettings.red * 255.0;
     self.redControl.value = redIntValue;
     [self sliderChanged:self.redControl];
     
     int greenIntValue = self.sharedSettings.green * 255.0;
     self.greenControl.value = greenIntValue;
     [self sliderChanged:self.greenControl];
     
     int blueIntValue = self.sharedSettings.blue * 255.0;
     self.blueControl.value = blueIntValue;
     [self sliderChanged:self.blueControl];
     
     self.brushControl.value = self.sharedSettings.brush;
     [self sliderChanged:self.brushControl];
     
     self.opacityControl.value = self.sharedSettings.opacity;
     [self sliderChanged:self.opacityControl];
    
    [self updatePreview];
}
//--------------------------------------------------------------------
//--------------------------------------------------------------------
- (void) setColor: (NSInteger) colorID
{
    switch(colorID)
    {
        case 0:
            self.sharedSettings.red = 0.0/255.0;
            self.sharedSettings.green = 0.0/255.0;
            self.sharedSettings.blue = 0.0/255.0;
            break;
        case 1:
            self.sharedSettings.red = 105.0/255.0;
            self.sharedSettings.green = 105.0/255.0;
            self.sharedSettings.blue = 105.0/255.0;
            break;
        case 2:
            self.sharedSettings.red = 255.0/255.0;
            self.sharedSettings.green = 0.0/255.0;
            self.sharedSettings.blue = 0.0/255.0;
            break;
        case 3:
            self.sharedSettings.red = 0.0/255.0;
            self.sharedSettings.green = 0.0/255.0;
            self.sharedSettings.blue = 255.0/255.0;
            break;
        case 4:
            self.sharedSettings.red = 102.0/255.0;
            self.sharedSettings.green = 204.0/255.0;
            self.sharedSettings.blue = 0.0/255.0;
            break;
        case 5:
            self.sharedSettings.red = 102.0/255.0;
            self.sharedSettings.green = 255.0/255.0;
            self.sharedSettings.blue = 0.0/255.0;
            break;
        case 6:
            self.sharedSettings.red = 51.0/255.0;
            self.sharedSettings.green = 204.0/255.0;
            self.sharedSettings.blue = 255.0/255.0;
            break;
        case 7:
            self.sharedSettings.red = 160.0/255.0;
            self.sharedSettings.green = 82.0/255.0;
            self.sharedSettings.blue = 45.0/255.0;
            break;
        case 8:
            self.sharedSettings.red = 255.0/255.0;
            self.sharedSettings.green = 102.0/255.0;
            self.sharedSettings.blue = 0.0/255.0;
            break;
        case 9:
            self.sharedSettings.red = 255.0/255.0;
            self.sharedSettings.green = 255.0/255.0;
            self.sharedSettings.blue = 0.0/255.0;
            break;
        default:
            self.sharedSettings.red = 255.0/255.0;
            self.sharedSettings.green = 255.0/255.0;
            self.sharedSettings.blue = 255.0/255.0;
            break;
    }
    
}
//--------------------------------------------------------------------
#pragma mark - UITableViewDataSource
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView heightForRowAtIndexPath:indexPath];
    
    if ([indexPath isEqual:_enlargingCellIndexPath])
    {
        return 200.0f;
    }
    else if (indexPath.section == 2)
    {
        return 100.0f;
    }
    return 45.0f;
}
//--------------------------------------------------------------------
#pragma mark - UITableViewDataSource
//- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
//{
////    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
////    
////    [[header textLabel] setTextColor:[UIColor darkTextColor]];
//    
//}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath isEqual:[self pencilSelectPath]] || [indexPath isEqual:[self eraserSelectPath]])
    {
        [cell setBackgroundColor:[UIColor clearColor]];
        [[cell contentView] setBackgroundColor:[UIColor clearColor]];
    }
    else
    {
        if (indexPath.section == 2)
        {
            previewCenter = cell.contentView.center;
            [self updatePreview];
        }
        [cell setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.7f]];
        [[cell contentView] setBackgroundColor:[UIColor clearColor]];
    }
}

//--------------------------------------------------------------------
#pragma mark - ASOBounceButtonViewDelegate
- (void)didSelectBounceButtonAtIndex:(NSUInteger)index
{
    // Collapse all 'menu item button' and remove 'menu item view' once a menu item is selected
//    [self.menuButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    [self setColor:index];
    [self updateColors];
}
//--------------------------------------------------------------------
- (IBAction)menuButtonAction:(id)sender
{
    if ([sender isOn]) {
        
        // Show 'menu item view' and expand its 'menu item button'
        _enlargingCellIndexPath = [NSIndexPath indexPathForRow:3
                                                    inSection:3];
        [[self tableView] beginUpdates];
        [[self tableView] endUpdates];
        [[self menuItemView] setAnimationStartFromHere:CGRectZero];
        [self.menuButton addCustomView:self.menuItemView];
//        [self.menuItemView  setSpeed:[NSNumber numberWithFloat:1.0f]];
        [self.menuItemView expandWithAnimationStyle:ASOAnimationStyleExpand];
    }
    else
    {
        _enlargingCellIndexPath = nil;
        [[self tableView] beginUpdates];
        [[self tableView] endUpdates];
        // Collapse all 'menu item button' and remove 'menu item view'
        [[self menuItemView] setAnimationStartFromHere:CGRectZero];
        [self.menuItemView collapseWithAnimationStyle:ASOAnimationStyleRiseConcurrently];
        [self.menuButton removeCustomView:self.menuItemView
                                 interval:[self.menuItemView.collapsedViewDuration doubleValue]];
    }

}
//--------------------------------------------------------------------
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration
{
    // Update 'menu button' position to 'menu item view' everytime there is a change in device orientation
    [self.menuItemView setAnimationStartFromHere:self.menuButton.frame];
}




@end
