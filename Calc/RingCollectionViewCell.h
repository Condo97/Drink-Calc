//
//  RingCollectionViewCell.h
//  Calc
//
//  Created by Alex Coundouriotis on 6/11/17.
//  Copyright © 2017 ACApplications. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Calc-Swift.h"

@interface RingCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet KDCircularProgress *progressRing;

@end
