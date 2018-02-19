//
//  CustomSlider.m
//  Calc
//
//  Created by Alex Coundouriotis on 8/21/17.
//  Copyright © 2017 ACApplications. All rights reserved.
//

#import "CustomSlider.h"

@implementation CustomSlider

- (BOOL) pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    CGRect bounds = self.bounds;
    bounds = CGRectInset(bounds, -100, -150);
    return CGRectContainsPoint(bounds, point);
}

@end
