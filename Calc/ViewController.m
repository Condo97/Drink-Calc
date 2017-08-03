//
//  ViewController.m
//  Calc
//
//  Created by Alex Coundouriotis on 5/15/17.
//  Copyright © 2017 ACApplications. All rights reserved.
//

#import "ViewController.h"
#import "Calc-Swift.h"
#import "RingCollectionViewCell.h"
#import "CDManager.h"
#import "HTTPManager.h"
#import "ArchiverManager.h"
#import "JSONManager.h"
#import "DrinksListTableViewCell.h"
#import "DrinksListTableViewController.h"
#import "UIColor+ColorWithHex.h"
#import "UIImage+BlurExtension.h"
#import "KFKeychain.h"
#import "RingPurchaseButton.h"
#import <HealthKit/HealthKit.h>
#import "HealthKitManager.h"
#import "LimitCalculationManager.h"
#import "EditProfileTableViewController.h"
#import "HistoryTableViewController.h"

@interface ViewController ()

@property (strong, nonatomic) NSMutableArray *ringArray, *ringLabelArray, *ringLabelShowingPercentArray, *amountSumPerRing, *limitPerRing, *ringPurchaseButtonArray;
@property (nonatomic) int currentRing;
@property (nonatomic) NSInteger selectedGeneralDrink;
@property (nonatomic) NSMutableDictionary *slideShowImages, *generalDrinkImages;
@property (strong, nonatomic) NSDictionary *purchasedRingsDictionary, *ringTexts;
@property (nonatomic) int tableViewHeight;

@end

@implementation ViewController

//Idea: home screen for rings

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[CDManager sharedManager] setupRingStore];
    
    //[[StoreKitManager sharedManager] resetKeychainForTesting];
    
    self.currentRing = 0;
    self.selectedGeneralDrink = 0;
    self.ringArray = [[NSMutableArray alloc] init];
    self.ringLabelArray = [[NSMutableArray alloc] init];
    self.ringLabelShowingPercentArray = [[NSMutableArray alloc] init];
    self.amountSumPerRing = [[NSMutableArray alloc] init];
    self.limitPerRing = [[NSMutableArray alloc] init];
    self.ringPurchaseButtonArray = [[NSMutableArray alloc] init];
    self.generalDrinkImages = [[NSMutableDictionary alloc] init];
    
