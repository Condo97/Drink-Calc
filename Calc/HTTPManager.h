//
//  HTTPManager.h
//  Calc
//
//  Created by Alex Coundouriotis on 6/18/17.
//  Copyright © 2017 ACApplications. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HTTPManager : NSObject

+ (id)sharedManager;
- (NSDictionary *) getJSONFromURL:(NSString *)url withArguments:(NSString *)arguments,...;

@end
