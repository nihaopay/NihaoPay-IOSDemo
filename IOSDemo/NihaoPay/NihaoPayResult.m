//
//  NihaoPayResult.m
//  IOSDemo
//
//  Created by Sherry on 21/03/2017.
//  Copyright © 2017 Sherry. All rights reserved.
//

#import "NihaoPayResult.h"

@implementation NihaoPayResult

-(id) initWithAlipayReturn:(NSDictionary *)apResultDic
{
    self= [super init];
    NSLog(@"AliPay client return reslut = %@",apResultDic);
    
    NSInteger resultStatus=[apResultDic[@"resultStatus"] integerValue];
    switch (resultStatus) {
        case 9000:
            self.clientStatus=@"success";
            self.needQuery=@"true";
    break;
        case 8000:
        case 6004:
            self.clientStatus=@"Processing";
            self.needQuery=@"true";
            break;
        case 4000:
            self.clientStatus=@"failed";
            self.needQuery=@"false";
            break;
        case 6001:
            self.clientStatus=@"canceled";
            self.needQuery=@"false";
            break;
        case 6002:
            self.clientStatus=@"error";
            self.needQuery=@"true";
            break;
        default:
            self.clientStatus=@"failed";
            self.needQuery=@"false";
            break;
    }
    return self;
}


@end