//    UIGestureRecognizer *leftArrowGestureRecognizer = [[UIGestureRecognizer alloc] initWithTarget:self action:@selector(leftArrowTapped:)];
//    UIGestureRecognizer *rightArrowGestureRecognizer = [[UIGestureRecognizer alloc] initWithTarget:self action:@selector(rightArrowTapped:)];
//    [self.leftArrow addGestureRecognizer:leftArrowGestureRecognizer];
//    [self.rightArrow addGestureRecognizer:rightArrowGestureRecognizer];
    
    __block NSDictionary *ringsJson = [NSKeyedUnarchiver unarchiveObjectWithData:[[ArchiverManager sharedManager] loadDataFromDiskWithFileName:@"allJson"]];
    NSString *currentRingName = [[[JSONManager sharedManager] getRingNamesInOrderWithJSONDictionary:ringsJson] objectAtIndex:self.currentRing];
    [[UIView appearance] setTintColor:[UIColor colorWithHex:[[[JSONManager sharedManager] getRingNamesAsDictionaryWithJSONDictionary:ringsJson] objectForKey:currentRingName]]];
    NSMutableArray *generalDrinksArray = [[JSONManager sharedManager] getGeneralDrinksAsArrayWithJSONDictionary:ringsJson andRingIndex:self.currentRing];
    [self.tableViewHeightConstraint setConstant:generalDrinksArray.count * 77 + self.drinksTableView.sectionHeaderHeight + self.ringTextView.frame.size.height + self.drinksTableView.sectionFooterHeight];
    
    self.ringTexts = [[JSONManager sharedManager] getRingTextsAsDictionaryWithJSONDictionary:ringsJson];
    [self.profileButton setTitleColor:[UIColor colorWithHex:[[[JSONManager sharedManager] getRingNamesAsDictionaryWithJSONDictionary:ringsJson] objectForKey:currentRingName]] forState:UIControlStateNormal];
    [self.historyButton setTitleColor:[UIColor colorWithHex:[[[JSONManager sharedManager] getRingNamesAsDictionaryWithJSONDictionary:ringsJson] objectForKey:currentRingName]] forState:UIControlStateNormal];
    
    [self.navigationController.navigationBar.layer setMasksToBounds:NO];
    [self.navigationController.navigationBar.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.navigationController.navigationBar.layer setShadowOpacity:1.0];
    [self.navigationController.navigationBar.layer setShadowRadius:7.5];
    [self.navigationController.navigationBar.layer setShadowOffset:CGSizeMake(0, 0)];
    
    [self.tableViewBlurView.layer setMasksToBounds:NO];
    [self.tableViewBlurView.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.tableViewBlurView.layer setShadowOpacity:1.0];
    [self.tableViewBlurView.layer setShadowRadius:7.5];
    [self.tableViewBlurView.layer setShadowOffset:CGSizeMake(0, 0)];
    
    [[JSONManager sharedManager] setupScrollviewBackgroundImagesWithJSONDictionary:ringsJson withImageSize:CGSizeMake(self.view.frame.size.width, self.ringScrollView.frame.size.height)];
    
    NSArray *allRingsInOrder = [[JSONManager sharedManager] getRingNamesInOrderWithJSONDictionary:ringsJson];
    for(int i = 0; i < allRingsInOrder.count; i++) {
        [[JSONManager sharedManager] setupGeneralDrinkImagesWithJSONDictionary:ringsJson withImageSize:CGSizeMake(55, 55) andRingIndex:i];
    }
    
    [self setTitle:currentRingName];
    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor colorWithHex:[[[JSONManager sharedManager] getRingNamesAsDictionaryWithJSONDictionary:ringsJson] objectForKey:currentRingName]]];
    [self.navigationItem.rightBarButtonItem setTintColor:[UIColor colorWithHex:[[[JSONManager sharedManager] getRingNamesAsDictionaryWithJSONDictionary:ringsJson] objectForKey:currentRingName]]];
    
    NSDictionary *sliderBGImageDataDictionary = [NSKeyedUnarchiver unarchiveObjectWithData:[[ArchiverManager sharedManager] loadDataFromDiskWithFileName:@"scrollViewBGImageData"]];
    self.slideShowImages = [[JSONManager sharedManager] getImageDictionaryWithDataDictionary:sliderBGImageDataDictionary];
    for(int i = 0; i < allRingsInOrder.count; i++) {
        NSDictionary *generalDrinkDataDictionary = [NSKeyedUnarchiver unarchiveObjectWithData:[[ArchiverManager sharedManager] loadDataFromDiskWithFileName:[NSString stringWithFormat:@"generalDrinkImageDataWithRingIndex%ld", (long)i]]];
        [self.generalDrinkImages setObject:[[JSONManager sharedManager] getImageDictionaryForGeneralDrinkImagesWithDataDictionary:generalDrinkDataDictionary] forKey:[allRingsInOrder objectAtIndex:i]];
    }
    
    //Setup rings
    NSMutableDictionary *ringDictionary = [[JSONManager sharedManager] getRingNamesAsDictionaryWithJSONDictionary:ringsJson];
    NSMutableArray *ringName = [[JSONManager sharedManager] getRingNamesInOrderWithJSONDictionary:ringsJson];
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"useAutoLimit"] == nil) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"useAutoLimit"];
    }
    
    for(int i = 0; i < [ringDictionary allKeys].count; i++) {
        [self.ringArray addObject:[self createRingWithColorHex:[ringDictionary valueForKey:[ringName objectAtIndex:i]] andIndex:i]];
        [self.ringLabelArray addObject:[self createRingLabelWithRing:[self.ringArray objectAtIndex:i]]];
        [self.ringPurchaseButtonArray addObject:[self createRingPurchaseButtonWithRing:[self.ringArray objectAtIndex:i] withColorHex:[ringDictionary valueForKey:[ringName objectAtIndex:i]] andCurrentRingID:i]];
        [self.ringLabelShowingPercentArray addObject:@YES];
        
        [(UIButton *)[self.ringPurchaseButtonArray objectAtIndex:i] setEnabled:NO];
        
        [[self.ringArray objectAtIndex:i] addSubview:[self.ringLabelArray objectAtIndex:i]];
        [[self.ringArray objectAtIndex:i] addSubview:[self.ringPurchaseButtonArray objectAtIndex:i]];
        [self.ringScrollView addSubview: [self.ringArray objectAtIndex:i]];
    }
    
    [self.ringScrollView setContentSize:CGSizeMake(self.view.frame.size.width*self.ringArray.count, self.ringScrollView.frame.size.height)];
    
    self.scrollViewBackgroundView.datasource = self;
    [self.scrollViewBackgroundView setDelay:3.0];
    [self.scrollViewBackgroundView setTransitionDuration:1.5];
    [self.scrollViewBackgroundView setTransitionType:KASlideShowTransitionFade];
    
    [self.ringTextView setText:[self.ringTexts objectForKey:currentRingName]];
    
    [self.leftArrow setAlpha:0.0];
    
    [self.drinksTableView reloadData];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.scrollViewBackgroundView start];
    
    __block NSDictionary *ringsJson = [NSKeyedUnarchiver unarchiveObjectWithData:[[ArchiverManager sharedManager] loadDataFromDiskWithFileName:@"allJson"]];
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"initialSetupComplete"] == NO) {
        [self performSegueWithIdentifier:@"toInitialSetupVC" sender:nil];
    } else {
        [[HealthKitManager sharedManager] requestAuthorizationWithCompletion:^(BOOL completion){
            if(completion) {
                NSLog(@"Authorized HealthKit!");
                __block NSDictionary *equation = [[JSONManager sharedManager] getRingLimitEquationsAsDictionaryWithJSONDictionary:ringsJson];
                __block NSMutableDictionary *finalEquationDictionary = [[NSMutableDictionary alloc] init];
                
                for(int i = 0; i < [equation allKeys].count; i++) {
                    [[LimitCalculationManager sharedManager] calculateLimitWithEquation:[equation objectForKey:[[equation allKeys] objectAtIndex:i]] andRingName:[[equation allKeys] objectAtIndex:i] withCompletion:^(BOOL successful, double value, NSString *ringName){
                        [finalEquationDictionary setObject:[NSNumber numberWithDouble:value] forKey:ringName];
                    }];
                }
                
                [[NSUserDefaults standardUserDefaults] setObject:finalEquationDictionary forKey:@"userLimit"];
            } else {
                NSLog(@"HealthKit authorization didn't work dang.");
            }
        }];
    }
    
    [self animateRings];
}

