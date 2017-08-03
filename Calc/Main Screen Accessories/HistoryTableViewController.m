//
//  HistoryTableViewController.m
//  Calc
//
//  Created by Alex Coundouriotis on 7/23/17.
//  Copyright © 2017 ACApplications. All rights reserved.
//

#import "HistoryTableViewController.h"
#import "CDManager.h"
#import "HistoryHeaderTableViewCell.h"
#import "HistoryStandardTableViewCell.h"
#import "ArchiverManager.h"
#import "JSONManager.h"
#import "Calc-Swift.h"

@interface HistoryTableViewController ()

@property (strong, nonatomic) NSDictionary *allAmountsForCurrentRing;
@property (strong, nonatomic) NSMutableArray *allAmountsSplitIntoSections, *ringDataArray;
@property (strong, nonatomic) NSString *units;
@property (strong, nonatomic) UIColor *currentColor;
@property (nonatomic) double limit;
@property (nonatomic) BOOL noCellsExistSections;
@property (nonatomic) BOOL noCellsExistCells;

@end

@implementation HistoryTableViewController

@synthesize currentRingName, currentRingID;

- (void) viewDidLoad {
    [super viewDidLoad];
    
    [self loadAllAmountsSplitIntoSectionsArray];
    
    if(self.allAmountsSplitIntoSections.count == 0) {
        self.noCellsExistSections = YES;
        self.noCellsExistCells = YES;
    } else {
        self.noCellsExistSections = NO;
        self.noCellsExistCells = NO;
    }
    
    [self.tableView reloadData];
}

