//
//  TimeLabel.h
//  Order
//
//  Created by 凯东源 on 17/6/8.
//  Copyright © 2017年 凯东源. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimeLabel : UILabel

@property (strong, nonatomic) NSDate *date;

@property (copy, nonatomic) NSString *time;

@property (copy, nonatomic) NSString *startTime;

@property (copy, nonatomic) NSString *endTime;

@end
