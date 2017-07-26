//
//  ArchiverManager.h
//  Calc
//
//  Created by Alex Coundouriotis on 6/18/17.
//  Copyright © 2017 ACApplications. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ArchiverManager : NSObject

+ (id)sharedManager;
- (void) saveDataToDisk:(NSData *)data withFileName:(NSString *)fileName;
- (NSData *) loadDataFromDiskWithFileName:(NSString *)fileName;

@end