- (void) animateRings {
    NSMutableArray *ringID, *amount, *timeStamp, *name;
    double limit = 0;
    
    self.purchasedRingsDictionary = [self getPurchasedRings];
    
    self.amountSumPerRing = [[NSMutableArray alloc] init];
    self.limitPerRing = [[NSMutableArray alloc] init];
    
    for(int i = 0; i < self.ringArray.count; i++) {
        NSDictionary *ringsJson = [NSKeyedUnarchiver unarchiveObjectWithData:[[ArchiverManager sharedManager] loadDataFromDiskWithFileName:@"allJson"]];
        NSString *currentRingName = [[[JSONManager sharedManager] getRingNamesInOrderWithJSONDictionary:ringsJson] objectAtIndex:i];
        
        limit = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"userLimit"] objectForKey:currentRingName] doubleValue];
        
        if([self ringIsPurchasedWithRingName:currentRingName]) {
            double amountSum = 0;
            
            [[self.ringPurchaseButtonArray objectAtIndex:i] setTitle:@"" forState:UIControlStateNormal];
            [[self.ringPurchaseButtonArray objectAtIndex:i] setEnabled:NO];
            
            [[CDManager sharedManager] getParsedRingDataForTodayForRingDataArray:[[CDManager sharedManager] getDataArrayForEntityNamed:@"Ring"] andFilterRingID:[NSString stringWithFormat:@"%d", i] outputRingID:&ringID outputAmount:&amount outputRingDateStamp:&timeStamp outputName:&name];
            
            for(NSString *currentAmount in amount)
                amountSum += [currentAmount doubleValue];
            
            [self.amountSumPerRing addObject:[NSNumber numberWithDouble:amountSum]];
            [self.limitPerRing addObject:[NSNumber numberWithDouble:limit]];
            
            [[self.ringArray objectAtIndex:i] animateToAngle:[[CDManager sharedManager] getRingAngleForAmount:amountSum andLimit:limit] duration:1.0 relativeDuration:NO completion:nil];
            
            if(![[self.ringLabelShowingPercentArray objectAtIndex:i] isEqual:@YES]) {
                if([[self.amountSumPerRing objectAtIndex:i] doubleValue] <= 9 && [[self.limitPerRing objectAtIndex:i] doubleValue] <= 9) {
                    double tempAmount = round(100 * [[self.amountSumPerRing objectAtIndex:i] doubleValue]) / 100;
                    double tempLimit = round(100 * [[self.limitPerRing objectAtIndex:i] doubleValue]) / 100;
                    [(UILabel *)[self.ringLabelArray objectAtIndex:i] setText:[NSString stringWithFormat:@"%.2f/%.2f", tempAmount, tempLimit]];
                } else if ([[self.amountSumPerRing objectAtIndex:i] doubleValue] > 9 && [[self.limitPerRing objectAtIndex:i] doubleValue] <= 9) {
                    int tempAmount = round([[self.amountSumPerRing objectAtIndex:i] doubleValue]);
                    double tempLimit = round(100 * [[self.limitPerRing objectAtIndex:i] doubleValue]) / 100;
                    [(UILabel *)[self.ringLabelArray objectAtIndex:i] setText:[NSString stringWithFormat:@"%ld/%.2f", (long)tempAmount, tempLimit]];
                } else if ([[self.amountSumPerRing objectAtIndex:i] doubleValue] <= 9 && [[self.limitPerRing objectAtIndex:i] doubleValue] > 9) {
                    double tempAmount = round(100 * [[self.amountSumPerRing objectAtIndex:i] doubleValue]) / 100;
                    int tempLimit = round([[self.limitPerRing objectAtIndex:i] doubleValue]);
                    [(UILabel *)[self.ringLabelArray objectAtIndex:i] setText:[NSString stringWithFormat:@"%.2f/%ld", tempAmount, (long)tempLimit]];
                } else {
                    int tempAmount = round([[self.amountSumPerRing objectAtIndex:i] doubleValue]);
                    int tempLimit = round([[self.limitPerRing objectAtIndex:i] doubleValue]);
                    [(UILabel *)[self.ringLabelArray objectAtIndex:i] setText:[NSString stringWithFormat:@"%ld/%ld", (long)tempAmount, (long)tempLimit]];
                }
            } else {
                int percent = 0;
                if([(NSNumber *)[self.limitPerRing objectAtIndex:i] doubleValue] != 0)
                    percent = ([(NSNumber *)[self.amountSumPerRing objectAtIndex:i] floatValue] / [(NSNumber *)[self.limitPerRing objectAtIndex:i] floatValue]) * 100;
                [(UILabel *)[self.ringLabelArray objectAtIndex:i] setText:[NSString stringWithFormat:@"%d%%", percent]];
            }
        } else {
            [(UILabel *)[self.ringLabelArray objectAtIndex:i] setText:@""];
            [self.limitPerRing addObject:@"0"];
            [self.amountSumPerRing addObject:@"0"];
            
            UIButton *currentPurchaseButton = (UIButton *)[self.ringPurchaseButtonArray objectAtIndex:i];
            [currentPurchaseButton setEnabled:YES];
            [currentPurchaseButton setTitle:@"Buy: $0.99" forState:UIControlStateNormal];
        }
    }
}

