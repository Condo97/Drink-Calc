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
#import "KFKeychain.h"
#import "UIColor+ColorWithHex.h"
#import "CustomDrinkEntryViewController.h"
@import GoogleMobileAds;

@interface DrinksListTableViewController ()

@property (nonatomic) NSInteger selectedSpecificDrink;
@property (strong, nonatomic) NSString *selectedSpecificDrinkName;
@property (nonatomic) BOOL specificDrinkIsShot, shouldShowAds;
@property (strong, nonatomic) NSDictionary *specificDrinkIsShotDictionary;
@property (strong, nonatomic) GADBannerView *bannerAd;
@property (strong, nonatomic) NSMutableArray *customDrinkName, *customDrinkAmount, *customDrinkIsShot;
@property (nonatomic) double amount;

@end

@implementation DrinksListTableViewController

@synthesize currentRing;
@synthesize currentGeneralDrink;

- (void) viewDidLoad {
    [super viewDidLoad];
    
    NSDictionary *ringsJson = [NSKeyedUnarchiver unarchiveObjectWithData:[[ArchiverManager sharedManager] loadDataFromDiskWithFileName:@"allJson"]];
    NSMutableArray *generalDrinksArray = [[JSONManager sharedManager] getGeneralDrinksAsArrayWithJSONDictionary:ringsJson andRingIndex:self.currentRing];
    self.specificDrinkIsShotDictionary = [[JSONManager sharedManager] getSpecificDrinkIsShotAsDictionaryWithJSONDictionary:ringsJson andRingIndex:self.currentRing andGeneralDrinkIndex:currentGeneralDrink];
    
    self.shouldShowAds = YES;
    if([[KFKeychain loadObjectForKey:@"adsRemoved"] isEqualToString:@"YES"])
        self.shouldShowAds = NO;
    
    if(self.shouldShowAds) {
        self.bannerAd = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner origin:CGPointMake((self.view.frame.size.width - kGADAdSizeBanner.size.width) / 2, self.view.frame.size.height - kGADAdSizeBanner.size.height)];
        [self.bannerAd setAdUnitID:@"ca-app-pub-0561860165633355/9018661352"];
        [self.bannerAd setRootViewController:self];
        [self.view addSubview:self.bannerAd];
        [self.bannerAd loadRequest:[GADRequest request]];
    }
    
    [self setTitle:[generalDrinksArray objectAtIndex:self.currentGeneralDrink]];
    
    [self.navigationController.navigationBar.layer setMasksToBounds:NO];
    [self.navigationController.navigationBar.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.navigationController.navigationBar.layer setShadowOpacity:0.0];
    //[self.navigationController.navigationBar.layer setShadowRadius:7.5];
    //[self.navigationController.navigationBar.layer setShadowOffset:CGSizeMake(0, 0)];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    NSMutableArray *lel, *tempDrinkName, *tempDrinkAmount, *tempIsShot;
    NSDictionary *ringsJson = [NSKeyedUnarchiver unarchiveObjectWithData:[[ArchiverManager sharedManager] loadDataFromDiskWithFileName:@"allJson"]];
    [[CDManager sharedManager] getParsedCustomDrinksForDataArray:[[CDManager sharedManager] getDataArrayForEntityNamed:@"CustomDrink"] andFilterRingID:[NSString stringWithFormat:@"%ld",(long)self.currentRing] andFilterGeneralDrinkName:[[[JSONManager sharedManager] getGeneralDrinksAsArrayWithJSONDictionary:ringsJson andRingIndex:self.currentRing] objectAtIndex:self.currentGeneralDrink] outputRingID:&lel outputDrinkName:&tempDrinkName outputDrinkAmount:&tempDrinkAmount outputIsShot:&tempIsShot];
    
    self.customDrinkName = [[NSMutableArray alloc] init];
    
    self.customDrinkAmount = [[NSMutableArray alloc] init];
    self.customDrinkIsShot = [[NSMutableArray alloc] init];
    
    self.customDrinkName = [tempDrinkName mutableCopy];
    self.customDrinkAmount = [tempDrinkAmount mutableCopy];
    self.customDrinkIsShot = [tempIsShot mutableCopy];
    
    [self.tableView reloadData];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source


- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 1)
        return @"Custom Drinks";
    return @"";
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0) {
        NSDictionary *ringsJson = [NSKeyedUnarchiver unarchiveObjectWithData:[[ArchiverManager sharedManager] loadDataFromDiskWithFileName:@"allJson"]];
        NSMutableDictionary *specificDrinksDictionary = [[JSONManager sharedManager] getSpecificDrinksAsDictionaryWithJSONDictionary:ringsJson andRingIndex:self.currentRing andGeneralDrinkIndex:self.currentGeneralDrink];
        
        return specificDrinksDictionary.count;
    }
    return self.customDrinkName.count + 1;
}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if(self.shouldShowAds && section == 1)
        return 75;
    return 0;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *ringsJson = [NSKeyedUnarchiver unarchiveObjectWithData:[[ArchiverManager sharedManager] loadDataFromDiskWithFileName:@"allJson"]];
    NSMutableDictionary *specificDrinksDictionary = [[JSONManager sharedManager] getSpecificDrinksAsDictionaryWithJSONDictionary:ringsJson andRingIndex:self.currentRing andGeneralDrinkIndex:self.currentGeneralDrink];
    
    if(indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        
        [cell.textLabel setText:[[specificDrinksDictionary allKeys] objectAtIndex:indexPath.row]];
        if([[self.specificDrinkIsShotDictionary objectForKey:[[specificDrinksDictionary allKeys] objectAtIndex:indexPath.row]] isEqualToString:@"1"])
            [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@%@ Per Shot", [specificDrinksDictionary objectForKey:[[specificDrinksDictionary allKeys] objectAtIndex:indexPath.row]], [[[JSONManager sharedManager] getRingMeasurementTypesBeforeSlashAsDictionaryWithJSONDictionary:ringsJson] objectForKey:[[[JSONManager sharedManager] getRingNamesInOrderWithJSONDictionary:ringsJson] objectAtIndex:self.currentRing]]]];
        else
            [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@%@/%@",[specificDrinksDictionary objectForKey:[[specificDrinksDictionary allKeys] objectAtIndex:indexPath.row]], [[[JSONManager sharedManager] getRingMeasurementTypesBeforeSlashAsDictionaryWithJSONDictionary:ringsJson] objectForKey:[[[JSONManager sharedManager] getRingNamesInOrderWithJSONDictionary:ringsJson] objectAtIndex:self.currentRing]], [[[JSONManager sharedManager] getRingMeasurementTypesAfterSlashAsDictionaryWithJSONDictionary:ringsJson] objectForKey:[[[JSONManager sharedManager] getRingNamesInOrderWithJSONDictionary:ringsJson] objectAtIndex:self.currentRing]]]];
        
        return cell;
    } else {
        if(indexPath.row != self.customDrinkName.count) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
            
            [cell.textLabel setText:[self.customDrinkName objectAtIndex:indexPath.row]];
            if([[self.specificDrinkIsShotDictionary objectForKey:[[specificDrinksDictionary allKeys] objectAtIndex:indexPath.row]] isEqualToString:@"1"])
                [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@%@ Per Shot", [self.customDrinkAmount objectAtIndex:indexPath.row], [[[JSONManager sharedManager] getRingMeasurementTypesBeforeSlashAsDictionaryWithJSONDictionary:ringsJson] objectForKey:[[[JSONManager sharedManager] getRingNamesInOrderWithJSONDictionary:ringsJson] objectAtIndex:self.currentRing]]]];
            else
                [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@%@/%@", [self.customDrinkAmount objectAtIndex:indexPath.row], [[[JSONManager sharedManager] getRingMeasurementTypesBeforeSlashAsDictionaryWithJSONDictionary:ringsJson] objectForKey:[[[JSONManager sharedManager] getRingNamesInOrderWithJSONDictionary:ringsJson] objectAtIndex:self.currentRing]], [[[JSONManager sharedManager] getRingMeasurementTypesAfterSlashAsDictionaryWithJSONDictionary:ringsJson] objectForKey:[[[JSONManager sharedManager] getRingNamesInOrderWithJSONDictionary:ringsJson] objectAtIndex:self.currentRing]]]];
            
            return cell;
        } else {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"customDrink" forIndexPath:indexPath];
            
            NSString *ringName = [[[JSONManager sharedManager] getRingNamesInOrderWithJSONDictionary:ringsJson] objectAtIndex:currentRing];
            [cell.textLabel setTextColor:[UIColor colorWithHex:[[[JSONManager sharedManager] getRingNamesAsDictionaryWithJSONDictionary:ringsJson] objectForKey:ringName]]];
            
            return cell;
        }
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO];
    
    if(indexPath.section == 0) {
        self.selectedSpecificDrink = indexPath.row;
        
        self.selectedSpecificDrinkName = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
        
        if([[self.specificDrinkIsShotDictionary objectForKey:self.selectedSpecificDrinkName] isEqualToString:@"1"])
            self.specificDrinkIsShot = YES;
        else
            self.specificDrinkIsShot = NO;
        
        self.amount = 0;
        
        [self performSegueWithIdentifier:@"toEntryView" sender:nil];
    } else {
        if(indexPath.row != self.customDrinkName.count) {
            self.selectedSpecificDrink = indexPath.row;
            
            self.selectedSpecificDrinkName = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
            
            if([[self.customDrinkIsShot objectAtIndex:indexPath.row] isEqualToString:@"1"])
                self.specificDrinkIsShot = YES;
            else
                self.specificDrinkIsShot = NO;
            
            self.amount = [[self.customDrinkAmount objectAtIndex:indexPath.row] doubleValue];
            
            [self performSegueWithIdentifier:@"toEntryView" sender:nil];
        } else
            [self performSegueWithIdentifier:@"toCustomDrinkViewController" sender:nil];
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55;
}

- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 1 && indexPath.row != self.customDrinkName.count)
        return YES;
    return NO;
}

- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 1 && indexPath.row != self.customDrinkName.count)
        return UITableViewCellEditingStyleDelete;
    return UITableViewCellEditingStyleNone;
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if(editingStyle == UITableViewCellEditingStyleDelete) {
        [[CDManager sharedManager] deleteCustomDrinkWithRingID:[NSString stringWithFormat:@"%ld", (long)self.currentRing] andDrinkName:[tableView cellForRowAtIndexPath:indexPath].textLabel.text];

        NSMutableArray *lel, *tempDrinkName, *tempDrinkAmount, *tempIsShot;
        NSDictionary *ringsJson = [NSKeyedUnarchiver unarchiveObjectWithData:[[ArchiverManager sharedManager] loadDataFromDiskWithFileName:@"allJson"]];
        [[CDManager sharedManager] getParsedCustomDrinksForDataArray:[[CDManager sharedManager] getDataArrayForEntityNamed:@"CustomDrink"] andFilterRingID:[NSString stringWithFormat:@"%ld",(long)self.currentRing] andFilterGeneralDrinkName:[[[JSONManager sharedManager] getGeneralDrinksAsArrayWithJSONDictionary:ringsJson andRingIndex:self.currentRing] objectAtIndex:self.currentGeneralDrink] outputRingID:&lel outputDrinkName:&tempDrinkName outputDrinkAmount:&tempDrinkAmount outputIsShot:&tempIsShot];
        
        self.customDrinkName = [tempDrinkName mutableCopy];
        self.customDrinkAmount = [tempDrinkAmount mutableCopy];
        self.customDrinkIsShot = [tempIsShot mutableCopy];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];

        [tableView beginUpdates];
        [tableView endUpdates];
    }
}

- (IBAction)editButton:(id)sender {
    if(self.tableView.isEditing) {
        [self.tableView setEditing:NO animated:YES];
        [self.editButtonOutlet setStyle:UIBarButtonItemStylePlain];
        [self.editButtonOutlet setTitle:@"Edit"];
    } else {
        [self.tableView setEditing:YES animated:YES];
        [self.editButtonOutlet setStyle:UIBarButtonItemStyleDone];
        [self.editButtonOutlet setTitle:@"Done"];
    }
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
    NSDictionary *ringsJson = [NSKeyedUnarchiver unarchiveObjectWithData:[[ArchiverManager sharedManager] loadDataFromDiskWithFileName:@"allJson"]];
    NSString *ringName = [[[JSONManager sharedManager] getRingNamesInOrderWithJSONDictionary:ringsJson] objectAtIndex:currentRing];
    
    if([[segue identifier] isEqualToString:@"toEntryView"]) {
        UINavigationController *navController = [segue destinationViewController];
        EntryViewController *entryVC = (EntryViewController *)[navController topViewController];
        [entryVC setCurrentRing:self.currentRing];
        [entryVC setCurrentGeneralDrink:self.currentGeneralDrink];
        [entryVC setCurrentSpecificDrink:self.selectedSpecificDrink];
        [entryVC setCurrentSpecificDrinkName:self.selectedSpecificDrinkName];
        [entryVC setIsShot:self.specificDrinkIsShot];
        [entryVC setAmount:self.amount];
    } else if ([[segue identifier] isEqualToString:@"toCustomDrinkViewController"]) {
        UINavigationController *navController = [segue destinationViewController];
        CustomDrinkEntryViewController *entryVC = (CustomDrinkEntryViewController *)[navController topViewController];
        [entryVC setCurrentRing:self.currentRing];
        [entryVC setCurrentGeneralDrinkName:[[[JSONManager sharedManager] getGeneralDrinksAsArrayWithJSONDictionary:ringsJson andRingIndex:self.currentRing] objectAtIndex:self.currentGeneralDrink]];
        [entryVC setCurrentRingName:ringName];
    }
}

-(IBAction)unwindToDrinksList:(UIStoryboardSegue *)segue {
    
}

@end
