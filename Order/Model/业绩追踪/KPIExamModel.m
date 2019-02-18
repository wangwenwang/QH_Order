//
//  KPIExamModel.m
//  Order
//
//  Created by wenwang wang on 2019/2/15.
//  Copyright © 2019 凯东源. All rights reserved.
//

#import "KPIExamModel.h"


NSString *const kKPIExamModelAmountMoney = @"AmountMoney";
NSString *const kKPIExamModelCompleteAmountMoney = @"CompleteAmountMoney";
NSString *const kKPIExamModelCompleteSalesVolume = @"CompleteSalesVolume";
NSString *const kKPIExamModelSalesVolume = @"SalesVolume";


@implementation KPIExamModel

/**
 * Instantiate the instance using the passed dictionary values to set the properties values
 */

-(instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if(![dictionary[kKPIExamModelAmountMoney] isKindOfClass:[NSNull class]]){
        self.amountMoney = dictionary[kKPIExamModelAmountMoney];
    }
    if(![dictionary[kKPIExamModelCompleteAmountMoney] isKindOfClass:[NSNull class]]){
        self.completeAmountMoney = dictionary[kKPIExamModelCompleteAmountMoney];
    }
    if(![dictionary[kKPIExamModelCompleteSalesVolume] isKindOfClass:[NSNull class]]){
        self.completeSalesVolume = dictionary[kKPIExamModelCompleteSalesVolume];
    }
    if(![dictionary[kKPIExamModelSalesVolume] isKindOfClass:[NSNull class]]){
        self.salesVolume = dictionary[kKPIExamModelSalesVolume];
    }
    return self;
}


/**
 * Returns all the available property values in the form of NSDictionary object where the key is the approperiate json key and the value is the value of the corresponding property
 */
-(NSDictionary *)toDictionary
{
    NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
    if(self.amountMoney != nil){
        dictionary[kKPIExamModelAmountMoney] = self.amountMoney;
    }
    if(self.completeAmountMoney != nil){
        dictionary[kKPIExamModelCompleteAmountMoney] = self.completeAmountMoney;
    }
    if(self.completeSalesVolume != nil){
        dictionary[kKPIExamModelCompleteSalesVolume] = self.completeSalesVolume;
    }
    if(self.salesVolume != nil){
        dictionary[kKPIExamModelSalesVolume] = self.salesVolume;
    }
    return dictionary;
    
}

/**
 * Implementation of NSCoding encoding method
 */
/**
 * Returns all the available property values in the form of NSDictionary object where the key is the approperiate json key and the value is the value of the corresponding property
 */
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    if(self.amountMoney != nil){
        [aCoder encodeObject:self.amountMoney forKey:kKPIExamModelAmountMoney];
    }
    if(self.completeAmountMoney != nil){
        [aCoder encodeObject:self.completeAmountMoney forKey:kKPIExamModelCompleteAmountMoney];
    }
    if(self.completeSalesVolume != nil){
        [aCoder encodeObject:self.completeSalesVolume forKey:kKPIExamModelCompleteSalesVolume];
    }
    if(self.salesVolume != nil){
        [aCoder encodeObject:self.salesVolume forKey:kKPIExamModelSalesVolume];
    }
    
}

/**
 * Implementation of NSCoding initWithCoder: method
 */
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    self.amountMoney = [aDecoder decodeObjectForKey:kKPIExamModelAmountMoney];
    self.completeAmountMoney = [aDecoder decodeObjectForKey:kKPIExamModelCompleteAmountMoney];
    self.completeSalesVolume = [aDecoder decodeObjectForKey:kKPIExamModelCompleteSalesVolume];
    self.salesVolume = [aDecoder decodeObjectForKey:kKPIExamModelSalesVolume];
    return self;
    
}

/**
 * Implementation of NSCopying copyWithZone: method
 */
- (instancetype)copyWithZone:(NSZone *)zone
{
    KPIExamModel *copy = [KPIExamModel new];
    
    copy.amountMoney = [self.amountMoney copy];
    copy.completeAmountMoney = [self.completeAmountMoney copy];
    copy.completeSalesVolume = [self.completeSalesVolume copy];
    copy.salesVolume = [self.salesVolume copy];
    
    return copy;
}

@end