- (KDCircularProgress *) createRingWithColorHex:(NSString *)colorHex andIndex:(CGFloat)index {
    KDCircularProgress *ringView = [[KDCircularProgress alloc] initWithFrame:CGRectMake(((self.view.frame.size.width-170)/2 + (self.view.frame.size.width*index)), (self.ringScrollView.frame.size.height-150)/2, 170, 150)];
    [ringView setStartAngle:-90];
    [ringView setTrackColor:[UIColor whiteColor]];
    [ringView setProgressColors:[[NSArray alloc] initWithObjects:[[CDManager sharedManager] colorWithHexString:colorHex], nil]];
    [ringView setGlowAmount:1.0];
    [ringView setProgressInsideFillColor:[UIColor whiteColor]];
    
    [ringView.layer setMasksToBounds:NO];
    [ringView.layer setShadowColor:[UIColor blackColor].CGColor];
    [ringView.layer setShadowOpacity:1.0];
    [ringView.layer setShadowRadius:7.5];
    [ringView.layer setShadowOffset:CGSizeMake(0, 0)];
    
    UIGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedRing:)];
    [ringView addGestureRecognizer:tapRecognizer];
    
    return ringView;
}

- (UILabel *) createRingLabelWithRing:(KDCircularProgress *)ring {
    UILabel *ringLabel = [[UILabel alloc] initWithFrame:CGRectMake((ring.frame.size.width - 100) / 2, (ring.frame.size.height - 50) / 2, 100, 50)];
    [ringLabel setFont:[UIFont systemFontOfSize:27.0]];
    [ringLabel setTextAlignment:NSTextAlignmentCenter];
    [ringLabel setAdjustsFontSizeToFitWidth:YES];
    [ringLabel setMinimumScaleFactor:0.5];
    return ringLabel;
}

