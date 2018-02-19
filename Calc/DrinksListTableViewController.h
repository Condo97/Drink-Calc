//
//  DrinksListTableViewController.h
//  Calc
//
//  Created by Alex Coundouriotis on 6/22/17.
//  Copyright © 2017 ACApplications. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DrinksListTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    int currentRing;
    NSInteger currentGeneralDrink;
}

@property (nonatomic) int currentRing;
@property (nonatomic) NSInteger currentGeneralDrink;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButtonOutlet;

@end
