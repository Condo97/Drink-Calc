//
//  RoundedView.m
//  Calc
//
//  Created by Alex Coundouriotis on 6/30/17.
//  Copyright © 2017 ACApplications. All rights reserved.
//

#import "RoundedView.h"

@implementation RoundedView

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    [self setBackgroundColor:[UIColor clearColor]];
    
    CGContextRef ref = UIGraphicsGetCurrentContext();
    
    /* We can only draw inside our view, so we need to inset the actual 'rounded content' */
    CGRect contentRect = CGRectInset(rect, 14.0, 14.0);
    
    /* Create the rounded path and fill it */
    UIBezierPath *roundedPath = [UIBezierPath bezierPathWithRoundedRect:contentRect cornerRadius:7.0];
    CGContextSetFillColorWithColor(ref, [UIColor whiteColor].CGColor);
    CGContextSetShadowWithColor(ref, CGSizeMake(0.0, 0.0), 14.0, [UIColor blackColor].CGColor);
    [roundedPath fill];
    
    /* Draw a subtle white line at the top of the view */
    [roundedPath addClip];
    CGContextSetStrokeColorWithColor(ref, [UIColor colorWithWhite:1.0 alpha:0.6].CGColor);
    CGContextSetBlendMode(ref, kCGBlendModeOverlay);
    
    CGContextMoveToPoint(ref, CGRectGetMinX(contentRect), CGRectGetMinY(contentRect)+0.5);
    CGContextAddLineToPoint(ref, CGRectGetMaxX(contentRect), CGRectGetMinY(contentRect)+0.5);
    CGContextStrokePath(ref);
}


@end
