//
//  GameCenterManager.h
//  Tableau
//
//  Created by Dustin Schie on 11/1/14.
//  Copyright (c) 2014 Dustin Schie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

extern NSString *const PresentAuthenticationViewController;
extern NSString *const LocalPlayerIsAuthenticated;

@protocol GameCenterManagerDelegate <NSObject>
- (void)matchStarted;
- (void)matchEnded;
- (void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(GKPlayer *)player;

@end

@interface GameCenterManager : NSObject <GKMatchmakerViewControllerDelegate, GKMatchDelegate>
@property (nonatomic, strong) NSMutableDictionary *playersDict;

@property (nonatomic, readonly) UIViewController *authenticationViewController;
@property (assign, nonatomic) id <GameCenterManagerDelegate> delegate;
@property (nonatomic, readonly) NSError *lastError;
@property (nonatomic, strong) GKMatch *match;

+ (instancetype)sharedInstance;

- (void) authenticateLocalPlayer;

- (void)findMatchWithMinPlayers:(int)minPlayers
                     maxPlayers:(int)maxPlayers
                 viewController:(UIViewController *)viewController
                       delegate:(id<GameCenterManagerDelegate>) delegate;

@end