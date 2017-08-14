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
@import GoogleMobileAds;

@interface DrinksListTableViewController ()

@property (nonatomic) NSInteger selectedSpecificDrink;
@property (strong, nonatomic) NSString *selectedSpecificDrinkName;
@property (nonatomic) BOOL specificDrinkIsShot, shouldShowAds;
@property (strong, nonatomic) NSDictionary *specificDrinkIsShotDictionary;
@property (strong, nonatomic) GADBannerView *bannerAd;

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

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if(self.shouldShowAds)
        return 75;
    return 0;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    NSDictionary *ringsJson = [NSKeyedUnarchiver unarchiveObjectWithData:[[ArchiverManager sharedManager] loadDataFromDiskWithFileName:@"allJson"]];
    NSMutableDictionary *specificDrinksDictionary = [[JSONManager sharedManager] getSpecificDrinksAsDictionaryWithJSONDictionary:ringsJson andRingIndex:self.currentRing andGeneralDrinkIndex:self.currentGeneralDrink];
    
    [cell.textLabel setText:[[specificDrinksDictionary allKeys] objectAtIndex:indexPath.row]];
    if([[self.specificDrinkIsShotDictionary objectForKey:[[specificDrinksDictionary allKeys] objectAtIndex:indexPath.row]] isEqualToString:@"1"])
        [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@%@ Per Shot",[specificDrinksDictionary objectForKey:[[specificDrinksDictionary allKeys] objectAtIndex:indexPath.row]], [[[JSONManager sharedManager] getRingMeasurementTypesBeforeSlashAsDictionaryWithJSONDictionary:ringsJson] objectForKey:[[[JSONManager sharedManager] getRingNamesInOrderWithJSONDictionary:ringsJson] objectAtIndex:self.currentRing]]]];
    else
        [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@%@/%@",[specificDrinksDictionary objectForKey:[[specificDrinksDictionary allKeys] objectAtIndex:indexPath.row]], [[[JSONManager sharedManager] getRingMeasurementTypesBeforeSlashAsDictionaryWithJSONDictionary:ringsJson] objectForKey:[[[JSONManager sharedManager] getRingNamesInOrderWithJSONDictionary:ringsJson] objectAtIndex:self.currentRing]], [[[JSONManager sharedManager] getRingMeasurementTypesAfterSlashAsDictionaryWithJSONDictionary:ringsJson] objectForKey:[[[JSONManager sharedManager] getRingNamesInOrderWithJSONDictionary:ringsJson] objectAtIndex:self.currentRing]]]];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO];
    
    self.selectedSpecificDrink = indexPath.row;
    
    self.selectedSpecificDrinkName = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
    
    if([[self.specificDrinkIsShotDictionary objectForKey:self.selectedSpecificDrinkName] isEqualToString:@"1"])
        self.specificDrinkIsShot = YES;
    else
        self.specificDrinkIsShot = NO;
    
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
        [entryVC setIsShot:self.specificDrinkIsShot];
    }
}

-(IBAction)unwindToDrinksList:(UIStoryboardSegue *)segue {
    
}

@end
