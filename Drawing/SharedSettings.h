//
//  SharedSettings.h
//  
//
//  Created by Dustin Schie on 10/23/14.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SharedSettings : NSObject
@property (nonatomic) BOOL settingsTapped;
@property (nonatomic) CGFloat red, green, blue, brush, opacity;
@property (nonatomic) UIImage *boardImage;


+ (id) sharedSettings;
@end
