//
//  YBNeighborLocationCell.h
//  9999md-doctor
//
//  Created by 周英斌 on 2017/6/14.
//  Copyright © 2017年 ZhouYingbin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BMKPoiInfo;
@interface YBNeighborLocationCell : UITableViewCell

- (void)configureForData:(BMKPoiInfo *)data keyword:(NSString *)keyword;

@end
