//
//  CustomDrinkEntryViewController.m
//  Calc
//
//  Created by Alex Coundouriotis on 8/20/17.
//  Copyright © 2017 ACApplications. All rights reserved.
//

#import "CustomDrinkEntryViewController.h"
#import "JSONManager.h"
#import "ArchiverManager.h"
#import "UIColor+ColorWithHex.h"
#import "CDManager.h"
#import "HTTPManager.h"

@interface CustomDrinkEntryViewController ()

@end

@implementation CustomDrinkEntryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSDictionary *ringsJson = [NSKeyedUnarchiver unarchiveObjectWithData:[[ArchiverManager sharedManager] loadDataFromDiskWithFileName:@"allJson"]];
    UIColor *currentColor = [UIColor colorWithHex:[[[JSONManager sharedManager] getRingNamesAsDictionaryWithJSONDictionary:ringsJson] objectForKey:self.currentRingName]];
    NSString *unitsBeforeSlash = [[[JSONManager sharedManager] getRingMeasurementTypesBeforeSlashAsDictionaryWithJSONDictionary:ringsJson] objectForKey:self.currentRingName];
    NSString *unitsAfterSlash = [[[JSONManager sharedManager] getRingMeasurementTypesAfterSlashAsDictionaryWithJSONDictionary:ringsJson] objectForKey:self.currentRingName];
    
    [self.cancelButtonOutlet setTintColor:currentColor];
    [self.saveButtonOutlet setTintColor:currentColor];
    [self.isShot setTintColor:currentColor];
    
    [self.amountLabel setText:[NSString stringWithFormat:@"Amount in %@", unitsBeforeSlash]];
    [self.amountForSize setPlaceholder:[NSString stringWithFormat:@"Amount (%@)", unitsBeforeSlash]];
    
    [self.sizeLabel setText:[NSString stringWithFormat:@"Size in %@", unitsAfterSlash]];
    [self.size setPlaceholder:[NSString stringWithFormat:@"Size (%@)", unitsAfterSlash]];
    
    [self.tableView setAllowsSelection:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

- (BOOL) shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if([identifier isEqualToString:@"saveAndExit"]) {
        if(self.name.text.length != 0 || self.amountForSize.text.length != 0 || self.size.text.length != 0) {
            NSDictionary *ringsJson = [NSKeyedUnarchiver unarchiveObjectWithData:[[ArchiverManager sharedManager] loadDataFromDiskWithFileName:@"allJson"]];
            NSString *currentRingName = [[[JSONManager sharedManager] getRingNamesInOrderWithJSONDictionary:ringsJson] objectAtIndex:self.currentRing];
            NSString *isShotFinal = [[NSString alloc] init];
            if(self.isShot.selectedSegmentIndex == 1)
                isShotFinal = @"0";
            else
                isShotFinal = @"1";
            
            NSString *amountPerOz = [NSString stringWithFormat:@"%.2f", self.amountForSize.text.doubleValue / self.size.text.doubleValue];
            
            NSArray *dataArray = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%ld", (long)self.currentRing], self.name.text, amountPerOz, isShotFinal, self.currentGeneralDrinkName, nil];
            
            [[CDManager sharedManager] saveDataArray:dataArray forEntityNamed:@"CustomDrink" forAttributesNamed:@"ringID", @"name", @"amount", @"isShot", @"generalDrinkName", nil];
            [[HTTPManager sharedManager] saveCustomDrinkWithRingName:currentRingName andGeneralDrinkName:self.currentGeneralDrinkName andSpecificDrinkName:self.name.text andAmount:amountPerOz andIsShot:isShotFinal.intValue];
            
        } else {
            UIAlertController *incompleteFieldsAlertController = [UIAlertController alertControllerWithTitle:@"Incomplete Fields" message:@"Please complete all incomplete fields." preferredStyle:UIAlertControllerStyleAlert];
            [incompleteFieldsAlertController addAction:[UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleDefault handler:nil]];
            
            [self presentViewController:incompleteFieldsAlertController animated:YES completion:nil];
            
            return NO;
        }
    }
    return YES;
}

@end
