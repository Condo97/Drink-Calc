//
//  EntryViewController.h
//  Calc
//
//  Created by Alex Coundouriotis on 6/26/17.
//  Copyright © 2017 ACApplications. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BAFluidView.h"
#import "RoundedView.h"
#import "CustomSlider.h"

@interface EntryViewController : UIViewController {
    int currentRing;
    NSInteger currentGeneralDrink;
    NSInteger currentSpecificDrink;
    NSString *currentSpecificDrinkName;
    NSString *currentRingName;
    BOOL isShot;
}

@property (weak, nonatomic) IBOutlet BAFluidView *liquidView;
@property (weak, nonatomic) IBOutlet UIView *sliderBGView;
@property (weak, nonatomic) IBOutlet UIStepper *cupStepper;
@property (weak, nonatomic) IBOutlet UILabel *cupLabel;
@property (weak, nonatomic) IBOutlet UIView *roundedViewOverlay;

@property (strong, nonatomic) CustomSlider *slider;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *roundedViewTopConstraint;

@property (nonatomic) int currentRing;
@property (nonatomic) double amount, finalAmount;
@property (nonatomic) NSInteger currentGeneralDrink, currentSpecificDrink;
@property (strong, nonatomic) NSString *currentSpecificDrinkName, *currentRingName;

@property (nonatomic) BOOL isShot;


@end
