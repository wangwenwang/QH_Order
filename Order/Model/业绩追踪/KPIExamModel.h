//
//  KPIExamModel.h
//  Order
//
//  Created by wenwang wang on 2019/2/15.
//  Copyright © 2019 凯东源. All rights reserved.
//

#import <Foundation/Foundation.h>

//{
//    "SalesVolume": "881",
//    "AmountMoney": "881",
//    "CompleteSalesVolume": "881",
//    "CompleteAmountMoney": "星期一"
//}

@interface KPIExamModel : NSObject

@property (nonatomic, strong) NSString * amountMoney;
@property (nonatomic, strong) NSString * completeAmountMoney;
@property (nonatomic, strong) NSString * completeSalesVolume;
@property (nonatomic, strong) NSString * salesVolume;

-(instancetype)initWithDictionary:(NSDictionary *)dictionary;

-(NSDictionary *)toDictionary;

@end