- (UIButton *) createRingPurchaseButtonWithRing:(KDCircularProgress *)ring withColorHex:(NSString *)colorHex andCurrentRingID:(int)currentRingID {
    RingPurchaseButton *ringPurchaseButton = [[RingPurchaseButton alloc] initWithFrame:CGRectMake((ring.frame.size.width - 100) / 2, (ring.frame.size.height - 50) / 2, 100, 50)];
    [ringPurchaseButton addTarget:self action:@selector(purchaseRingButtonPressed:) forControlEvents:UIControlEventTouchDown];
    [ringPurchaseButton setTitleColor:[[CDManager sharedManager] colorWithHexString:colorHex] forState:UIControlStateNormal];
    [ringPurchaseButton setRingNumber:currentRingID];
    return ringPurchaseButton;
}

//- (IBAction)saveToRing1Pressed:(id)sender {
//    [[CDManager sharedManager] saveRingDataWithName:@"Coffee Ring" andAmount:self.ringEntryTestField.text andLimit:self.ringEntryTestField2.text andRingIndex:0];
//    [self animateRings];
//}
//
//- (IBAction)saveToRing2Pressed:(id)sender {
//    [[CDManager sharedManager] saveRingDataWithName:@"Alcohol Ring" andAmount:self.ringEntryTestField.text andLimit:self.ringEntryTestField2.text andRingIndex:1];
//    [self animateRings];
//}

- (void) tappedRing:(id)sender {
    NSDictionary *ringsJson = [NSKeyedUnarchiver unarchiveObjectWithData:[[ArchiverManager sharedManager] loadDataFromDiskWithFileName:@"allJson"]];
    NSArray *allRingNames = [[JSONManager sharedManager] getRingNamesInOrderWithJSONDictionary:ringsJson];
    
    if([[[self getPurchasedRings] objectForKey:[allRingNames objectAtIndex:self.currentRing]] isEqualToString:@"YES"]) {
        if([[self.ringLabelShowingPercentArray objectAtIndex:self.currentRing] isEqual:@YES])
            [self.ringLabelShowingPercentArray setObject:@NO atIndexedSubscript:self.currentRing];
        else
            [self.ringLabelShowingPercentArray setObject:@YES atIndexedSubscript:self.currentRing];
        
        if(![[self.ringLabelShowingPercentArray objectAtIndex:self.currentRing] isEqual:@YES]) {
            if([[self.amountSumPerRing objectAtIndex:self.currentRing] doubleValue] <= 9 && [[self.limitPerRing objectAtIndex:self.currentRing] doubleValue] <= 9) {
                double tempAmount = round(100 * [[self.amountSumPerRing objectAtIndex:self.currentRing] doubleValue]) / 100;
                double tempLimit = round(100 * [[self.limitPerRing objectAtIndex:self.currentRing] doubleValue]) / 100;
                [(UILabel *)[self.ringLabelArray objectAtIndex:self.currentRing] setText:[NSString stringWithFormat:@"%.2f/%.2f", tempAmount, tempLimit]];
            } else if ([[self.amountSumPerRing objectAtIndex:self.currentRing] doubleValue] > 9 && [[self.limitPerRing objectAtIndex:self.currentRing] doubleValue] <= 9) {
                int tempAmount = round([[self.amountSumPerRing objectAtIndex:self.currentRing] doubleValue]);
                double tempLimit = round(100 * [[self.limitPerRing objectAtIndex:self.currentRing] doubleValue]) / 100;
                [(UILabel *)[self.ringLabelArray objectAtIndex:self.currentRing] setText:[NSString stringWithFormat:@"%ld/%.2f", (long)tempAmount, tempLimit]];
            } else if ([[self.amountSumPerRing objectAtIndex:self.currentRing] doubleValue] <= 9 && [[self.limitPerRing objectAtIndex:self.currentRing] doubleValue] > 9) {
                double tempAmount = round(100 * [[self.amountSumPerRing objectAtIndex:self.currentRing] doubleValue]) / 100;
                int tempLimit = round([[self.limitPerRing objectAtIndex:self.currentRing] doubleValue]);
                [(UILabel *)[self.ringLabelArray objectAtIndex:self.currentRing] setText:[NSString stringWithFormat:@"%.2f/%ld", tempAmount, (long)tempLimit]];
            } else {
                int tempAmount = round([[self.amountSumPerRing objectAtIndex:self.currentRing] doubleValue]);
                int tempLimit = round([[self.limitPerRing objectAtIndex:self.currentRing] doubleValue]);
                [(UILabel *)[self.ringLabelArray objectAtIndex:self.currentRing] setText:[NSString stringWithFormat:@"%ld/%ld", (long)tempAmount, (long)tempLimit]];
            }
        } else {
            int percent = 0;
            if([(NSNumber *)[self.limitPerRing objectAtIndex:self.currentRing] doubleValue] != 0)
                percent = ([(NSNumber *)[self.amountSumPerRing objectAtIndex:self.currentRing] floatValue] / [(NSNumber *)[self.limitPerRing objectAtIndex:self.currentRing] floatValue]) * 100;
            [(UILabel *)[self.ringLabelArray objectAtIndex:self.currentRing] setText:[NSString stringWithFormat:@"%d%%", percent]];
        }
    }
}

