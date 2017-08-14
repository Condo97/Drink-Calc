//
//  ArchiverManager.m
//  Calc
//
//  Created by Alex Coundouriotis on 6/18/17.
//  Copyright © 2017 ACApplications. All rights reserved.
//

#import "ArchiverManager.h"

#define DEFAULT_PATH @"~/Documents/"

@implementation ArchiverManager

+ (id) sharedManager {
    static ArchiverManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (void) saveDataToDisk:(NSData *)data withFileName:(NSString *)fileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    
    //NSString *thePath = @"~/Documents/data";
    NSString *thePath = [documentsDirectory stringByAppendingPathComponent:fileName];
    
    thePath = [thePath stringByExpandingTildeInPath];
    
    [NSKeyedArchiver archiveRootObject:data toFile:thePath];
}

- (NSData *) loadDataFromDiskWithFileName:(NSString *)fileName {
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    
    //NSString *thePath = @"~/Documents/data";
    NSString *thePath = [documentsDirectory stringByAppendingPathComponent:fileName];

    return [NSKeyedUnarchiver unarchiveObjectWithFile:thePath];
}

@end
