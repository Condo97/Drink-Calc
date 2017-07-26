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
@property (strong, nonatomic) NSMutableArray *allAmountsSplitIntoSections;
@property (strong, nonatomic) NSString *units;
@property (strong, nonatomic) UIColor *currentColor;
@property (nonatomic) int limit;

@end

@implementation HistoryTableViewController

@synthesize currentRingName, currentRingID;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSMutableArray *differentDatesArray = [[NSMutableArray alloc] init];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDictionary *json = [NSKeyedUnarchiver unarchiveObjectWithData:[[ArchiverManager sharedManager] loadDataFromDiskWithFileName:@"allJson"]];
    self.units = [[[JSONManager sharedManager] getRingMeasurementTypesBeforeSlashAsDictionaryWithJSONDictionary:json] objectForKey:currentRingName];
    self.limit = [(NSNumber *)[(NSDictionary *)[[NSUserDefaults standardUserDefaults] objectForKey:@"userLimit"] objectForKey:currentRingName] intValue];
    self.currentColor = [[CDManager sharedManager] colorWithHexString:[[[JSONManager sharedManager] getRingNamesAsDictionaryWithJSONDictionary:json] objectForKey:currentRingName]];
    
    self.allAmountsSplitIntoSections = [[NSMutableArray alloc] init];
    self.allAmountsForCurrentRing = [[CDManager sharedManager] getAllRingDataWithRingDataArray:[[CDManager sharedManager] getDataArrayForEntityNamed:@"Ring"] andFilterRingID:[NSString stringWithFormat:@"%ld", (long)currentRingID]];
    
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
        NSArray *finalTempArray = [moreTempArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
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
    
    self.allAmountsSplitIntoSections = (NSMutableArray *)[[tempArray reverseObjectEnumerator] allObjects];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSDate *) getDayForArray:(NSArray *)array {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:[[array objectAtIndex:0] valueForKey:@"date"]];
    return [calendar dateFromComponents:dateComponents];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.allAmountsSplitIntoSections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [(NSArray *)[self.allAmountsSplitIntoSections objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == 0) {
        HistoryHeaderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"headerCell" forIndexPath:indexPath];
        UILabel *circularProgressLabel = [[UILabel alloc] initWithFrame:CGRectMake((cell.circularProgress.frame.size.width - 100) / 2, (cell.circularProgress.frame.size.height - 50) / 2, 100, 50)];
        int totalConsumed = 0;
        
        for(int i = 0; i < [(NSArray *)[self.allAmountsSplitIntoSections objectAtIndex:indexPath.section] count]; i++) {
            totalConsumed += (int)[[[self.allAmountsSplitIntoSections objectAtIndex:indexPath.section] objectAtIndex:i] objectForKey:@"value"];
        }
        
        NSString *originalString = [NSString stringWithFormat:@"You have drank %ld out of %ld.", (long)totalConsumed, (long)self.limit];
        NSMutableAttributedString *headerLabelText = [[NSMutableAttributedString alloc] initWithString:originalString];
        [headerLabelText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:25.0 weight:UIFontWeightSemibold] range:[originalString rangeOfString:[NSString stringWithFormat:@"%ld", (long)totalConsumed]]];
        
        if(totalConsumed > (self.limit * 0.90))
            [headerLabelText addAttribute:NSStrokeColorAttributeName value:[UIColor redColor] range:[originalString rangeOfString:[NSString stringWithFormat:@"%ld", (long)totalConsumed]]];
        
        [headerLabelText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:25.0 weight:UIFontWeightSemibold] range:[originalString rangeOfString:[NSString stringWithFormat:@"%ld", (long)self.limit]]];
        
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
        
        [circularProgressLabel setFont:[UIFont systemFontOfSize:27.0]];
        [circularProgressLabel setTextAlignment:NSTextAlignmentCenter];
        [circularProgressLabel setAdjustsFontSizeToFitWidth:YES];
        [circularProgressLabel setMinimumScaleFactor:0.5];
        
        int ringAngle = [[CDManager sharedManager] getRingAngleForAmount:totalConsumed andLimit:self.limit];
        int percent = totalConsumed/self.limit;
        
        [circularProgressLabel setText:[NSString stringWithFormat:@"%ld", (long)percent]];
        [cell.circularProgress addSubview:circularProgressLabel];
        [cell.circularProgress animateToAngle:ringAngle duration:1.0 relativeDuration:NO completion:nil];
        
        [cell.label setAttributedText:headerLabelText];
        
        return cell;
    }
    
    HistoryStandardTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"standardCell" forIndexPath:indexPath];
    
    [cell.headerLabel setText:@"Drink Type"];
    [cell.subtitleLabel setText:[NSString stringWithFormat:@"%@%@", [NSDateFormatter localizedStringFromDate:(NSDate *)[[self.allAmountsSplitIntoSections objectAtIndex:indexPath.row] objectForKey:@"date"] dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle], self.units]];
    [cell.detailLabel setText:[NSString stringWithFormat:@"%ld", (long)[[self.allAmountsSplitIntoSections objectAtIndex:indexPath.row] objectForKey:@"value"]]];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
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
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
