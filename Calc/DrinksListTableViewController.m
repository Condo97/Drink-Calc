//
//  DrinksListTableViewController.m
//  Calc
//
//  Created by Alex Coundouriotis on 6/22/17.
//  Copyright © 2017 ACApplications. All rights reserved.
//

#import "DrinksListTableViewController.h"
#import "JSONManager.h"
#import "CDManager.h"
#import "ArchiverManager.h"
#import "EntryViewController.h"

@interface DrinksListTableViewController ()

@property (nonatomic) NSInteger selectedSpecificDrink;
@property (strong, nonatomic) NSString *selectedSpecificDrinkName;

@end

@implementation DrinksListTableViewController

@synthesize currentRing;
@synthesize currentGeneralDrink;

- (void) viewDidLoad {
    [super viewDidLoad];
    
    NSDictionary *ringsJson = [NSKeyedUnarchiver unarchiveObjectWithData:[[ArchiverManager sharedManager] loadDataFromDiskWithFileName:@"allJson"]];
    NSMutableArray *generalDrinksArray = [[JSONManager sharedManager] getGeneralDrinksAsArrayWithJSONDictionary:ringsJson andRingIndex:self.currentRing];
    
    [self setTitle:[generalDrinksArray objectAtIndex:self.currentGeneralDrink]];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDictionary *ringsJson = [NSKeyedUnarchiver unarchiveObjectWithData:[[ArchiverManager sharedManager] loadDataFromDiskWithFileName:@"allJson"]];
    NSMutableDictionary *specificDrinksDictionary = [[JSONManager sharedManager] getSpecificDrinksAsDictionaryWithJSONDictionary:ringsJson andRingIndex:self.currentRing andGeneralDrinkIndex:self.currentGeneralDrink];
    return specificDrinksDictionary.count;
}


- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    NSDictionary *ringsJson = [NSKeyedUnarchiver unarchiveObjectWithData:[[ArchiverManager sharedManager] loadDataFromDiskWithFileName:@"allJson"]];
    NSMutableDictionary *specificDrinksDictionary = [[JSONManager sharedManager] getSpecificDrinksAsDictionaryWithJSONDictionary:ringsJson andRingIndex:self.currentRing andGeneralDrinkIndex:self.currentGeneralDrink];
    
    [cell.textLabel setText:[[specificDrinksDictionary allKeys] objectAtIndex:indexPath.row]];
    [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@%@/%@",[specificDrinksDictionary objectForKey:[[specificDrinksDictionary allKeys] objectAtIndex:indexPath.row]], [[[JSONManager sharedManager] getRingMeasurementTypesBeforeSlashAsDictionaryWithJSONDictionary:ringsJson] objectForKey:[[[JSONManager sharedManager] getRingNamesInOrderWithJSONDictionary:ringsJson] objectAtIndex:self.currentRing]], [[[JSONManager sharedManager] getRingMeasurementTypesAfterSlashAsDictionaryWithJSONDictionary:ringsJson] objectForKey:[[[JSONManager sharedManager] getRingNamesInOrderWithJSONDictionary:ringsJson] objectAtIndex:self.currentRing]]]];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO];
    
    self.selectedSpecificDrink = indexPath.row;
    
    self.selectedSpecificDrinkName = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
    [self performSegueWithIdentifier:@"toEntryView" sender:nil];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55;
}

/*
// Override to support conditional editing of the table view.
- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void) tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL) tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Segue handler

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([[segue identifier] isEqualToString:@"toEntryView"]) {
        UINavigationController *navController = [segue destinationViewController];
        EntryViewController *entryVC = (EntryViewController *)[navController topViewController];
        [entryVC setCurrentRing:self.currentRing];
        [entryVC setCurrentGeneralDrink:self.currentGeneralDrink];
        [entryVC setCurrentSpecificDrink:self.selectedSpecificDrink];
        [entryVC setCurrentSpecificDrinkName:self.selectedSpecificDrinkName];
    }
}

-(IBAction)unwindToDrinksList:(UIStoryboardSegue *)segue {
    
}

@end