- (NSDictionary *) getPurchasedRings {
    NSMutableDictionary *purchasedRings = [[NSMutableDictionary alloc] init];
    NSDictionary *ringsJson = [NSKeyedUnarchiver unarchiveObjectWithData:[[ArchiverManager sharedManager] loadDataFromDiskWithFileName:@"allJson"]];
    NSArray *allRingNames = [[JSONManager sharedManager] getRingNamesInOrderWithJSONDictionary:ringsJson];
    NSDictionary *productIDs = [[JSONManager sharedManager] getRingIAPIDsAsDictionaryWithJSONDictionary:ringsJson];
    
    for(NSString *ringName in allRingNames) {
        NSString *currentProductID = [productIDs objectForKey:ringName];
        if(![currentProductID isEqual:[NSNull null]]) {
            NSString *purchased = [KFKeychain loadObjectForKey:[NSString stringWithFormat:@"%@Purchased", currentProductID]];
            
            if(purchased != nil)
                [purchasedRings setObject:purchased forKey:ringName];
            else
                [purchasedRings setObject:@"NO" forKey:ringName];
        } else {
            [purchasedRings setObject:@"YES" forKey:ringName];
        }
    }
    
    return purchasedRings;
}

- (BOOL) ringIsPurchasedWithRingName:(NSString *)ringName {
    return ([[self.purchasedRingsDictionary objectForKey:ringName] isEqualToString:@"YES"]);
}

- (void) purchaseRingButtonPressed:(id)sender {
    RingPurchaseButton *currentButton = (RingPurchaseButton *)sender;
    
    NSDictionary *ringsJson = [NSKeyedUnarchiver unarchiveObjectWithData:[[ArchiverManager sharedManager] loadDataFromDiskWithFileName:@"allJson"]];
    NSString *currentRingName = [[[JSONManager sharedManager] getRingNamesInOrderWithJSONDictionary:ringsJson] objectAtIndex:[currentButton ringNumber]];
    
    UIAlertController *buyConformationAlert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"Buy %@", currentRingName] message:[NSString stringWithFormat:@"Are you sure you want to buy %@?", currentRingName] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *buyButton = [UIAlertAction actionWithTitle:@"Buy" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        StoreKitManager *skManager = [StoreKitManager sharedManager];
        [skManager setDelegate:self];
        [skManager purchaseRingWithRingID:[currentButton ringNumber]];
    }];
    UIAlertAction *cancelButton = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    [buyConformationAlert addAction:buyButton];
    [buyConformationAlert addAction:cancelButton];
    [self presentViewController:buyConformationAlert animated:YES completion:nil];
}

