//
//  HistoryTableViewController.h
//  Calc
//
//  Created by Alex Coundouriotis on 7/23/17.
//  Copyright © 2017 ACApplications. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoryTableViewController : UITableViewController {
    int currentRingID;
    NSString *currentRingName;
}

@property (nonatomic) int currentRingID;
@property (strong, nonatomic) NSString *currentRingName;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButtonOutlet;

@end
