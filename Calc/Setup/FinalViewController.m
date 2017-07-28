//
//  FinalTableViewController.m
//  Calc
//
//  Created by Alex Coundouriotis on 7/23/17.
//  Copyright © 2017 ACApplications. All rights reserved.
//

#import "FinalViewController.h"

@interface FinalViewController ()

@end

@implementation FinalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    [self.circularProgress animateToAngle:360 duration:2.0 relativeDuration:nil completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
