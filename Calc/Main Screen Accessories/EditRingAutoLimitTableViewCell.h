//
//  EditAutoLimitTableViewCell.h
//  Calc
//
//  Created by Alex Coundouriotis on 7/23/17.
//  Copyright © 2017 ACApplications. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditRingAutoLimitTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *ringName;
@property (weak, nonatomic) IBOutlet UITextField *limitTextField;
@property (weak, nonatomic) IBOutlet UISwitch *autoLimitSwitch;

@end
