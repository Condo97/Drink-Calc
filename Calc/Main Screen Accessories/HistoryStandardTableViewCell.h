//
//  HistoryStandardTableViewCell.h
//  Calc
//
//  Created by Alex Coundouriotis on 7/26/17.
//  Copyright © 2017 ACApplications. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoryStandardTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;

@end