- (void) loadAllAmountsSplitIntoSectionsArray {
    NSMutableArray *differentDatesArray = [[NSMutableArray alloc] init];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDictionary *json = [NSKeyedUnarchiver unarchiveObjectWithData:[[ArchiverManager sharedManager] loadDataFromDiskWithFileName:@"allJson"]];
    self.units = [[[JSONManager sharedManager] getRingMeasurementTypesBeforeSlashAsDictionaryWithJSONDictionary:json] objectForKey:currentRingName];
    self.limit = [(NSNumber *)[(NSDictionary *)[[NSUserDefaults standardUserDefaults] objectForKey:@"userLimit"] objectForKey:currentRingName] doubleValue];
    self.currentColor = [[CDManager sharedManager] colorWithHexString:[[[JSONManager sharedManager] getRingNamesAsDictionaryWithJSONDictionary:json] objectForKey:currentRingName]];
    
    self.ringDataArray = (NSMutableArray *)[[CDManager sharedManager] getDataArrayForEntityNamed:@"Ring"];
    self.allAmountsSplitIntoSections = [[NSMutableArray alloc] init];
    self.allAmountsForCurrentRing = [[CDManager sharedManager] getAllRingDataWithRingDataArray:self.ringDataArray andFilterRingID:[NSString stringWithFormat:@"%ld", (long)currentRingID]];
    
    [self setTitle:[NSString stringWithFormat:@"%@ History", currentRingName]];
    
    for(int i = 0; i < [self.allAmountsForCurrentRing allKeys].count; i++) {
        NSDateComponents *tempDateComponents = [calendar componentsInTimeZone:[NSTimeZone systemTimeZone] fromDate:[[self.allAmountsForCurrentRing allKeys] objectAtIndex:i]];
        
        NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
        [dateComponents setYear:tempDateComponents.year];
        [dateComponents setMonth:tempDateComponents.month];
        [dateComponents setDay:tempDateComponents.day];
        
        if(![differentDatesArray containsObject:dateComponents])
            [differentDatesArray addObject:dateComponents];//[differentDatesArray addObject:[[self.allAmountsForCurrentRing allKeys] objectAtIndex:i]];
    }
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    for(int i = 0; i < differentDatesArray.count; i++) {
        NSMutableArray *moreTempArrayDate = [[NSMutableArray alloc] init];
        NSMutableArray *moreTempArrayValue = [[NSMutableArray alloc] init];
        
        for(int j = 0; j < [self.allAmountsForCurrentRing allKeys].count; j++) {
            NSDateComponents *tempDateComponents = [calendar componentsInTimeZone:[NSTimeZone systemTimeZone] fromDate:[[self.allAmountsForCurrentRing allKeys] objectAtIndex:j]];
            NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
            [dateComponents setYear:tempDateComponents.year];
            [dateComponents setMonth:tempDateComponents.month];
            [dateComponents setDay:tempDateComponents.day];
            
            if([[differentDatesArray objectAtIndex:i] isEqual:dateComponents]) {
                NSDateComponents *tempComponents = [calendar componentsInTimeZone:[NSTimeZone systemTimeZone] fromDate:[[self.allAmountsForCurrentRing allKeys] objectAtIndex:j]];
                [tempComponents setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
                [moreTempArrayDate addObject:[calendar dateFromComponents:tempComponents]];
                [moreTempArrayValue addObject:[self.allAmountsForCurrentRing objectForKey:[[self.allAmountsForCurrentRing allKeys] objectAtIndex:j]]];
            }
        }
        
        NSMutableArray *moreTempArray = [[NSMutableArray alloc] init];
        for(int i = 0; i < moreTempArrayValue.count; i++) {
            NSMutableDictionary *tempDicts = [[NSMutableDictionary alloc] init];
            [tempDicts setObject:[moreTempArrayValue objectAtIndex:i] forKey:@"value"];
            [tempDicts setObject:[moreTempArrayDate objectAtIndex:i] forKey:@"date"];
            [moreTempArray addObject:tempDicts];
        }
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
        NSMutableArray *finalTempArray = (NSMutableArray *)[moreTempArray sortedArrayUsingDescriptors:[NSMutableArray arrayWithObject:sortDescriptor]];
        finalTempArray = (NSMutableArray *)[[finalTempArray reverseObjectEnumerator] allObjects];
        [tempArray addObject:finalTempArray];
    }
    
    int k;
    for(int i = 1; i < tempArray.count; i++) {
        k = i;
        
        while(k > 0 && [[self getDayForArray:[tempArray objectAtIndex:(k-1)]] compare:[self getDayForArray:[tempArray objectAtIndex:k]]] == NSOrderedAscending) {
            [tempArray exchangeObjectAtIndex:k withObjectAtIndex:(k-1)];
            k--;
        }
    }
    
    self.allAmountsSplitIntoSections = tempArray;//(NSMutableArray *)[[tempArray reverseObjectEnumerator] allObjects];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSDate *) getDayForArray:(NSArray *)array {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:[[array objectAtIndex:0] valueForKey:@"date"]];
    return [calendar dateFromComponents:dateComponents];
}

#pragma mark - Table view data source

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    if(self.noCellsExistSections)
        return 1;
    return self.allAmountsSplitIntoSections.count;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(self.noCellsExistCells)
        return 1;
    if(self.noCellsExistSections)
        return 0;
    return [(NSArray *)[self.allAmountsSplitIntoSections objectAtIndex:section] count] + 1;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(self.noCellsExistSections)
        return @"";
    return [NSDateFormatter localizedStringFromDate:(NSDate *)[self getDayForArray:[self.allAmountsSplitIntoSections objectAtIndex:section]] dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.noCellsExistSections && self.noCellsExistCells)
        return [tableView dequeueReusableCellWithIdentifier:@"noDisplayCell" forIndexPath:indexPath];
    
    if(indexPath.row == 0) {
        HistoryHeaderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"headerCell" forIndexPath:indexPath];
        //[cell.circularProgressLabel setFrame:CGRectMake((cell.circularProgress.frame.size.width - 100) / 2, (cell.circularProgress.frame.size.height - 50) / 2, 100, 50)];
        double totalConsumed = 0;
        
        for(int i = 0; i < [(NSArray *)[self.allAmountsSplitIntoSections objectAtIndex:indexPath.section] count]; i++) {
            totalConsumed += [[[[self.allAmountsSplitIntoSections objectAtIndex:indexPath.section] objectAtIndex:i] objectForKey:@"value"] doubleValue];
        }
        
        NSString *originalString = [[NSString alloc] init];
        NSMutableAttributedString *headerLabelText = [[NSMutableAttributedString alloc] init];
        if(self.view.frame.size.width <= 320) {
            if(totalConsumed <= 9 && self.limit <= 9) {
                double tempTotalConsumed = round(100 * totalConsumed) / 100;
                double tempLimit = round(100 * self.limit) / 100;
                originalString = [NSString stringWithFormat:@"You have\ndrank %.2f%@\nout of %.2f%@.", tempTotalConsumed, self.units, tempLimit, self.units];
                
                headerLabelText = [[NSMutableAttributedString alloc] initWithString:originalString];
                [headerLabelText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17.0 weight:UIFontWeightSemibold] range:[originalString rangeOfString:[NSString stringWithFormat:@"%.2f%@", tempTotalConsumed, self.units]]];
                if(totalConsumed > (self.limit * 0.90))
                    [headerLabelText addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:[originalString rangeOfString:[NSString stringWithFormat:@"%.2f%@", tempTotalConsumed, self.units]]];
                [headerLabelText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17.0 weight:UIFontWeightSemibold] range:[originalString rangeOfString:[NSString stringWithFormat:@"%.2f%@", tempLimit, self.units]]];
            } else if (totalConsumed <= 9 && self.limit > 9) {
                double tempTotalConsumed = round(100 * totalConsumed) / 100;
                int tempLimit = round(self.limit);
                originalString = [NSString stringWithFormat:@"You have\ndrank %.2f%@\nout of %ld%@.", tempTotalConsumed, self.units, (long)tempLimit, self.units];
                
                headerLabelText = [[NSMutableAttributedString alloc] initWithString:originalString];
                [headerLabelText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17.0 weight:UIFontWeightSemibold] range:[originalString rangeOfString:[NSString stringWithFormat:@"%.2f%@", tempTotalConsumed, self.units]]];
                if(totalConsumed > (self.limit * 0.90))
                    [headerLabelText addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:[originalString rangeOfString:[NSString stringWithFormat:@"%.2f%@", tempTotalConsumed, self.units]]];
                [headerLabelText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17.0 weight:UIFontWeightSemibold] range:[originalString rangeOfString:[NSString stringWithFormat:@"%ldf%@", (long)tempLimit, self.units]]];
            } else if (totalConsumed > 9 && self.limit <= 9) {
                int tempTotalConsumed = round(totalConsumed);
                double tempLimit = round(100 * self.limit) / 100;
                originalString = [NSString stringWithFormat:@"You have\ndrank %ld%@\nout of %.2f%@.", (long)tempTotalConsumed, self.units, tempLimit, self.units];
                
                headerLabelText = [[NSMutableAttributedString alloc] initWithString:originalString];
                [headerLabelText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17.0 weight:UIFontWeightSemibold] range:[originalString rangeOfString:[NSString stringWithFormat:@"%ld%@", (long)tempTotalConsumed, self.units]]];
                if(totalConsumed > (self.limit * 0.90))
                    [headerLabelText addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:[originalString rangeOfString:[NSString stringWithFormat:@"%ld%@", (long)tempTotalConsumed, self.units]]];
                [headerLabelText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17.0 weight:UIFontWeightSemibold] range:[originalString rangeOfString:[NSString stringWithFormat:@"%.2f%@", tempLimit, self.units]]];
            } else {
                int tempTotalConsumed = round(totalConsumed);
                int tempLimit = round(self.limit);
                originalString = [NSString stringWithFormat:@"You have\ndrank %ld%@\nout of %ld%@.", (long)tempTotalConsumed, self.units, (long)tempLimit, self.units];
                
                headerLabelText = [[NSMutableAttributedString alloc] initWithString:originalString];
                [headerLabelText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17.0 weight:UIFontWeightSemibold] range:[originalString rangeOfString:[NSString stringWithFormat:@"%ld%@", (long)tempTotalConsumed, self.units]]];
                if(totalConsumed > (self.limit * 0.90))
                    [headerLabelText addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:[originalString rangeOfString:[NSString stringWithFormat:@"%ld%@", (long)tempTotalConsumed, self.units]]];
                [headerLabelText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17.0 weight:UIFontWeightSemibold] range:[originalString rangeOfString:[NSString stringWithFormat:@"%ld%@", (long)tempLimit, self.units]]];
            }
        } else {
            if(totalConsumed <= 9 && self.limit <= 9) {
                double tempTotalConsumed = round(100 * totalConsumed) / 100;
                double tempLimit = round(100 * self.limit) / 100;
                originalString = [NSString stringWithFormat:@"You have drank %.2f%@\nout of %.2f%@.", tempTotalConsumed, self.units, tempLimit, self.units];
                
                headerLabelText = [[NSMutableAttributedString alloc] initWithString:originalString];
                [headerLabelText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17.0 weight:UIFontWeightSemibold] range:[originalString rangeOfString:[NSString stringWithFormat:@"%.2f%@", tempTotalConsumed, self.units]]];
                if(totalConsumed > (self.limit * 0.90))
                    [headerLabelText addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:[originalString rangeOfString:[NSString stringWithFormat:@"%.2f%@", tempTotalConsumed, self.units]]];
                [headerLabelText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17.0 weight:UIFontWeightSemibold] range:[originalString rangeOfString:[NSString stringWithFormat:@"%.2f%@", tempLimit, self.units]]];
            } else if (totalConsumed <= 9 && self.limit > 9) {
                double tempTotalConsumed = round(100 * totalConsumed) / 100;
                int tempLimit = round(self.limit);
                originalString = [NSString stringWithFormat:@"You have drank %.2f%@\nout of %ld%@.", tempTotalConsumed, self.units, (long)tempLimit, self.units];
                
                headerLabelText = [[NSMutableAttributedString alloc] initWithString:originalString];
                [headerLabelText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17.0 weight:UIFontWeightSemibold] range:[originalString rangeOfString:[NSString stringWithFormat:@"%.2f%@", tempTotalConsumed, self.units]]];
                if(totalConsumed > (self.limit * 0.90))
                    [headerLabelText addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:[originalString rangeOfString:[NSString stringWithFormat:@"%.2f%@", tempTotalConsumed, self.units]]];
                [headerLabelText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17.0 weight:UIFontWeightSemibold] range:[originalString rangeOfString:[NSString stringWithFormat:@"%ldf%@", (long)tempLimit, self.units]]];
            } else if (totalConsumed > 9 && self.limit <= 9) {
                int tempTotalConsumed = round(totalConsumed);
                double tempLimit = round(100 * self.limit) / 100;
                originalString = [NSString stringWithFormat:@"You have drank %ld%@\nout of %.2f%@.", (long)tempTotalConsumed, self.units, tempLimit, self.units];
                
                headerLabelText = [[NSMutableAttributedString alloc] initWithString:originalString];
                [headerLabelText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17.0 weight:UIFontWeightSemibold] range:[originalString rangeOfString:[NSString stringWithFormat:@"%ld%@", (long)tempTotalConsumed, self.units]]];
                if(totalConsumed > (self.limit * 0.90))
                    [headerLabelText addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:[originalString rangeOfString:[NSString stringWithFormat:@"%ld%@", (long)tempTotalConsumed, self.units]]];
                [headerLabelText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17.0 weight:UIFontWeightSemibold] range:[originalString rangeOfString:[NSString stringWithFormat:@"%.2f%@", tempLimit, self.units]]];
            } else {
                int tempTotalConsumed = round(totalConsumed);
                int tempLimit = round(self.limit);
                originalString = [NSString stringWithFormat:@"You have drank %ld%@\nout of %ld%@.", (long)tempTotalConsumed, self.units, (long)tempLimit, self.units];
                
                headerLabelText = [[NSMutableAttributedString alloc] initWithString:originalString];
                [headerLabelText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17.0 weight:UIFontWeightSemibold] range:[originalString rangeOfString:[NSString stringWithFormat:@"%ld%@", (long)tempTotalConsumed, self.units]]];
                if(totalConsumed > (self.limit * 0.90))
                    [headerLabelText addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:[originalString rangeOfString:[NSString stringWithFormat:@"%ld%@", (long)tempTotalConsumed, self.units]]];
                [headerLabelText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17.0 weight:UIFontWeightSemibold] range:[originalString rangeOfString:[NSString stringWithFormat:@"%ld%@", (long)tempLimit, self.units]]];
            }
        }
        
        [cell.circularProgress setStartAngle:-90];
        [cell.circularProgress setTrackColor:[UIColor whiteColor]];
        [cell.circularProgress setProgressColors:[NSArray arrayWithObject:self.currentColor]];
        [cell.circularProgress setGlowAmount:1.0];
        [cell.circularProgress setProgressInsideFillColor:[UIColor whiteColor]];
        
        [cell.circularProgress.layer setMasksToBounds:NO];
        [cell.circularProgress.layer setShadowColor:[UIColor blackColor].CGColor];
        [cell.circularProgress.layer setShadowOpacity:1.0];
        [cell.circularProgress.layer setShadowRadius:7.5];
        [cell.circularProgress.layer setShadowOffset:CGSizeMake(0, 0)];
        
        [cell.circularProgressLabel setFont:[UIFont systemFontOfSize:17.0]];
        [cell.circularProgressLabel setTextAlignment:NSTextAlignmentCenter];
        [cell.circularProgressLabel setAdjustsFontSizeToFitWidth:YES];
        [cell.circularProgressLabel setMinimumScaleFactor:0.5];
        
        if(cell.circularProgressLabel.numberOfLines > 2) {
            
        }
        
        
        
        int ringAngle = 0;
        double percent = 0;
        
        if(self.limit != 0) {
            ringAngle = [[CDManager sharedManager] getRingAngleForAmount:totalConsumed andLimit:self.limit];
            percent = ((double)totalConsumed/(double)self.limit) * 100.0;
        }
        
        [cell.circularProgressLabel setText:[NSString stringWithFormat:@"%ld%%", (long)percent]];
        //[cell.circularProgress addSubview:cell.circularProgressLabel];
        [cell.circularProgress animateToAngle:ringAngle duration:1.0 relativeDuration:NO completion:nil];
        
        [cell.label setAttributedText:headerLabelText];
        
        return cell;
    }
    
    HistoryStandardTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"standardCell" forIndexPath:indexPath];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *tempDate = (NSDate *)[[[self.allAmountsSplitIntoSections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row - 1] objectForKey:@"date"];
    NSDateComponents *tempDateComponents = [calendar componentsInTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"] fromDate:tempDate];
    NSString *hour = [NSString stringWithFormat:@"%ld", (long)tempDateComponents.hour];
    NSString *minute = [NSString stringWithFormat:@"%ld", (long)tempDateComponents.minute];
    NSString *pmOrAm = @"AM";
    
    if(tempDateComponents.hour >= 12) {
        pmOrAm = @"PM";
        
        if(tempDateComponents.hour != 12)
            hour = [NSString stringWithFormat:@"%ld", (long)tempDateComponents.hour - 12];
    } else if(tempDateComponents.hour == 0) {
        hour = @"12";
    }
    
    if(tempDateComponents.minute <= 9) {
        minute = [NSString stringWithFormat:@"%ld0", (long)tempDateComponents.minute];
    }
    
    double amount = [[[[self.allAmountsSplitIntoSections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row - 1] objectForKey:@"value"] doubleValue];
    
    [cell.headerLabel setText:[[CDManager sharedManager] getDrinkNameWithRingDataArray:self.ringDataArray andRingID:[NSString stringWithFormat:@"%ld", (long)self.currentRingID] andDateStamp:tempDate]];
    [cell.subtitleLabel setText:[NSString stringWithFormat:@"%@:%@ %@", hour, minute, pmOrAm]];
    
    if(amount <= 9) {
        amount = round(100 * amount) / 100;
        [cell.detailLabel setText:[NSString stringWithFormat:@"%.2f%@", amount, self.units]];
    } else {
        int intAmount = round(amount);
        [cell.detailLabel setText:[NSString stringWithFormat:@"%ld%@", (long)intAmount, self.units]];
    }
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.noCellsExistCells && self.noCellsExistSections)
        return 55;
    if(indexPath.row == 0)
        return 120;
    return 55;
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

- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == 0)
        return NO;
    return YES;
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if([tableView numberOfRowsInSection:indexPath.section] != 2) {
            if([[CDManager sharedManager] deleteRingDataWithRingID:[NSString stringWithFormat:@"%ld", (long)currentRingID] andTimeStamp:[[[self.allAmountsSplitIntoSections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row - 1] objectForKey:@"date"]]) {
                
                [self loadAllAmountsSplitIntoSectionsArray];
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                
                [self.tableView beginUpdates];
                [self.tableView endUpdates];
                
                HistoryHeaderTableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:indexPath.section]];
                //[cell.circularProgressLabel setFrame:CGRectMake((cell.circularProgress.frame.size.width - 100) / 2, (cell.circularProgress.frame.size.height - 50) / 2, 100, 50)];
                
                double totalConsumed = 0;
                
                for(int i = 0; i < [(NSArray *)[self.allAmountsSplitIntoSections objectAtIndex:indexPath.section] count]; i++) {
                    totalConsumed += [[[[self.allAmountsSplitIntoSections objectAtIndex:indexPath.section] objectAtIndex:i] objectForKey:@"value"] doubleValue];
                }
                
                NSString *originalString = [[NSString alloc] init];
                NSMutableAttributedString *headerLabelText = [[NSMutableAttributedString alloc] init];
                if(self.view.frame.size.width <= 320) {
                    if(totalConsumed <= 9 && self.limit <= 9) {
                        double tempTotalConsumed = round(100 * totalConsumed) / 100;
                        double tempLimit = round(100 * self.limit) / 100;
                        originalString = [NSString stringWithFormat:@"You have\ndrank %.2f%@\nout of %.2f%@.", tempTotalConsumed, self.units, tempLimit, self.units];
                        
                        headerLabelText = [[NSMutableAttributedString alloc] initWithString:originalString];
                        [headerLabelText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17.0 weight:UIFontWeightSemibold] range:[originalString rangeOfString:[NSString stringWithFormat:@"%.2f%@", tempTotalConsumed, self.units]]];
                        if(totalConsumed > (self.limit * 0.90))
                            [headerLabelText addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:[originalString rangeOfString:[NSString stringWithFormat:@"%.2f%@", tempTotalConsumed, self.units]]];
                        [headerLabelText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17.0 weight:UIFontWeightSemibold] range:[originalString rangeOfString:[NSString stringWithFormat:@"%.2f%@", tempLimit, self.units]]];
                    } else if (totalConsumed <= 9 && self.limit > 9) {
                        double tempTotalConsumed = round(100 * totalConsumed) / 100;
                        int tempLimit = round(self.limit);
                        originalString = [NSString stringWithFormat:@"You have\ndrank %.2f%@\nout of %ld%@.", tempTotalConsumed, self.units, (long)tempLimit, self.units];
                        
                        headerLabelText = [[NSMutableAttributedString alloc] initWithString:originalString];
                        [headerLabelText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17.0 weight:UIFontWeightSemibold] range:[originalString rangeOfString:[NSString stringWithFormat:@"%.2f%@", tempTotalConsumed, self.units]]];
                        if(totalConsumed > (self.limit * 0.90))
                            [headerLabelText addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:[originalString rangeOfString:[NSString stringWithFormat:@"%.2f%@", tempTotalConsumed, self.units]]];
                        [headerLabelText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17.0 weight:UIFontWeightSemibold] range:[originalString rangeOfString:[NSString stringWithFormat:@"%ldf%@", (long)tempLimit, self.units]]];
                    } else if (totalConsumed > 9 && self.limit <= 9) {
                        int tempTotalConsumed = round(totalConsumed);
                        double tempLimit = round(100 * self.limit) / 100;
                        originalString = [NSString stringWithFormat:@"You have\ndrank %ld%@\nout of %.2f%@.", (long)tempTotalConsumed, self.units, tempLimit, self.units];
                        
                        headerLabelText = [[NSMutableAttributedString alloc] initWithString:originalString];
                        [headerLabelText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17.0 weight:UIFontWeightSemibold] range:[originalString rangeOfString:[NSString stringWithFormat:@"%ld%@", (long)tempTotalConsumed, self.units]]];
                        if(totalConsumed > (self.limit * 0.90))
                            [headerLabelText addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:[originalString rangeOfString:[NSString stringWithFormat:@"%ld%@", (long)tempTotalConsumed, self.units]]];
                        [headerLabelText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17.0 weight:UIFontWeightSemibold] range:[originalString rangeOfString:[NSString stringWithFormat:@"%.2f%@", tempLimit, self.units]]];
                    } else {
                        int tempTotalConsumed = round(totalConsumed);
                        int tempLimit = round(self.limit);
                        originalString = [NSString stringWithFormat:@"You have\ndrank %ld%@\nout of %ld%@.", (long)tempTotalConsumed, self.units, (long)tempLimit, self.units];
                        
                        headerLabelText = [[NSMutableAttributedString alloc] initWithString:originalString];
                        [headerLabelText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17.0 weight:UIFontWeightSemibold] range:[originalString rangeOfString:[NSString stringWithFormat:@"%ld%@", (long)tempTotalConsumed, self.units]]];
                        if(totalConsumed > (self.limit * 0.90))
                            [headerLabelText addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:[originalString rangeOfString:[NSString stringWithFormat:@"%ld%@", (long)tempTotalConsumed, self.units]]];
                        [headerLabelText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17.0 weight:UIFontWeightSemibold] range:[originalString rangeOfString:[NSString stringWithFormat:@"%ld%@", (long)tempLimit, self.units]]];
                    }
                } else {
                    if(totalConsumed <= 9 && self.limit <= 9) {
                        double tempTotalConsumed = round(100 * totalConsumed) / 100;
                        double tempLimit = round(100 * self.limit) / 100;
                        originalString = [NSString stringWithFormat:@"You have drank %.2f%@\nout of %.2f%@.", tempTotalConsumed, self.units, tempLimit, self.units];
                        
                        headerLabelText = [[NSMutableAttributedString alloc] initWithString:originalString];
                        [headerLabelText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17.0 weight:UIFontWeightSemibold] range:[originalString rangeOfString:[NSString stringWithFormat:@"%.2f%@", tempTotalConsumed, self.units]]];
                        if(totalConsumed > (self.limit * 0.90))
                            [headerLabelText addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:[originalString rangeOfString:[NSString stringWithFormat:@"%.2f%@", tempTotalConsumed, self.units]]];
                        [headerLabelText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17.0 weight:UIFontWeightSemibold] range:[originalString rangeOfString:[NSString stringWithFormat:@"%.2f%@", tempLimit, self.units]]];
                    } else if (totalConsumed <= 9 && self.limit > 9) {
                        double tempTotalConsumed = round(100 * totalConsumed) / 100;
                        int tempLimit = round(self.limit);
                        originalString = [NSString stringWithFormat:@"You have drank %.2f%@\nout of %ld%@.", tempTotalConsumed, self.units, (long)tempLimit, self.units];
                        
                        headerLabelText = [[NSMutableAttributedString alloc] initWithString:originalString];
                        [headerLabelText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17.0 weight:UIFontWeightSemibold] range:[originalString rangeOfString:[NSString stringWithFormat:@"%.2f%@", tempTotalConsumed, self.units]]];
                        if(totalConsumed > (self.limit * 0.90))
                            [headerLabelText addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:[originalString rangeOfString:[NSString stringWithFormat:@"%.2f%@", tempTotalConsumed, self.units]]];
                        [headerLabelText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17.0 weight:UIFontWeightSemibold] range:[originalString rangeOfString:[NSString stringWithFormat:@"%ldf%@", (long)tempLimit, self.units]]];
                    } else if (totalConsumed > 9 && self.limit <= 9) {
                        int tempTotalConsumed = round(totalConsumed);
                        double tempLimit = round(100 * self.limit) / 100;
                        originalString = [NSString stringWithFormat:@"You have drank %ld%@\nout of %.2f%@.", (long)tempTotalConsumed, self.units, tempLimit, self.units];
                        
                        headerLabelText = [[NSMutableAttributedString alloc] initWithString:originalString];
                        [headerLabelText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17.0 weight:UIFontWeightSemibold] range:[originalString rangeOfString:[NSString stringWithFormat:@"%ld%@", (long)tempTotalConsumed, self.units]]];
                        if(totalConsumed > (self.limit * 0.90))
                            [headerLabelText addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:[originalString rangeOfString:[NSString stringWithFormat:@"%ld%@", (long)tempTotalConsumed, self.units]]];
                        [headerLabelText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17.0 weight:UIFontWeightSemibold] range:[originalString rangeOfString:[NSString stringWithFormat:@"%.2f%@", tempLimit, self.units]]];
                    } else {
                        int tempTotalConsumed = round(totalConsumed);
                        int tempLimit = round(self.limit);
                        originalString = [NSString stringWithFormat:@"You have drank %ld%@\nout of %ld%@.", (long)tempTotalConsumed, self.units, (long)tempLimit, self.units];
                        
                        headerLabelText = [[NSMutableAttributedString alloc] initWithString:originalString];
                        [headerLabelText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17.0 weight:UIFontWeightSemibold] range:[originalString rangeOfString:[NSString stringWithFormat:@"%ld%@", (long)tempTotalConsumed, self.units]]];
                        if(totalConsumed > (self.limit * 0.90))
                            [headerLabelText addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:[originalString rangeOfString:[NSString stringWithFormat:@"%ld%@", (long)tempTotalConsumed, self.units]]];
                        [headerLabelText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17.0 weight:UIFontWeightSemibold] range:[originalString rangeOfString:[NSString stringWithFormat:@"%ld%@", (long)tempLimit, self.units]]];
                    }
                }
                
                int ringAngle = 0;
                double percent = 0;
                
                if(self.limit != 0) {
                    ringAngle = [[CDManager sharedManager] getRingAngleForAmount:totalConsumed andLimit:self.limit];
                    percent = ((double)totalConsumed/(double)self.limit) * 100.0;
                }
                
                [cell.circularProgress animateToAngle:ringAngle duration:1.0 relativeDuration:NO completion:nil];
                [cell.circularProgressLabel setText:[NSString stringWithFormat:@"%ld%%", (long)percent]];
                [cell.circularProgress animateToAngle:ringAngle duration:1.0 relativeDuration:NO completion:nil];
                
                [cell.label setAttributedText:headerLabelText];
            }
        } else {
            if([[CDManager sharedManager] deleteRingDataWithRingID:[NSString stringWithFormat:@"%ld", (long)currentRingID] andTimeStamp:[[[self.allAmountsSplitIntoSections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row - 1] objectForKey:@"date"]]) {
                [tableView beginUpdates];
                
                [self loadAllAmountsSplitIntoSectionsArray];
                //[tableView deleteRowsAtIndexPaths:@[indexPath, [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationFade];
                
                [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
                [tableView endUpdates];
                
                if(tableView.numberOfSections == 0) {
                    
                    
//                    [tableView beginUpdates];
//                    [tableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
                    self.noCellsExistSections = YES;
                    //[tableView endUpdates];
                    
                    
                    
                    //[tableView beginUpdates];
//                    [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                    self.noCellsExistCells = YES;
                    ///[tableView endUpdates];
                    
                    [tableView reloadData];
                }
            }
        }
    }
}

- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == 0)
        return UITableViewCellEditingStyleNone;
    return UITableViewCellEditingStyleDelete;
}

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
