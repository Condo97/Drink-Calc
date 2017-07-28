//
//  EditRingAutoLimitTableViewController.m
//  Calc
//
//  Created by Alex Coundouriotis on 7/23/17.
//  Copyright © 2017 ACApplications. All rights reserved.
//

#import "EditRingAutoLimitTableViewController.h"
#import "EditRingAutoLimitTableViewCell.h"
#import "ArchiverManager.h"
#import "JSONManager.h"

@interface EditRingAutoLimitTableViewController ()

@property (strong, nonatomic) NSArray *ringNamesInOrder;
@property (strong, nonatomic) NSMutableArray *autoLimitSwitchArray;
@property (strong, nonatomic) NSMutableDictionary *ringUsesAutoLimit;

@end

@implementation EditRingAutoLimitTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSDictionary *ringsJson = [NSKeyedUnarchiver unarchiveObjectWithData:[[ArchiverManager sharedManager] loadDataFromDiskWithFileName:@"allJson"]];
    self.ringNamesInOrder = [[JSONManager sharedManager] getRingNamesInOrderWithJSONDictionary:ringsJson];
    
    self.autoLimitSwitchArray = [[NSMutableArray alloc] init];
    self.ringUsesAutoLimit = [[NSMutableDictionary alloc] init];
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"ringAutoLimitDictionary"] != nil)
        self.ringUsesAutoLimit = [[[NSUserDefaults standardUserDefaults] objectForKey:@"ringAutoLimitDictionary"] mutableCopy];
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.ringNamesInOrder.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EditRingAutoLimitTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    [self.autoLimitSwitchArray addObject:cell.autoLimitSwitch];
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:cell.limitTextField action:@selector(resignFirstResponder)];
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    toolbar.items = [NSArray arrayWithObject:barButton];
    
    cell.limitTextField.inputAccessoryView = toolbar;
    
    double limit = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"userLimit"] objectForKey:[self.ringNamesInOrder objectAtIndex:indexPath.row]] doubleValue];
    if(limit <= 9) {
        limit = round(100 * limit) / 100;
        [cell.limitTextField setText:[NSString stringWithFormat:@"%.2f", limit]];
    } else {
        limit = round(limit);
        [cell.limitTextField setText:[NSString stringWithFormat:@"%ld", (long)limit]];
    }
    
    [cell.ringName setText:[self.ringNamesInOrder objectAtIndex:indexPath.row]];
    if([[self.ringUsesAutoLimit allKeys] containsObject:[self.ringNamesInOrder objectAtIndex:indexPath.row]]) {
        if([[self.ringUsesAutoLimit objectForKey:[self.ringNamesInOrder objectAtIndex:indexPath.row]] isEqual:@YES]) {
            [cell.autoLimitSwitch setOn:YES];
            [cell.limitTextField setEnabled:NO];
        } else {
            [cell.autoLimitSwitch setOn:NO];
            [cell.limitTextField setEnabled:YES];
        }
    } else {
        [cell.autoLimitSwitch setOn:NO];
        [cell.limitTextField setEnabled:YES];
    }
    
    [cell.autoLimitSwitch addTarget:self action:@selector(switchToggled:) forControlEvents:UIControlEventValueChanged];
    
    return cell;
}

- (IBAction)saveButton:(id)sender {
    NSMutableDictionary *ringLimitDictionary = [[[NSUserDefaults standardUserDefaults] objectForKey:@"userLimit"] mutableCopy];
    for(int i = 0; i < self.ringNamesInOrder.count; i++) {
        EditRingAutoLimitTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        if(cell.autoLimitSwitch.on)
            [self.ringUsesAutoLimit setObject:@YES forKey:[self.ringNamesInOrder objectAtIndex:i]];
        else {
            [self.ringUsesAutoLimit setObject:@NO forKey:[self.ringNamesInOrder objectAtIndex:i]];
            [ringLimitDictionary setObject:[NSNumber numberWithInt:[cell.limitTextField.text intValue]] forKey:[self.ringNamesInOrder objectAtIndex:i]];
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:self.ringUsesAutoLimit forKey:@"ringAutoLimitDictionary"];
    [[NSUserDefaults standardUserDefaults] setObject:ringLimitDictionary forKey:@"userLimit"];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) switchToggled:(id)sender {
    for(int i = 0; i < self.autoLimitSwitchArray.count; i++) {
        if([sender isEqual:[self.autoLimitSwitchArray objectAtIndex:i]]) {
            if([(UISwitch *)sender isOn])
                [self.ringUsesAutoLimit setObject:@YES forKey:[self.ringNamesInOrder objectAtIndex:i]];
            else
                [self.ringUsesAutoLimit setObject:@NO forKey:[self.ringNamesInOrder objectAtIndex:i]];
        }
    }
    
    self.autoLimitSwitchArray = [[NSMutableArray alloc] init];
    
    [self.tableView reloadData];
}

- (void) resignFirstResponder:(id)sender {
    [self.view endEditing:YES];
}

@end
