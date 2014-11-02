//
//  WhiteboardViewController.m
//  Drawing
//
//  Created by Dustin Schie on 10/22/14.
//  Copyright (c) 2014 Dustin Schie. All rights reserved.
//

#import "WhiteboardViewController.h"
#import "SharedSettings.h"
#import "GameCenterManager.h"
#import "MultiplayerNetworking.h"

@interface WhiteboardViewController () <GameCenterManagerDelegate, MultiplayerNetworkingDelegate>
@property (strong, nonatomic) SharedSettings *sharedSettings;
@property (strong, nonatomic) VBFPopFlatButton *settingsButton;
@end

@implementation WhiteboardViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setSharedSettings:[SharedSettings sharedSettings]];
    [[self sharedSettings] setSettingsTapped:NO];
    
    self.sharedSettings.red = 0.0/255.0;
    self.sharedSettings.green = 0.0/255.0;
    self.sharedSettings.blue = 0.0/255.0;
    self.sharedSettings.brush = 10.0;
    self.sharedSettings.opacity = 1.0;
    
    CGRect frame = self.visualEffectsView.frame;
    frame.origin.x = frame.size.width * 1.5;
    frame.origin.y = 30;
    frame.size.height = frame.size.width = 30;
    
    [self setSettingsButton:[[VBFPopFlatButton alloc] initWithFrame: frame
                                                         buttonType: buttonBackType
                                                        buttonStyle: buttonRoundedStyle
                                              animateToInitialState: YES]];
    self.settingsButton.roundBackgroundColor = [UIColor redColor];
    self.settingsButton.lineThickness = 2;
    self.settingsButton.tintColor = [UIColor whiteColor];
    [self.settingsButton addTarget:self
                            action:@selector(settings:)
                  forControlEvents:UIControlEventTouchUpInside];
    [[[self settingsButton] layer] setZPosition:10];
    [[self whiteBoardView] addSubview:self.settingsButton];
    
    [[[self whiteBoardView] layer] setZPosition:1];
    [[self whiteBoardView] setDelegate:self];
    [[[self visualEffectsView] layer] setZPosition:2];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingsTapped) name:@"settingsTapped" object:nil];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self settingsTappedAndShouldAnimate:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerAuthenticated)
                                                 name:LocalPlayerIsAuthenticated object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showAuthenticationViewController)
                                                 name:PresentAuthenticationViewController
                                               object:nil];
    [[GameCenterManager sharedInstance] authenticateLocalPlayer];
    
}

- (void)playerAuthenticated
{
    [[GameCenterManager sharedInstance] findMatchWithMinPlayers:2
                                                      maxPlayers:2
                                                  viewController:self
                                                        delegate:self];
    
}

- (void) showAuthenticationViewController
{
    GameCenterManager *gcm = [GameCenterManager sharedInstance];
    
    [self presentViewController:[gcm authenticationViewController]
                       animated:YES
                     completion:nil];
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) setSettingsViewWithNewXPosition: (CGFloat)xPos
{
    self.visualEffectsView.frame = CGRectMake(xPos,
                                           self.visualEffectsView.frame.origin.y,
                                           self.visualEffectsView.frame.size.width,
                                           self.visualEffectsView.frame.size.height);
}
- (void) settingsTappedAndShouldAnimate:(BOOL)shouldAnimate
{
    [[self settingsButton] animateToType: ([[self sharedSettings] settingsTapped] ? buttonBackType:buttonMenuType)];
    CGFloat x = self.visualEffectsView.frame.size.width * -1.0;
    CGFloat tempVal = (self.sharedSettings.settingsTapped ? 0 : x);
    CGPoint buttonCenter = self.settingsButton.center;
             buttonCenter.x = (tempVal + 30.0f + x * -1.0);
    if (shouldAnimate)
    {
        [UIView animateWithDuration:0.7f
                         animations:^{
                             [self setSettingsViewWithNewXPosition: tempVal];
        }];
        [UIView animateWithDuration:0.4f
                              delay:0.3f
                             options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             [[self settingsButton] setCenter:buttonCenter];
        }
                         completion:nil];
        self.sharedSettings.settingsTapped = !self.sharedSettings.settingsTapped;
    }
    else
    {
         [self setSettingsViewWithNewXPosition:tempVal];
        [[self settingsButton] setCenter:buttonCenter];
    }
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void) configureView
{
    [[self view] setNeedsDisplay];
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[UITabBarController class]])
    {
        for (id obj in [(UITabBarController *)[segue destinationViewController] viewControllers])
        {
            if ([[[obj  viewControllers] objectAtIndex:0] isKindOfClass:[SettingsTableViewController class]])
            {
                SettingsTableViewController *vc = (SettingsTableViewController *) [[obj  viewControllers] objectAtIndex:0];
                [vc setDelegate:self];
            }
            else if([[[obj  viewControllers] objectAtIndex:0] isKindOfClass: [MoreTableViewController class]])
            {
                MoreTableViewController *vc = (MoreTableViewController *) [[obj  viewControllers] objectAtIndex:0];
                [vc setDelegate:self];
            }
        }
    }
    
}

- (void)settings:(id)sender
{
    [self settingsTappedAndShouldAnimate:YES];
}

#pragma mark - SettingsTableViewControllerDelegate
- (void) settingsTableViewControllerIsDone: (SettingsTableViewController *)stvc
{
    [self settingsTappedAndShouldAnimate:YES];
}

- (void)settingsTableViewController:(SettingsTableViewController *)stvc
                 resetButtonPressed:(UIButton *)resetButton
{
    [[self whiteBoardView] setIncrementalImage:nil];
}

#pragma mark - More table View Controller Delegate
- (void)moreTableViewControllerIsDone:(MoreTableViewController *)mtvc
{
    [self settingsTappedAndShouldAnimate:YES];
}
- (void)moreTableViewControllerSavePhoto:(MoreTableViewController *)mtvc
{
    UIImageWriteToSavedPhotosAlbum(self.sharedSettings.boardImage, nil, nil, nil);
}
- (void)moreTableViewController:(MoreTableViewController *)mtvc hostSessionButtonPressed:(UIButton *)hsButton
{
    
}
#pragma mark - white board view delegate
- (void)board:(WhiteboardView *)board createdImage:(UIImage *)image
{
    [[self sharedSettings] setBoardImage:image];
}

#pragma mark - GameCenterManagerDelegate
- (void)matchStarted
{
    NSLog(@"Match Started");
}

- (void)matchEnded
{
    NSLog(@"Match Ended");
}

- (void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(GKPlayer *)player
{
    NSLog(@"Received Data");
}

#pragma mark - MultiplayerMetworking Delegate
- (void)setCurrentPlayerIndex:(NSUInteger)index
{
    
}
@end
