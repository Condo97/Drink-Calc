//
//  EntryViewController.m
//  Calc
//
//  Created by Alex Coundouriotis on 6/26/17.
//  Copyright © 2017 ACApplications. All rights reserved.
//

#import "EntryViewController.h"
#import "JSONManager.h"
#import "ArchiverManager.h"
#import "CDManager.h"
#import "RoundedView.h"
#import "UIColor+ColorWithHex.h"
#import "HealthKitManager.h"

@interface EntryViewController ()

@property (nonatomic) int maxAmplitude;
@property (nonatomic) int minAmplitude;
@property (strong, nonatomic) RoundedView *sliderBackgroundView, *roundedViewBackgroundView, *customAmountView, *infoView, *addShotView;
@property (strong, nonatomic) UILabel *infoViewLabel;

@property (strong, nonatomic) NSString *measurementUnitsBeforeSlash, *measurementUnitsAfterSlash, *thingToMeasure, *ringColorHex, *hkIdentifierToWrite, *hkIdentifierToWriteUnit;
@property (nonatomic) int size, sliderMax, increments, shotCount;
@property (nonatomic) double amount, finalAmount;

@end

@implementation EntryViewController

@synthesize currentRing;
@synthesize currentGeneralDrink, currentSpecificDrink;
@synthesize currentSpecificDrinkName, currentRingName;
@synthesize isShot;

