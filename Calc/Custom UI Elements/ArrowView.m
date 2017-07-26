//
//  ArrowView.m
//  Calc
//
//  Created by Alex Coundouriotis on 7/24/17.
//  Copyright © 2017 ACApplications. All rights reserved.
//

#import "ArrowView.h"

@implementation ArrowView

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    [self.nextRingLabel setTransform:CGAffineTransformMakeRotation(-M_PI / 2)];
}

@end
