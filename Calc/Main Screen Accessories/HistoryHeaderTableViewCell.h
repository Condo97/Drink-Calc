//
//  HistoryHeaderTableViewCell.h
//  Calc
//
//  Created by Alex Coundouriotis on 7/25/17.
//  Copyright © 2017 ACApplications. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Calc-Swift.h"

@interface HistoryHeaderTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet KDCircularProgress *circularProgress;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UILabel *circularProgressLabel;

@end