- (void) viewDidLoad {
    [super viewDidLoad];
    
    self.sliderMax = 42; //MAKE DYNAMIC
    self.increments = 2; //MAKE DYNAMIC
    
    self.shotCount = 0;
    
    if(isShot) {
        self.sliderMax = 5;
        self.increments = 1;
    }
    
    NSDictionary *json = [NSKeyedUnarchiver unarchiveObjectWithData:[[ArchiverManager sharedManager] loadDataFromDiskWithFileName:@"allJson"]];
    currentRingName = [[[JSONManager sharedManager] getRingNamesInOrderWithJSONDictionary:json] objectAtIndex:currentRing];
    self.measurementUnitsBeforeSlash = [[[JSONManager sharedManager] getRingMeasurementTypesBeforeSlashAsDictionaryWithJSONDictionary:json] objectForKey:currentRingName];
    self.measurementUnitsAfterSlash = [[[JSONManager sharedManager] getRingMeasurementTypesAfterSlashAsDictionaryWithJSONDictionary:json] objectForKey:currentRingName];
    self.thingToMeasure = [[[JSONManager sharedManager] getRingThingsToMeasureAsDictionaryWithJSONDictionary:json] objectForKey:currentRingName];
    self.amount = [[[[JSONManager sharedManager] getSpecificDrinksAsDictionaryWithJSONDictionary:json andRingIndex:self.currentRing andGeneralDrinkIndex:self.currentGeneralDrink] objectForKey:self.currentSpecificDrinkName] doubleValue];
    self.ringColorHex = [[[JSONManager sharedManager] getRingNamesAsDictionaryWithJSONDictionary:json] objectForKey:currentRingName];
    self.hkIdentifierToWrite = [[[[[JSONManager sharedManager] getRingHKWriteTypesAsDictionaryWithJSONDictionary:json] mutableArrayValueForKey:currentRingName] objectAtIndex:0] objectAtIndex:0];
    self.hkIdentifierToWriteUnit = [[[[[JSONManager sharedManager] getRingHKWriteTypesAsDictionaryWithJSONDictionary:json] mutableArrayValueForKey:currentRingName] objectAtIndex:0] objectAtIndex:1];
    
    self.maxAmplitude = 70;
    self.minAmplitude = 40;
    
    [self setTitle:[NSString stringWithFormat:@"%@ Entry", currentSpecificDrinkName]];
    
    [self.liquidView setFillColor:[UIColor colorWithHex:self.ringColorHex]];
    [self.liquidView setFillDuration:2.0];
    [self.liquidView setFillAutoReverse:NO];
    [self.liquidView setFillRepeatCount:1];
    [self.liquidView setMaxAmplitude: self.maxAmplitude];
    [self.liquidView setMinAmplitude: self.minAmplitude];
    [self.liquidView startAnimation];
    [self.liquidView startTiltAnimation];
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurEffectView.frame = self.view.frame;
    [self.view insertSubview:blurEffectView aboveSubview:self.liquidView];
    
    self.sliderBackgroundView = [[RoundedView alloc] initWithFrame:CGRectMake((self.view.frame.size.width-((self.view.frame.size.height-self.view.frame.size.width/3)/2))-30 - 17 - 14, ((self.view.frame.size.height-self.view.frame.size.width/3)/2)+self.navigationController.navigationBar.frame.size.height*2 - 28 + 2 - 5, self.view.frame.size.height-self.view.frame.size.width/3+28 + 5, 70.0)];
    self.sliderBackgroundView.transform = CGAffineTransformMakeRotation(M_PI_2*3);
    [self.sliderBackgroundView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self.sliderBackgroundView];
    CGRect sliderBackgroundViewFrame = self.sliderBackgroundView.frame;
    sliderBackgroundViewFrame.origin.x = sliderBackgroundViewFrame.origin.x + 150;
    [self.sliderBackgroundView setFrame:sliderBackgroundViewFrame];
    
    self.slider = [[UISlider alloc] initWithFrame:CGRectMake((self.view.frame.size.width-((self.view.frame.size.height-self.view.frame.size.width/3)/2))-30 - 14, ((self.view.frame.size.height-self.view.frame.size.width/3)/2)+self.navigationController.navigationBar.frame.size.height*2, self.view.frame.size.height-self.view.frame.size.width/3, 10.0)];
    self.slider.transform = CGAffineTransformMakeRotation(M_PI_2*3);
    [self.slider setMaximumValue:self.sliderMax];
    [self.slider setMinimumValue:0];
    [self.slider setValue:(self.sliderMax/2)];
    [self.slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.slider addTarget:self action:@selector(sliderEndedTouches:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.slider];
    
    CGRect sliderViewFrame = self.slider.frame;
    sliderViewFrame.origin.x = sliderViewFrame.origin.x + 150;
    
    [self.slider setFrame:sliderViewFrame];
    
    CGRect roundedViewOverlayFrame = self.roundedViewOverlay.frame;
    roundedViewOverlayFrame.origin.y = 700;
    [self.roundedViewOverlay setFrame:roundedViewOverlayFrame];
    
    if(self.view.frame.size.width <= 330)
        self.customAmountView = [[RoundedView alloc] initWithFrame:CGRectMake(self.view.frame.size.width - (self.sliderBackgroundView.frame.origin.x - 150 + self.sliderBackgroundView.frame.size.width) - 150, (self.sliderBackgroundView.frame.size.height + self.sliderBackgroundView.frame.origin.y - self.roundedViewOverlay.frame.size.height), self.sliderBackgroundView.frame.size.width, self.roundedViewOverlay.frame.size.height)];
    else
        self.customAmountView = [[RoundedView alloc] initWithFrame:CGRectMake(self.view.frame.size.width - (self.sliderBackgroundView.frame.origin.x - 150 + self.sliderBackgroundView.frame.size.width) - 150, (self.sliderBackgroundView.frame.size.height + self.sliderBackgroundView.frame.origin.y - self.roundedViewOverlay.frame.size.height), self.roundedViewOverlay.frame.size.height, self.roundedViewOverlay.frame.size.height)];
    [self.customAmountView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self.customAmountView];
    
    UIButton *customAmountButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [customAmountButton setImage:[[UIImage imageNamed:@"editButtonImage"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [customAmountButton setTintColor:[UIColor colorWithHex:self.ringColorHex]];
    [customAmountButton addTarget:self action:@selector(customAmountButtonPressed:) forControlEvents:UIControlEventTouchDown];
    [self.customAmountView addSubview:customAmountButton];
    [customAmountButton setFrame:CGRectMake((self.customAmountView.frame.size.width - 30) / 2, (self.customAmountView.frame.size.height - 30) / 2, 30, 30)];
    
    [self setBackgroundHeightForSliderValue:self.slider.value];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    CGRect roundedViewOverlayFrame = self.roundedViewOverlay.frame;
    [self.roundedViewTopConstraint setConstant:((self.sliderBackgroundView.frame.size.height + self.sliderBackgroundView.frame.origin.y - roundedViewOverlayFrame.size.height) - self.view.frame.size.height)];
    
    self.infoView = [[RoundedView alloc] initWithFrame:CGRectMake(self.roundedViewOverlay.frame.origin.x, self.sliderBackgroundView.frame.origin.y - 150, self.roundedViewOverlay.frame.size.width, self.roundedViewOverlay.frame.size.height*1.5)];
    [self.infoView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self.infoView];
    
    self.infoViewLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.infoView.frame.size.width - 150) / 2, (self.infoView.frame.size.height - 75) / 2, 150, 75)];
    [self.infoViewLabel setNumberOfLines:2];
    [self.infoViewLabel setAdjustsFontSizeToFitWidth:YES];
    [self.infoViewLabel setFont:[UIFont systemFontOfSize:25.0]];
    [self.infoViewLabel setTextAlignment:NSTextAlignmentCenter];
    [self.infoView addSubview:self.infoViewLabel];
    
    if((int)self.slider.value % 2 != 0)
        [self.slider setValue:((int)self.slider.value - ((int)self.slider.value % self.increments) + self.increments)];
    self.size = self.slider.value;
    [self updateInfoViewLabelTextWithAmount:[self getCalculatedAmountForSliderValue:self.size]];
    
    [UIView animateWithDuration:0.7 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^(void){
        CGRect sliderBackgroundViewFrame = self.sliderBackgroundView.frame;
        CGRect sliderViewFrame = self.slider.frame;
        CGRect customAmountViewFrame = self.customAmountView.frame;
        CGRect infoViewFrame = self.infoView.frame;
        
        customAmountViewFrame.origin.x = customAmountViewFrame.origin.x + 150;// - self.view.frame.size.height);
        
        infoViewFrame.origin.y = infoViewFrame.origin.y + 150;
        
        [self.view layoutIfNeeded];
        [self.customAmountView setFrame:customAmountViewFrame];
        [self.infoView setFrame:infoViewFrame];
        
        sliderBackgroundViewFrame.origin.x = sliderBackgroundViewFrame.origin.x - 150;
        [self.sliderBackgroundView setFrame:sliderBackgroundViewFrame];
        
        sliderViewFrame.origin.x = sliderViewFrame.origin.x - 150;
        [self.slider setFrame:sliderViewFrame];
        
        //[self.roundedViewBackgroundView setFrame:roundedViewOverlayFrame];
        
    } completion:^(BOOL finished){
        NSLog(@"");
    }];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) updateInfoViewLabelTextWithAmount:(double)theAmount {
    NSString *infoViewLabelTextBeforeAttributes;
    NSMutableAttributedString *infoViewLabelText;
    
    if(theAmount <= 9) {
        theAmount = round(100 * theAmount) / 100;
        if(!isShot)
            infoViewLabelTextBeforeAttributes = [NSString stringWithFormat:@"%ld%@\n%.2f%@ of %@", (long)self.size, self.measurementUnitsAfterSlash, (double)theAmount, self.measurementUnitsBeforeSlash, self.thingToMeasure];
        else {
            NSString *s = @"s";
            if(theAmount == 1)
                s = @"";
            infoViewLabelTextBeforeAttributes = [NSString stringWithFormat:@"%ld Shot%@\n%.2f%@ of %@", (long)self.size, s, (double)theAmount, self.measurementUnitsBeforeSlash, self.thingToMeasure];
        }
        infoViewLabelText = [[NSMutableAttributedString alloc] initWithString:infoViewLabelTextBeforeAttributes];
        [infoViewLabelText addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHex:self.ringColorHex] range:[infoViewLabelTextBeforeAttributes rangeOfString:[NSString stringWithFormat:@"%.2f", (double)theAmount]]];
        [infoViewLabelText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17.0] range:[infoViewLabelTextBeforeAttributes rangeOfString:[NSString stringWithFormat:@"%.2f%@ of %@", (double)theAmount, self.measurementUnitsBeforeSlash, self.thingToMeasure]]];
        [infoViewLabelText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17.0 weight:UIFontWeightBold] range:[infoViewLabelTextBeforeAttributes rangeOfString:[NSString stringWithFormat:@"%.2f", (double)theAmount]]];
    } else {
        theAmount = round(theAmount);
        if(!isShot)
            infoViewLabelTextBeforeAttributes = [NSString stringWithFormat:@"%ld%@\n%ld%@ of %@", (long)self.size, self.measurementUnitsAfterSlash, (long)theAmount, self.measurementUnitsBeforeSlash, self.thingToMeasure];
        else {
            NSString *s = @"s";
            if(theAmount == 1)
                s = @"";
            infoViewLabelTextBeforeAttributes = [NSString stringWithFormat:@"%ld Shot%@\n%ld%@ of %@", (long)self.size, s, (long)theAmount, self.measurementUnitsBeforeSlash, self.thingToMeasure];
        }
        infoViewLabelText = [[NSMutableAttributedString alloc] initWithString:infoViewLabelTextBeforeAttributes];
        [infoViewLabelText addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHex:self.ringColorHex] range:[infoViewLabelTextBeforeAttributes rangeOfString:[NSString stringWithFormat:@"%ld", (long)theAmount]]];
        [infoViewLabelText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17.0] range:[infoViewLabelTextBeforeAttributes rangeOfString:[NSString stringWithFormat:@"%ld%@ of %@", (long)theAmount, self.measurementUnitsBeforeSlash, self.thingToMeasure]]];
        [infoViewLabelText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17.0 weight:UIFontWeightBold] range:[infoViewLabelTextBeforeAttributes rangeOfString:[NSString stringWithFormat:@"%ld", (long)theAmount]]];
    }
    
    [infoViewLabelText addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:[infoViewLabelTextBeforeAttributes rangeOfString:[NSString stringWithFormat:@"%@", self.measurementUnitsBeforeSlash]]];
    [infoViewLabelText addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHex:self.ringColorHex] range:[infoViewLabelTextBeforeAttributes rangeOfString:[NSString stringWithFormat:@"%@", self.thingToMeasure]]];
    [infoViewLabelText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17.0 weight:UIFontWeightBold] range:[infoViewLabelTextBeforeAttributes rangeOfString:[NSString stringWithFormat:@"%@", self.thingToMeasure]]];
    
    [self.infoViewLabel setAttributedText:infoViewLabelText];
}

