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
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    self.progressView = [[KDCircularProgress alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 250) / 2, (self.view.frame.size.height - 250) / 2, 250, 250)];
    [self.progressView setStartAngle:-90];
    [self.progressView setTrackColor:[UIColor grayColor]];
    [self.progressView setTrackColor:[UIColor whiteColor]];
    [self.progressView setProgressColors:[NSArray arrayWithObject:[UIColor brownColor]]];
    [self.progressView.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.progressView.layer setShadowOpacity:1.0];
    [self.progressView.layer setShadowOffset:CGSizeMake(0, 0)];
    [self.progressView.layer setShadowRadius:7.5];
    [self.progressView setClipsToBounds:NO];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, self.view.frame.origin.y + 50, self.view.frame.size.width - 30, 100)];
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"initialSetupComplete"] == NO)
        [label setText:@"Hang tight, we're downloading a little more..."];
    else
        [label setText:@"Hang tight, we're downloading some new content..."];
    [label setFont:[UIFont systemFontOfSize:27 weight:UIFontWeightMedium]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setNumberOfLines:3];
    
    [self.view addSubview:self.progressView];
    [self.view addSubview:label];
    
    JSONManager *jsonManager = [JSONManager sharedManager];
    [jsonManager setDelegate:self];
    
    [jsonManager setupScrollviewBackgroundImagesWithJSONDictionary:self.jsonDictionary withImageSize:self.imageSize withCompletion:^(BOOL successful) {
        if(successful) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) updateProgress:(int)percent {
    [self.progressView animateToAngle:percent duration:2.0 relativeDuration:NO completion:nil];
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
