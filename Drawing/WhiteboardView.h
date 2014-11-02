//
//  WhiteboardView.h
//  Drawing
//
//  Created by Dustin Schie on 10/25/14.
//  Copyright (c) 2014 Dustin Schie. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WhiteBoardDelegate;

@interface WhiteboardView : UIView
@property (strong, nonatomic) id<WhiteBoardDelegate> delegate;
@property (strong, nonatomic) UIImage *incrementalImage;
@end

@protocol WhiteBoardDelegate <NSObject>
- (void) board:(WhiteboardView *)board createdImage: (UIImage *)image;
@end