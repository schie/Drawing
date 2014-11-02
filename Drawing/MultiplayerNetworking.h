//
//  MultiplayerNetworking.h
//  Tableau
//
//  Created by Dustin Schie on 11/2/14.
//  Copyright (c) 2014 Dustin Schie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameCenterManager.h"

typedef NS_ENUM(NSUInteger, GameState)
{
    kGameStateWaitingForMatch = 0,
    kGameStateWaitingForRandomNumber,
    kGameStateWaitingForStart,
    kGameStateActive,
    kGameStateDone
};
typedef NS_ENUM(NSUInteger, MessageType) {
    kMessageTypeRandomNumber = 0,
    kMessageTypeGameBegin,
    kMessageTypeMove,
    kMessageTypeGameOver
};
typedef struct
{
    MessageType messageType;
} Message;
typedef struct
{
    Message message;
    uint32_t randomNumber;
} MessageRandomNumber;

typedef struct
{
    Message message;
} MessageGameBegin;

typedef struct
{
    Message message;
} MessageMove;

typedef struct
{
    Message message;
    BOOL player1Won;
} MessageGameOver;


@protocol MultiplayerNetworkingDelegate <NSObject>
- (void)matchEnded;
- (void)setCurrentPlayerIndex: (NSUInteger)index;
@end

@interface MultiplayerNetworking : NSObject <GameCenterManagerDelegate>
@property (nonatomic, assign) id<MultiplayerNetworkingDelegate> delegate;
@end