- (double) getCalculatedAmountForSliderValue:(float)sliderValue {
    self.finalAmount = (sliderValue * self.amount * self.cupStepper.value);
    return self.finalAmount;
}

- (void) sliderValueChanged:(id)sender {
    double chunk = self.slider.value - (fmod(self.slider.value, (double)self.increments) - (double)self.increments) - (double)self.increments;
    if(fmod(self.slider.value, (double)self.increments) >= ((double)self.increments/2)) {
        self.slider.value = chunk + self.increments;
    } else {
        self.slider.value = chunk;
    }
    
    self.size = self.slider.value;
    [self updateInfoViewLabelTextWithAmount:[self getCalculatedAmountForSliderValue:self.size]];
}

- (void) customAmountButtonPressed:(id)sender {
    NSString *alertText = @"";
    if(isShot)
        alertText = @"Enter desired number of shots.";
    else
        alertText = [NSString stringWithFormat:@"Enter in desired size in %@.", self.measurementUnitsAfterSlash];
    
    UIAlertController *customAmountAlert = [UIAlertController alertControllerWithTitle:@"Custom Amount Entry" message:alertText preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelButton = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *confirmButton = [UIAlertAction actionWithTitle:@"Enter" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        NSString *customAmount = [[customAmountAlert textFields] objectAtIndex:0].text;
        if([[NSScanner scannerWithString:customAmount] scanInt:nil]) {
            [self.slider setValue:[customAmount floatValue]];
            self.size = [customAmount floatValue];
            [self updateInfoViewLabelTextWithAmount:[self getCalculatedAmountForSliderValue:[customAmount floatValue]]];
            
            if([customAmount floatValue] <= self.sliderMax)
                [self setBackgroundHeightForSliderValue:[customAmount floatValue]];
            else
                [self setBackgroundHeightForSliderValue:self.sliderMax];
        }
    }];
    
    [customAmountAlert addTextFieldWithConfigurationHandler:^(UITextField *textField){
        [textField setPlaceholder:[NSString stringWithFormat:@"Custom amount in %@", self.measurementUnitsAfterSlash]];
        [textField setKeyboardType:UIKeyboardTypeNumberPad];
    }];
    
    [customAmountAlert addAction:cancelButton];
    [customAmountAlert addAction:confirmButton];
    [self presentViewController:customAmountAlert animated:YES completion:nil];
}

