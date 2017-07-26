
//
//  LoadingViewController.m
//  Calc
//
//  Created by Alex Coundouriotis on 7/11/17.
//  Copyright © 2017 ACApplications. All rights reserved.
//

#import "LoadingViewController.h"
#import "Calc-Swift.h"

@interface LoadingViewController ()

@property (strong) KDCircularProgress *progressView;

@end

@implementation LoadingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.progressView = [[KDCircularProgress alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 250) / 2, (self.view.frame.size.height - 250) / 2, 250, 250)];
    [self.progressView setStartAngle:-90];
    [self.progressView setTrackColor:[UIColor whiteColor]];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
