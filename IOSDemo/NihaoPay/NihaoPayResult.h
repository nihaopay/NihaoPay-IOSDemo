//
//  NihaoPayResult.h
//  IOSDemo
//
//  Created by Sherry on 21/03/2017.
//  Copyright © 2017 Sherry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NihaoPayResult : NSObject


@property(nonatomic, copy) NSString * clientStatus;
@property(nonatomic, copy) NSString * needQuery;

- (id) initWithAlipayReturn:(NSDictionary *)apResultDic;


@end