- (void) sliderEndedTouches:(id)sender {
    [self setBackgroundHeightForSliderValue:self.slider.value];
}

- (void) setBackgroundHeightForSliderValue:(float)sliderValue {
    [self.liquidView setFillDuration:2.5];
    [self.liquidView setMaxAmplitude:(self.maxAmplitude * (sliderValue / (self.sliderMax * 2 / 3)))];
    [self.liquidView setMinAmplitude:(self.minAmplitude * (sliderValue / (self.sliderMax * 2 / 3)))];
    
    if(sliderValue > 0) {
        [self.liquidView fillTo: [NSNumber numberWithDouble: ((sliderValue * (self.liquidView.frame.size.height)) / self.sliderMax) / (self.liquidView.frame.size.height + 100) + 0.17]]; //[NSNumber numberWithDouble:((((self.liquidView.frame.size.height - self.liquidView.frame.size.height/5) * sliderValue) / self.sliderMax) + self.liquidView.frame.size.height/5) / (self.liquidView.frame.size.height - self.liquidView.frame.size.height/5)]];
        NSLog(@"%@", [NSNumber numberWithDouble: ((sliderValue * (self.liquidView.frame.size.height)) / self.sliderMax) / (self.liquidView.frame.size.height + 100) + 0.17]);
    } else {
        [self.liquidView fillTo:@0.0];
    }
}

- (IBAction)stepperValueChanged:(id)sender {
    NSString *s = @"";
    [self.cupLabel setText:@""];
    
    if(self.cupStepper.value != 1)
        s = @"s";
    [self.cupLabel setText:[NSString stringWithFormat:@"%d Cup%@", (int)self.cupStepper.value, s]];
    [self updateInfoViewLabelTextWithAmount:[self getCalculatedAmountForSliderValue:self.size]];
}


#pragma mark - Segue handler

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([[segue identifier] isEqualToString:@"saveSegue"]) {
        int limit = [(NSNumber *)[(NSDictionary *)[[NSUserDefaults standardUserDefaults] objectForKey:@"userLimit"] objectForKey:currentRingName] intValue];
        
        [[CDManager sharedManager] saveRingDataWithRingID:[NSString stringWithFormat:@"%d", self.currentRing] andAmount:[NSString stringWithFormat:@"%f", self.finalAmount] andLimit:[NSString stringWithFormat:@"%ld", (long)limit] andName:currentSpecificDrinkName];
        [[HealthKitManager sharedManager] writeToHealthKitWithQuantityTypeIdentifier:self.hkIdentifierToWrite andValue:self.finalAmount andUnit:self.hkIdentifierToWriteUnit];
    }
}

@end
