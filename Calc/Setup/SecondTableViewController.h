//
//  SecondTableViewController.h
//  Calc
//
//  Created by Alex Coundouriotis on 7/21/17.
//  Copyright © 2017 ACApplications. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SecondTableViewController : UITableViewController <UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIDatePicker *birthdatePicker;
@property (weak, nonatomic) IBOutlet UIPickerView *heightPicker;
@property (weak, nonatomic) IBOutlet UIPickerView *weightPicker;
@property (weak, nonatomic) IBOutlet UIPickerView *genderPicker;

@property (weak, nonatomic) IBOutlet UIButton *continueButtonOutlet;

@end
