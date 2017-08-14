//
//  EditProfileTableViewController.m
//  Calc
//
//  Created by Alex Coundouriotis on 7/23/17.
//  Copyright © 2017 ACApplications. All rights reserved.
//

#import "EditProfileTableViewController.h"
#import "HealthKitManager.h"
#import "JSONManager.h"
#import "ArchiverManager.h"
#import "CDManager.h"
#import "StoreKitManager.h"

@interface EditProfileTableViewController ()

@property (strong, nonatomic) NSMutableArray *cellsShowing;
@property (strong, nonatomic) NSDate *birthdate;
@property (nonatomic) int weight;
@property (nonatomic) int gender;
@property (nonatomic) int heightInInches;
@property (nonatomic) int feet;
@property (nonatomic) int inches;

@end

@implementation EditProfileTableViewController

@synthesize currentRingName;

- (void) viewDidLoad {
    [super viewDidLoad];
    
    self.cellsShowing = [[NSMutableArray alloc] initWithObjects:@NO, @NO, @NO, @NO, nil];
    self.birthdate = [[NSDate alloc] init];
    self.weight = 0;
    self.gender = 0;
    self.heightInInches = 0;
    
    NSDictionary *json = (NSDictionary *)[NSKeyedUnarchiver unarchiveObjectWithData:[[ArchiverManager sharedManager] loadDataFromDiskWithFileName:@"allJson"]];
    UIColor *currentTintColor = [[CDManager sharedManager] colorWithHexString:[[[JSONManager sharedManager] getRingNamesAsDictionaryWithJSONDictionary:json] objectForKey:currentRingName]];
    
    [self.updateWithHealthAppValuesButtonOutlet setTitleColor:currentTintColor forState:UIControlStateNormal];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.birthdate = [[NSUserDefaults standardUserDefaults] objectForKey:@"userBirthdate"];
    self.heightInInches = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"userHeightInInches"];
    self.weight = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"userWeight"];
    self.gender = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"userGender"];
    self.feet = self.heightInInches/12;
    self.inches = self.heightInInches%12;
    
    [self.birthdatePicker setDate:self.birthdate animated:NO];
    [self.genderPicker selectRow:self.gender inComponent:0 animated:NO];
    [self.heightPicker selectRow:self.feet-1 inComponent:0 animated:NO];
    [self.heightPicker selectRow:self.inches inComponent:1 animated:NO];
    [self.genderPicker selectRow:self.gender inComponent:0 animated:NO];
    
    UITableViewCell *birthdateCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    [birthdateCell.detailTextLabel setText:[NSDateFormatter localizedStringFromDate:self.birthdate dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle]];
    UITableViewCell *genderCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath  indexPathForRow:6 inSection:1]];
    [genderCell.detailTextLabel setText:[self getGenderString]];
    UITableViewCell *heightCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:1]];
    [heightCell.detailTextLabel setText:[NSString stringWithFormat:@"%ld ft, %ld in", (long)self.feet, (long)self.inches]];
    UITableViewCell *weightCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:1]];
    [weightCell.detailTextLabel setText:[NSString stringWithFormat:@"%ld", (long)self.weight]];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *) getGenderString {
    if(self.gender == 0)
        return @"Not Specified";
    if(self.gender == 2)
        return @"Male";
    if(self.gender == 3)
        return @"Other";
    return @"Female";
}

#pragma mark - Table view data source

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 1) {
        if(indexPath.row % 2 == 0)
            return 55;
        else {
            if([[self.cellsShowing objectAtIndex:(indexPath.row-1)/2] isEqual:@YES])
                return 150;
            else
                return 0;
        }
    }
    return 55;
}

#pragma  mark - Table view delegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO];
    
    if(indexPath.section == 1) {
        for(int i = 0; i < self.cellsShowing.count; i++) {
            if(indexPath.row / 2 == i) {
                if([[self.cellsShowing objectAtIndex:i] isEqual:@YES])
                    [self.cellsShowing setObject:@NO atIndexedSubscript:i];
                else
                    [self.cellsShowing setObject:@YES atIndexedSubscript:i];
            } else
                [self.cellsShowing setObject:@NO atIndexedSubscript:i];
        }
        
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    }
}

- (IBAction) birthdatePickerValueChanged:(id)sender {
    self.birthdate = self.birthdatePicker.date;
    
    UITableViewCell *birthDateCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    [birthDateCell.detailTextLabel setText:[NSDateFormatter localizedStringFromDate:self.birthdate dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle]];
}

