//
//  GetPartyVisitHistoryViewController.h
//  Order
//
//  Created by wenwang wang on 2019/3/19.
//  Copyright © 2019 凯东源. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GetPartyVisitItemModel.h"

@interface GetPartyVisitHistoryViewController : UIViewController

@property (strong, nonatomic) NSString *FartherPartyID;

@property (strong, nonatomic) GetPartyVisitItemModel *pvItemM;

@end
