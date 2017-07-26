//
//  FirstViewController.m
//  Calc
//
//  Created by Alex Coundouriotis on 7/20/17.
//  Copyright © 2017 ACApplications. All rights reserved.
//

#import "FirstViewController.h"

@interface FirstViewController ()

@end

@implementation FirstViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    
    [self.startButton setAlpha:0.0];

    [self.circularProgress setStartAngle:-90];
    [self.circularProgress setBackgroundColor:[UIColor clearColor]];
    [self.circularProgress setTrackColor:[UIColor whiteColor]];
    [self.circularProgress setProgressColors:[NSArray arrayWithObject:[UIColor brownColor]]];
    [self.circularProgress.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.circularProgress.layer setShadowOpacity:1.0];
    [self.circularProgress.layer setShadowOffset:CGSizeMake(0, 0)];
    [self.circularProgress.layer setShadowRadius:7.5];
    [self.circularProgress setClipsToBounds:NO];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.circularProgress animateToAngle:360 duration:2.0 relativeDuration:nil completion:^(BOOL successful){
        [UIView animateWithDuration:0.5 animations:^{
            [self.startButton setAlpha:1.0];
        }];
    }];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
