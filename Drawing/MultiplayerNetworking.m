//
//  MultiplayerNetworking.m
//  Tableau
//
//  Created by Dustin Schie on 11/2/14.
//  Copyright (c) 2014 Dustin Schie. All rights reserved.
//

#import "MultiplayerNetworking.h"

#define playerIdKey @"PlayerId"
#define randomNumberKey @"randomNumber"

@implementation MultiplayerNetworking
{
    uint32_t _ourRandomNumber;
    GameState _gameState;
    BOOL _isPlayer1, _receivedAllRandomNumbers;
    
    NSMutableArray *_orderOfPlayers;
}

- (id)  init
{
    if (self = [super init])
    {
        _ourRandomNumber = arc4random();
        _gameState = kGameStateWaitingForMatch;
        _orderOfPlayers = [NSMutableArray array];
        [_orderOfPlayers addObject:@{playerIdKey :[[GKLocalPlayer localPlayer] playerID],
                                     randomNumberKey : @(_ourRandomNumber)}];
    }
    
    return self;
}

//--------------------------------------------------
- (void)sendData: (NSData *)data
{
    NSError *error;
    GameCenterManager *gcm = [GameCenterManager sharedInstance];
    BOOL success = [[gcm match] sendDataToAllPlayers:data
                                        withDataMode:GKMatchSendDataReliable
                                               error:&error];
    if (!success)
    {
        NSLog(@"Error sending data: %@", [error localizedDescription]);
    }
}
//--------------------------------------------------
- (void) sendRandomNumber
{
    MessageRandomNumber message;
    message.message.messageType = kMessageTypeRandomNumber;
    message.randomNumber = _ourRandomNumber;
    NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageRandomNumber)];
    [self sendData:data];
}
//--------------------------------------------------
- (void) sendGameBegin
{
    MessageGameBegin message;
    message.message.messageType = kMessageTypeGameBegin;
    NSData *data = [NSData dataWithBytes:&message length:sizeof(MessageGameBegin)];
    [self sendData:data];
}
//--------------------------------------------------
- (void) tryStartGame
{
    if (_isPlayer1 && _gameState == kGameStateWaitingForStart)
    {
        _gameState = kGameStateActive;
        [self sendGameBegin];
        
        //first Player
        [[self delegate] setCurrentPlayerIndex:0];
    }
}
//--------------------------------------------------
- (void)processReceivedRandomNumber: (NSDictionary *)randomNumberDetails
{
    //1
    if([_orderOfPlayers containsObject:randomNumberDetails])
    {
        [_orderOfPlayers removeObjectAtIndex:
         [_orderOfPlayers indexOfObject:randomNumberDetails]];
    }
    //2
    [_orderOfPlayers addObject:randomNumberDetails];
    
    //3
    NSSortDescriptor *sortByRandomNumber =
    [NSSortDescriptor sortDescriptorWithKey:randomNumberKey
                                  ascending:NO];
    NSArray *sortDescriptors = @[sortByRandomNumber];
    [_orderOfPlayers sortUsingDescriptors:sortDescriptors];
    
    //4
    if ([self allRandomNumbersAreReceived])
    {
        _receivedAllRandomNumbers = YES;
    }
}
//--------------------------------------------------
- (BOOL)allRandomNumbersAreReceived
{
    NSMutableArray *receivedRandomNumbers = [NSMutableArray array];
    
    for (NSDictionary *dict in _orderOfPlayers)
    {
        [receivedRandomNumbers addObject:dict[randomNumberKey]];
    }
    
    NSArray *arrayOfUniqueRandomNumbers = [[NSSet setWithArray:receivedRandomNumbers] allObjects];
    
    if (arrayOfUniqueRandomNumbers.count == [GameCenterManager sharedInstance].match.players.count + 1)
    {
        return YES;
    }
    return NO;
}

//--------------------------------------------------
- (BOOL)isLocalPlayerPlayer1
{
    NSDictionary *dictionary = [_orderOfPlayers firstObject];
    if ([[dictionary objectForKey:playerIdKey] isEqualToString:[[GKLocalPlayer localPlayer] playerID]])
    {
        NSLog(@"I'm player 1");
        return YES;
    }
    return NO;
}

//--------------------------------------------------
- (NSUInteger)indexForLocalPlayer
{
    NSString *playerId = [[GKLocalPlayer localPlayer] playerID];
    return [self indexForPlayerWithId:playerId];
}

//--------------------------------------------------
- (NSUInteger) indexForPlayerWithId: (NSString *)playerId
{
    __block NSUInteger index = -1;
    [_orderOfPlayers enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop)
    {
        NSString *pID = [obj objectForKey:playerIdKey];
        if ([pID isEqualToString:playerId])
        {
            index = idx;
            *stop = YES;
        }
    }];
    return index;
}
#pragma mark GameCenterManager delegate
- (void) matchStarted
{
    NSLog(@"Match has started successfully");
    if (_receivedAllRandomNumbers)
    {
        _gameState = kGameStateWaitingForStart;
    }
    else
    {
        _gameState = kGameStateWaitingForRandomNumber;
    }
    [self sendRandomNumber];
    [self tryStartGame];
}

- (void)matchEnded
{
    NSLog(@"Match has ended");
    [_delegate matchEnded];
}

/**
 1. The received data is first cast into a MessageStruct.
 2. The received number is compared with the locally generated number. In case there is a tie you regenerate the random number and send again.
 3. If the random number received is not the same as the locally generated one, the method creates a dictionary that stores the player id and the random number it generated.
 4. When all random numbers are received and the order of players has been determined the _receivedAllRandomNumbers variable will be true. In this case you check if the local player is player 1.
 5. Finally if it wasn’t a tie and the local player is player 1 you initiate the game. Else you move the game state to “waiting for start”.
 */
- (void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(GKPlayer *)player
{
    //1
    Message *message = (Message *)[data bytes];
    if (message ->messageType == kMessageTypeRandomNumber)
    {
        MessageRandomNumber *messageRandomNumber = (MessageRandomNumber *)[data bytes];
        NSLog(@"received random number: %d", messageRandomNumber->randomNumber);
        BOOL tie = NO;
        if (messageRandomNumber->randomNumber == _ourRandomNumber)
        {
            //2
            NSLog(@"tie");
            tie = YES;
            _ourRandomNumber = arc4random();
            [self sendRandomNumber];
        }
        else
        {
            //3
            NSDictionary *dictionary = @{playerIdKey : [player playerID],
                                         randomNumberKey: @(messageRandomNumber -> randomNumber)};
            [self processReceivedRandomNumber:dictionary];
        }
        //4
        if (_receivedAllRandomNumbers)
        {
            _isPlayer1 = [self isLocalPlayerPlayer1];
        }
        if (!tie && _receivedAllRandomNumbers)
        {
            //5
            if (_gameState == kGameStateWaitingForRandomNumber)
            {
                _gameState = kGameStateWaitingForStart;
            }
            [self tryStartGame];
        }
    }
    else if (message -> messageType == kMessageTypeGameBegin)
    {
        NSLog(@"Begin Game Message Received");
        _gameState = kGameStateActive;
        [[self delegate] setCurrentPlayerIndex:[self indexForLocalPlayer]];
    }
    else if(message -> messageType == kMessageTypeMove)
    {
        NSLog(@"Move Message Received");
        MessageMove *messageMove = (MessageMove*)[data bytes];
    }
    else if (message -> messageType == kMessageTypeGameOver)
    {
        NSLog(@"Game over message received");
    }
}
@end
