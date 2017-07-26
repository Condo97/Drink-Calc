//
//  EditProfileTableViewController.h
//  Calc
//
//  Created by Alex Coundouriotis on 7/23/17.
//  Copyright © 2017 ACApplications. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditProfileTableViewController : UITableViewController <UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource> {
    NSString *currentRingName;
}

@property (weak, nonatomic) IBOutlet UIDatePicker *birthdatePicker;
@property (weak, nonatomic) IBOutlet UIPickerView *heightPicker;
@property (weak, nonatomic) IBOutlet UIPickerView *weightPicker;
@property (weak, nonatomic) IBOutlet UIPickerView *genderPicker;
@property (weak, nonatomic) IBOutlet UIButton *updateWithHealthAppValuesButtonOutlet;

@property (strong, nonatomic) NSString *currentRingName;

@end
