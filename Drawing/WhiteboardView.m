//
//  WhiteboardView.m
//  Drawing
//
//  Created by Dustin Schie on 10/25/14.
//  Copyright (c) 2014 Dustin Schie. All rights reserved.
//

#import "WhiteboardView.h"
#import "SharedSettings.h"

@interface WhiteboardView ()
{
    UIBezierPath *path;
    CGPoint pts[5];
    uint ctr;
}
@property (strong, nonatomic) SharedSettings *sharedSettings;
@end

@implementation WhiteboardView
@synthesize incrementalImage;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        NSLog(@"Coder");
        [self setSharedSettings:[SharedSettings sharedSettings]];
        [self setMultipleTouchEnabled:NO];
        [self setBackgroundColor:[UIColor whiteColor]];
        path = [UIBezierPath bezierPath];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        NSLog(@"Frame");
        [self setSharedSettings:[SharedSettings sharedSettings]];
        [self setMultipleTouchEnabled:NO];
        path = [UIBezierPath bezierPath];
        [path setLineWidth:[[self sharedSettings] brush]];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [path setLineWidth:[[self sharedSettings] brush]];
    UIColor *color = [UIColor colorWithRed:self.sharedSettings.red
                                     green:self.sharedSettings.green
                                      blue:self.sharedSettings.blue
                                     alpha:self.sharedSettings.opacity];
    [color setStroke];
    [incrementalImage drawInRect:rect];
    [path stroke];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    ctr = 0;
    UITouch *touch = [touches anyObject];
    pts[0] = [touch locationInView:self];
    NSLog(@"Begin");
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    CGPoint p = [touch locationInView:self];
    ctr++;
    pts[ctr] = p;
    if (ctr == 4)
    {
        // move the endpoint to the middle of the line joining the second control point of the first Bezier segment and the first control point of the second Bezier segment
        pts[3] = CGPointMake((pts[2].x + pts[4].x)/2.0, (pts[2].y + pts[4].y)/2.0);
        [path moveToPoint:pts[0]];
        [path addCurveToPoint:pts[3] controlPoint1:pts[1] controlPoint2:pts[2]];
        [self setNeedsDisplay];
        // replace points and get ready to handle the next segment
        pts[0] = pts[3];
        pts[1] = pts[4];
        ctr = 1;
    }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    [self drawBitmap];
    [self setNeedsDisplay];
    [path removeAllPoints];
    ctr = 0;
    NSLog(@"End");
}

- (void) setIncrementalImage:(UIImage *)aIncrementalImage
{
    incrementalImage = aIncrementalImage;
    [self setNeedsDisplay];
}

- (void) drawBitmap
{
    UIGraphicsBeginImageContextWithOptions([self bounds].size, YES, 0.0);
    if (!incrementalImage)
    {
        UIBezierPath *rectPath = [UIBezierPath bezierPathWithRect:[self bounds]];
        [[UIColor whiteColor] setFill];
        [rectPath fill];
    }
    [incrementalImage drawAtPoint:CGPointZero];
    [path setLineWidth:[[self sharedSettings] brush]];
    UIColor *color = [UIColor colorWithRed:self.sharedSettings.red
                                     green:self.sharedSettings.green
                                      blue:self.sharedSettings.blue
                                     alpha:self.sharedSettings.opacity];
    [color setStroke];
    [path stroke];
    incrementalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if ([[self delegate] conformsToProtocol:@protocol(WhiteBoardDelegate)] && [[self delegate] respondsToSelector: @selector(board:createdImage:)])
    {
        [[self delegate] board:self createdImage:incrementalImage];
    }
}

@end
