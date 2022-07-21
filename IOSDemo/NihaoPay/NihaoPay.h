//
//  NihaoPay.h
//  IOSDemo
//
//  Created by Sherry on 21/03/2017.
//  Copyright © 2017 Sherry. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NihaoPay : NSObject

@property(nonatomic, copy) NSString * nhpApiUrl;// NihaoPay Api Url
@property(nonatomic, copy) NSString * nhpApiToken;// NihaoPay Api Token

@property(nonatomic, copy) NSString * vendor;   // app pay
@property(nonatomic, copy) NSString * reference;
@property(nonatomic, copy) NSString * amount;
@property(nonatomic, copy) NSString * currency;
@property(nonatomic, copy) NSString * ipnUrl;
@property(nonatomic, copy) NSString * wechatAppID;
@property(nonatomic, copy) NSString * desc;//Optional
@property(nonatomic, copy) NSString * note; //Optional
@property(nonatomic, copy) NSString * ostype;

-(id) initWithAPIinfo:(NSString *) apiUrl addToken:(NSString *) apiToken;

- (NSDictionary *)appPay;
- (NSDictionary *)apsPay;

- (NSDictionary *)getPayResult;

@end
