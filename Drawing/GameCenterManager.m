//
//  GameCenterManager.m
//  Tableau
//
//  Created by Dustin Schie on 11/1/14.
//  Copyright (c) 2014 Dustin Schie. All rights reserved.
//

#import "GameCenterManager.h"
@interface GameCenterManager()
{
    BOOL enableGameCenter;
    BOOL matchStarted;
}
@end

@implementation GameCenterManager

NSString *const PresentAuthenticationViewController = @"present_authentication_view_controller";
NSString *const LocalPlayerIsAuthenticated = @"local_player_authenticated";

+ (instancetype)sharedInstance
{
    static GameCenterManager *sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[GameCenterManager alloc] init];
    });
    return sharedManager;
}

- (id) init
{
    if (self = [super init])
    {
        enableGameCenter = YES;
    }
    return self;
}


/**
 1. First you get an instance of the GKLocalPlayer class. This instance represents the player who is currently authenticated through Game Center on this device. Only one player may be authenticated at a time.
 2. Set the authenticateHandler of the GKLocalPlayer object. GameKit may call this handler multiple times.
 3. Store any error the callback may have received using the setLastError: method.
 4. If the player has not logged into Game Center either using the Game Center app or while playing another game, the Game Kit framework will pass a view controller to the authenticateHandler. It is your duty as the game’s developer to present this view controller to the user when you think it’s feasible. Ideally, you should do this as soon as possible. You will store this view controller in an instance variable using setAuthenticationViewController:. This is an empty method for now, but you’ll implement it in a moment.
 5. If the player has already logged in to Game Center, then the authenticated property of the GKLocalPlayer object is true. When this occurs, you enable all Game Center features by setting the _enableGameCenter boolean variable to YES.
 6. If the user did not sign in – perhaps they pressed the Cancel button or login was unsuccessful – you need to turn off all Game Center features. This is because, Game Center features are only available if the local player has logged in.
 */
- (void)authenticateLocalPlayer
{
    //1
    GKLocalPlayer *lp = [GKLocalPlayer localPlayer];
    if (lp.isAuthenticated)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:LocalPlayerIsAuthenticated object:nil];
        return;
    }
    //2
    [lp setAuthenticateHandler:^(UIViewController *viewController, NSError *error)
                                {
                                    //3
                                    [self setLastError:error];
                                    if (viewController != nil)
                                    {
                                        //4
                                        [self setAuthenticationViewController: viewController];
                                    }
                                    else if ([[GKLocalPlayer localPlayer] isAuthenticated])
                                    {
                                        //5
                                        enableGameCenter = YES;
                                        [[NSNotificationCenter defaultCenter] postNotificationName:LocalPlayerIsAuthenticated
                                                                                            object:nil];
                                    }
                                    else
                                    {
                                        //6
                                        enableGameCenter = NO;
                                    }
                                }
     ];
}

- (void)lookupPlayers
{
    NSLog(@"Looking up %lu players...", (unsigned long)_match.players.count);
    
    [GKPlayer loadPlayersForIdentifiers:[_match playerIDs]
                  withCompletionHandler:^(NSArray *players, NSError *error) {
                      if (error != nil)
                      {
                          NSLog(@"Error retrieving player info: %@", error.localizedDescription);
                          matchStarted = NO;
                          [_delegate matchEnded];
                      }
                      else
                      {
                          _playersDict = [NSMutableDictionary dictionaryWithCapacity:[players count]];
                          for (GKPlayer *player in players)
                          {
                              NSLog(@"Found player: %@", [player alias]);
                              [_playersDict setObject:[GKLocalPlayer localPlayer] forKey:[[GKLocalPlayer localPlayer] playerID]];
                              matchStarted = YES;
                              [_delegate matchStarted];
                          }
                      }
    }];
}

- (void)setAuthenticationViewController:(UIViewController *)authenticationViewController
{
    if (authenticationViewController)
    {
        _authenticationViewController = authenticationViewController;
        [[NSNotificationCenter defaultCenter] postNotificationName:PresentAuthenticationViewController
                                                            object:self];
        
    }
}

- (void)setLastError:(NSError *)error
{
    _lastError = [error copy];
    if (_lastError)
    {
        NSLog(@"GameCenterManager ERROR: %@", [[_lastError userInfo] description]);
    }
}

- (void)findMatchWithMinPlayers:(int)minPlayers maxPlayers:(int)maxPlayers viewController:(UIViewController *)viewController delegate:(id<GameCenterManagerDelegate>)delegate
{
    if (!enableGameCenter)
    {
        return;
    }
    
    matchStarted = NO;
    [self setMatch:nil];
    _delegate = delegate;
    [viewController dismissViewControllerAnimated:NO
                                       completion:nil];
    
    GKMatchRequest *request = [GKMatchRequest new];
    [request setMinPlayers:minPlayers];
    [request setMaxPlayers:maxPlayers];
    
    GKMatchmakerViewController *mmvc = [[GKMatchmakerViewController alloc] initWithMatchRequest:request];
    [mmvc setMatchmakerDelegate:self];
    [viewController presentViewController:mmvc
                                 animated:YES
                               completion:nil];
    
}

- (void)matchmakerViewControllerWasCancelled:(GKMatchmakerViewController *)viewController
{
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFailWithError:(NSError *)error
{
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFindMatch:(GKMatch *)match
{
    [viewController dismissViewControllerAnimated:YES completion:nil];
    [self setMatch:match];
    [match setDelegate:self];
    if (!matchStarted && [match expectedPlayerCount] == 0)
    {
        NSLog(@"Ready to start match!");
        [self lookupPlayers];
    }
}

#pragma mark GKMatchDelegate
- (void)match:(GKMatch *)match didReceiveData:(NSData *)data fromRemotePlayer:(GKPlayer *)player
{
    if (_match != match)
    {
        return;
    }
    
    [_delegate match:match didReceiveData:data fromPlayer:player];
}

- (void)match:(GKMatch *)match player:(GKPlayer *)player didChangeConnectionState:(GKPlayerConnectionState)state
{
    if (_match != match)
    {
        return;
    }
    
    switch (state) {
        case GKPlayerStateConnected:
            NSLog(@"Player Connected");
            if (!matchStarted && [match expectedPlayerCount] == 0)
            {
                NSLog(@"Ready to Start Match!");
                [self lookupPlayers];
            }
            break;
        case GKPlayerStateDisconnected:
            NSLog(@"Player Disconnected!");
            matchStarted = NO;
            [_delegate matchEnded];
            break;
        default:
            break;
    }
}

// The match was unable to connect with the player due to an error.
- (void)match:(GKMatch *)match connectionWithPlayerFailed:(NSString *)playerID withError:(NSError *)error {
    
    if (_match != match) return;
    
    NSLog(@"Failed to connect to player with error: %@", error.localizedDescription);
    matchStarted = NO;
    [_delegate matchEnded];
}

// The match was unable to be established with any players due to an error.
- (void)match:(GKMatch *)match didFailWithError:(NSError *)error {
    
    if (_match != match) return;
    
    NSLog(@"Match failed with error: %@", error.localizedDescription);
    matchStarted = NO;
    [_delegate matchEnded];
}

@end
