//
//  SharedSettings.m
//  
//
//  Created by Dustin Schie on 10/23/14.
//
//

#import "SharedSettings.h"

@implementation SharedSettings

@synthesize settingsTapped, red, green, blue, brush, opacity, boardImage;

+ (id) sharedSettings
{
    static id sharedSettings = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSettings = [[self alloc] init];
    });
    
    return sharedSettings;
}

@end
