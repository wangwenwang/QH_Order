//
//  CondModel.h
//  Order
//
//  Created by wenwang wang on 2019/2/15.
//  Copyright © 2019 凯东源. All rights reserved.
//

#import <Foundation/Foundation.h>


// 查询条件
@interface CondModel : NSObject

// 显示名称
@property (copy, nonatomic) NSString *name;

// 查询类型
@property (copy, nonatomic) NSString *type;

// 传服务器
@property (copy, nonatomic) NSString *key;

@end