- (IBAction) saveButton:(id)sender {
    if(self.weight != 0 && (self.feet != 0 || self.inches != 0) && self.birthdate != nil) {
        NSDateComponents *ageComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:self.birthdate toDate:[NSDate date] options:0];
        
        self.heightInInches = (self.feet * 12) + self.inches;
        
        [[NSUserDefaults standardUserDefaults] setInteger:self.weight forKey:@"userWeight"];
        [[NSUserDefaults standardUserDefaults] setInteger:self.heightInInches forKey:@"userHeightInInches"];
        [[NSUserDefaults standardUserDefaults] setInteger:ageComponents.year forKey:@"userAge"];
        [[NSUserDefaults standardUserDefaults] setObject:self.birthdate forKey:@"userBirthdate"];
        
        [[NSUserDefaults standardUserDefaults] setInteger:self.gender forKey:@"userGender"];
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"initialSetupComplete"
         ];
        
        if(self.sliderIncrementsSegmentedControl.selectedSegmentIndex == 0)
            [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"sliderIncrements"];
        else if(self.sliderIncrementsSegmentedControl.selectedSegmentIndex == 1)
            [[NSUserDefaults standardUserDefaults] setInteger:2 forKey:@"sliderIncrements"];
        else if(self.sliderIncrementsSegmentedControl.selectedSegmentIndex == 2)
            [[NSUserDefaults standardUserDefaults] setInteger:4 forKey:@"sliderIncrements"];
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - Picker view delegate

- (NSInteger) numberOfComponentsInPickerView:(nonnull UIPickerView *)pickerView {
    if([pickerView isEqual:self.heightPicker]) {
        return 2;
    }
    return 1;
}

- (NSInteger) pickerView:(nonnull UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if([pickerView isEqual:self.weightPicker]) {
        return 1000;
    } else if ([pickerView isEqual:self.heightPicker]) {
        if(component == 0) {
            return 9;
        } else {
            return 13;
        }
    }
    return 4;
}

- (NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if([pickerView isEqual:self.weightPicker]) {
        NSString *s = @"";
        if(row != 1)
            s = @"s";
        return [NSString stringWithFormat:@"%ld lb%@", (long)row, s];
    } else if ([pickerView isEqual:self.heightPicker]) {
        if(component == 0) {
            return [NSString stringWithFormat:@"%ld ft", (long)row+1];
        } else {
            return [NSString stringWithFormat:@"%ld in", (long)row];
        }
    } else {
        NSArray *gender = @[@"Unspecified", @"Female", @"Male", @"Other"];
        return [NSString stringWithFormat:@"%@", [gender objectAtIndex:row]];
    }
}

- (void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if ([pickerView isEqual:self.heightPicker]) {
        if(component == 0)
            self.feet = (int)row + 1;
        else
            self.inches = (int)row;
        
        UITableViewCell *heightCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:1]];
        [heightCell.detailTextLabel setText:[NSString stringWithFormat:@"%ld ft, %ld in", (long)self.feet, (long)self.inches]];
    } else if([pickerView isEqual:self.weightPicker]) {
        self.weight = (int)row;
        
        UITableViewCell *weightCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:1]];
        [weightCell.detailTextLabel setText:[NSString stringWithFormat:@"%ld", (long)self.weight]];
    } else if ([pickerView isEqual:self.genderPicker]) {
        self.gender = (int)row;
        
        UITableViewCell *genderCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:6 inSection:1]];
        [genderCell.detailTextLabel setText:[self getGenderString]];
    }
}

- (IBAction) updateWithHealthAppValuesButton:(id)sender {
    [[HealthKitManager sharedManager] requestAuthorizationWithCompletion:^(BOOL completion){
        if(completion) {
            NSLog(@"Authorized HealthKit!");
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if([[HealthKitManager sharedManager] getBirthdate] != nil) {
                    self.birthdate = [[HealthKitManager sharedManager] getBirthdate];
                    [self.birthdatePicker setDate:self.birthdate animated:NO];
                    
                    UITableViewCell *birthdateCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
                    [birthdateCell.detailTextLabel setText:[NSDateFormatter localizedStringFromDate:self.birthdate dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle]];
                }
                
                if([[HealthKitManager sharedManager] getGender] != 0) {
                    self.gender = [[HealthKitManager sharedManager] getGender];
                    [self.genderPicker selectRow:self.gender inComponent:0 animated:NO];
                    
                    UITableViewCell *genderCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath  indexPathForRow:6 inSection:1]];
                    [genderCell.detailTextLabel setText:[self getGenderString]];
                }
            });
            
            [[HealthKitManager sharedManager] getHeightWithCompletion:^(BOOL successful, double value){
                self.heightInInches = value;
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(value != 0) {
                        UITableViewCell *heightCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:1]];
                        self.feet = self.heightInInches/12;
                        self.inches = self.heightInInches%12;
                        [heightCell.detailTextLabel setText:[NSString stringWithFormat:@"%ld ft, %ld in", (long)self.feet, (long)self.inches]];
                        [self.heightPicker selectRow:self.feet-1 inComponent:0 animated:NO];
                        [self.heightPicker selectRow:self.inches inComponent:1 animated:NO];
                    }
                });
                
                [[HealthKitManager sharedManager] getWeightWithCompletion:^(BOOL successful, double value){
                    self.weight = value;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if(value != 0) {
                            UITableViewCell *weightCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:1]];
                            [weightCell.detailTextLabel setText:[NSString stringWithFormat:@"%ld", (long)self.weight]];
                            [self.weightPicker selectRow:self.weight inComponent:0 animated:NO];
                        }
                    });
                }];
            }];
        } else {
            NSLog(@"HITHERE");
        }
    }];
}

- (IBAction) restorePurchasesButton:(id)sender {
    [[StoreKitManager sharedManager] restorePurchases];
}
- (IBAction) unwindToEditProfile:(UIStoryboardSegue *)segue {
}

@end

