//
//  FirstAndAHalfViewController.m
//  Calc
//
//  Created by Alex Coundouriotis on 8/1/17.
//  Copyright © 2017 ACApplications. All rights reserved.
//

#import "FirstAndAHalfViewController.h"

@interface FirstAndAHalfViewController ()

@end

@implementation FirstAndAHalfViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSMutableArray *imageArray = [[NSMutableArray alloc] init];
    
    for(int i = 0; i < 70; i++) {
        [imageArray addObject:[UIImage imageNamed:[NSString stringWithFormat:@"%ld.png", (long)i]]];
    }
    
    [self.animation setAnimationImages:imageArray];
    [self.animation setAnimationDuration:7.0];
    [self.animation startAnimating];
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