#pragma mark - TableView stuff yay

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDictionary *ringsJson = [NSKeyedUnarchiver unarchiveObjectWithData:[[ArchiverManager sharedManager] loadDataFromDiskWithFileName:@"allJson"]];
    NSMutableArray *generalDrinksArray = [[JSONManager sharedManager] getGeneralDrinksAsArrayWithJSONDictionary:ringsJson andRingIndex:self.currentRing];
    return generalDrinksArray.count;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 77;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DrinksListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"drinksListCell"];
    
    NSDictionary *ringsJson = [NSKeyedUnarchiver unarchiveObjectWithData:[[ArchiverManager sharedManager] loadDataFromDiskWithFileName:@"allJson"]];
    NSMutableArray *generalDrinksArray = [[JSONManager sharedManager] getGeneralDrinksAsArrayWithJSONDictionary:ringsJson andRingIndex:self.currentRing]; //TODO fix ring index
    NSArray *allRingNames = [[JSONManager sharedManager] getRingNamesInOrderWithJSONDictionary:ringsJson];
    
    [cell.cellText setText:[generalDrinksArray objectAtIndex:indexPath.row]];
    [cell.cellImage setImage:[[self.generalDrinkImages objectForKey:[allRingNames objectAtIndex:self.currentRing]] objectForKey:[generalDrinksArray objectAtIndex:indexPath.row]]];
    
    if([[[self getPurchasedRings] objectForKey:[allRingNames objectAtIndex:self.currentRing]] isEqualToString:@"NO"]) {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        [tableView setAllowsSelection:NO];
    } else {
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        [tableView setAllowsSelection:YES];
    }
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO];
    
    self.selectedGeneralDrink = indexPath.row;
    [self performSegueWithIdentifier:@"toDrinksListView" sender:nil];
}

#pragma mark - ScrollView stuff

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    int pageWidth = scrollView.frame.size.width;
    int theCurrentRing = floor((scrollView.contentOffset.x - pageWidth/2)/pageWidth)+1;
    
    if(theCurrentRing != self.currentRing) {
        [self.drinksTableView setAllowsSelection:YES];
        
        self.currentRing = theCurrentRing;
        
        NSDictionary *json = [NSKeyedUnarchiver unarchiveObjectWithData:[[ArchiverManager sharedManager] loadDataFromDiskWithFileName:@"allJson"]];
        NSArray *allRingNamesInOrder = [[JSONManager sharedManager] getRingNamesInOrderWithJSONDictionary:json];
        NSString *currentRingName = [[[JSONManager sharedManager] getRingNamesInOrderWithJSONDictionary:json] objectAtIndex:self.currentRing];
        [[UIView appearance] setTintColor:[UIColor colorWithHex:[[[JSONManager sharedManager] getRingNamesAsDictionaryWithJSONDictionary:json] objectForKey:currentRingName]]];
        NSMutableArray *generalDrinksArray = [[JSONManager sharedManager] getGeneralDrinksAsArrayWithJSONDictionary:json andRingIndex:self.currentRing];
        
        if([[[self getPurchasedRings] objectForKey:[allRingNamesInOrder objectAtIndex:self.currentRing]] isEqualToString:@"NO"])
            [self.tableViewHeightConstraint setConstant:generalDrinksArray.count * 77 + self.drinksTableView.sectionHeaderHeight + self.ringTextView.frame.size.height + self.drinksTableView.sectionFooterHeight + 35];
        else
            [self.tableViewHeightConstraint setConstant:generalDrinksArray.count * 77 + self.drinksTableView.sectionHeaderHeight + self.ringTextView.frame.size.height + self.drinksTableView.sectionFooterHeight];
        
        [self setTitle:currentRingName];
        [self.ringTextView setText:[self.ringTexts objectForKey:currentRingName]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.profileButton setTitleColor:[UIColor colorWithHex:[[[JSONManager sharedManager] getRingNamesAsDictionaryWithJSONDictionary:json] objectForKey:currentRingName]] forState:UIControlStateNormal];
            [self.historyButton setTitleColor:[UIColor colorWithHex:[[[JSONManager sharedManager] getRingNamesAsDictionaryWithJSONDictionary:json] objectForKey:currentRingName]] forState:UIControlStateNormal];
        });
        
        [self.scrollViewBackgroundView next];
        
        if(self.currentRing == 0) {
            [UIView animateWithDuration:0.25 animations:^{
                [self.leftArrow setAlpha:0.0];
                [self.rightArrow setAlpha:1.0];
            }];
        } else if (self.currentRing == allRingNamesInOrder.count - 1) {
            [UIView animateWithDuration:0.25 animations:^{
                [self.rightArrow setAlpha:0.0];
                [self.leftArrow setAlpha:1.0];
            }];
        } else {
            [UIView animateWithDuration:0.25 animations:^{
                [self.rightArrow setAlpha:1.0];
                [self.leftArrow setAlpha:1.0];
            }];
        }
        
        [self.drinksTableView reloadData];
    }
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSDictionary *ringsJson = [NSKeyedUnarchiver unarchiveObjectWithData:[[ArchiverManager sharedManager] loadDataFromDiskWithFileName:@"allJson"]];
    NSArray *allRingNames = [[JSONManager sharedManager] getRingNamesInOrderWithJSONDictionary:ringsJson];
    
    if([[[self getPurchasedRings] objectForKey:[allRingNames objectAtIndex:self.currentRing]] isEqualToString:@"NO"])
        return @"Preview:";
    return @"";
}

