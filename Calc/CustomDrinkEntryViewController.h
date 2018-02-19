//
//  CustomDrinkEntryViewController.h
//  Calc
//
//  Created by Alex Coundouriotis on 8/20/17.
//  Copyright © 2017 ACApplications. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomDrinkEntryViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextField *size;
@property (weak, nonatomic) IBOutlet UITextField *amountForSize;
@property (weak, nonatomic) IBOutlet UISegmentedControl *isShot;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButtonOutlet;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButtonOutlet;

@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;

@property (strong, nonatomic) NSString *currentRingName, *currentGeneralDrinkName;
@property (nonatomic) int currentRing;

@end
