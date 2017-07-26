//
//  FirstViewController.h
//  Calc
//
//  Created by Alex Coundouriotis on 7/20/17.
//  Copyright © 2017 ACApplications. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Calc-Swift.h"

@interface FirstViewController : UIViewController

@property (weak, nonatomic) IBOutlet KDCircularProgress *circularProgress;
@property (weak, nonatomic) IBOutlet UIButton *startButton;

@end