#pragma mark - Segue handler

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([[segue identifier] isEqualToString:@"toDrinksListView"]) {
        DrinksListTableViewController *drinksListTVC = [segue destinationViewController];
        [drinksListTVC setCurrentRing:self.currentRing];
        [drinksListTVC setCurrentGeneralDrink:self.selectedGeneralDrink];
    } else if ([[segue identifier] isEqualToString:@"toEditProfileVC"]) {
        UINavigationController *navController = segue.destinationViewController;
        EditProfileTableViewController *editProfileTableViewController = (EditProfileTableViewController *)navController.topViewController;
        NSDictionary *ringsJson = [NSKeyedUnarchiver unarchiveObjectWithData:[[ArchiverManager sharedManager] loadDataFromDiskWithFileName:@"allJson"]];
        [editProfileTableViewController setCurrentRingName:[[[JSONManager sharedManager] getRingNamesInOrderWithJSONDictionary:ringsJson] objectAtIndex:self.currentRing]];
    } else if ([[segue identifier] isEqualToString:@"toHistoryVC"]) {
        UINavigationController *navController = segue.destinationViewController;
        HistoryTableViewController *historyTableViewController = (HistoryTableViewController *)navController.topViewController;
        NSDictionary *ringsJson = [NSKeyedUnarchiver unarchiveObjectWithData:[[ArchiverManager sharedManager] loadDataFromDiskWithFileName:@"allJson"]];
        [historyTableViewController setCurrentRingName:[[[JSONManager sharedManager] getRingNamesInOrderWithJSONDictionary:ringsJson] objectAtIndex:self.currentRing]];
        [historyTableViewController setCurrentRingID:self.currentRing];
    }
}
    
- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction) unwindToHome:(UIStoryboardSegue *)segue {
}

#pragma mark - Slideshow stuff

- (NSObject *) slideShow:(KASlideShow *)slideShow objectAtIndex:(NSUInteger)index {
    NSDictionary *ringsJson = [NSKeyedUnarchiver unarchiveObjectWithData:[[ArchiverManager sharedManager] loadDataFromDiskWithFileName:@"allJson"]];
    NSString *currentRingName = [[[JSONManager sharedManager] getRingNamesInOrderWithJSONDictionary:ringsJson] objectAtIndex:self.currentRing];
    
    return [[self.slideShowImages mutableArrayValueForKey:currentRingName] objectAtIndex:index];
}

- (NSUInteger) slideShowImagesNumber:(KASlideShow *)slideShow {
    NSDictionary *ringsJson = [NSKeyedUnarchiver unarchiveObjectWithData:[[ArchiverManager sharedManager] loadDataFromDiskWithFileName:@"allJson"]];
    NSString *currentRingName = [[[JSONManager sharedManager] getRingNamesInOrderWithJSONDictionary:ringsJson] objectAtIndex:self.currentRing];
    
    return [self.slideShowImages mutableArrayValueForKey:currentRingName].count;
}

- (void) encodeWithCoder:(nonnull NSCoder *)aCoder {
}

- (void) traitCollectionDidChange:(nullable UITraitCollection *)previousTraitCollection {
}

- (void) preferredContentSizeDidChangeForChildContentContainer:(nonnull id<UIContentContainer>)container {
}

- (void) systemLayoutFittingSizeDidChangeForChildContentContainer:(nonnull id<UIContentContainer>)container {
}

- (void) viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(nonnull id<UIViewControllerTransitionCoordinator>)coordinator {
}

- (void) willTransitionToTraitCollection:(nonnull UITraitCollection *)newCollection withTransitionCoordinator:(nonnull id<UIViewControllerTransitionCoordinator>)coordinator {
}

- (void) didUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context withAnimationCoordinator:(nonnull UIFocusAnimationCoordinator *)coordinator {
}

- (void) setNeedsFocusUpdate {
}

- (void) updateFocusIfNeeded {
}

- (void) purchaseSuccessful {
    [self animateRings];
    [self.drinksTableView reloadData];
}

- (void) purchaseUnsuccessful {
}

@end
