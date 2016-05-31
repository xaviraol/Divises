//
//  ConnectionManager.m
//  Divises
//
//  Created by Xavier Ramos Oliver on 29/5/16.
//  Copyright © 2016 Xavier Ramos. All rights reserved.
//

#import "ConnectionManager.h"
#import "AFNetworking.h"

@implementation ConnectionManager


-(void) downloadCountriesCurrency{
    
    static NSString * const BaseURLString = @"http://www.apilayer.net/api/live?access_key=9cd66e5ae1e9b2d10f0380df9ee190fb&format=1";
    
    NSURL *url = [NSURL URLWithString:BaseURLString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary  *currencies = responseObject;
        NSDictionary *quotes = [currencies objectForKey:@"quotes"];
        
        NSMutableDictionary *currencyUpdated = [NSMutableDictionary new];
        
        for (NSString *key in [quotes allKeys]) {
            NSRange range = NSMakeRange(3,3);
            NSString *newKey = [key substringWithRange:range];
            
            NSNumber *value = [quotes objectForKey:key];
            [currencyUpdated setValue:value forKey:newKey];
        }
        //NSLog(@"CurrencyUpdated: %@",currencyUpdated);
        //EDIT: fer tot això del reload data un cop la operació del block en qüestió s'ha acabat.
        [[NSUserDefaults standardUserDefaults] setValue:currencyUpdated forKey:@"currencyUpdated"];
        //TODO. problemes aquí perquè un cop s'hagi descarregat el currency hem d'avisar a la taula perquè fagi un [reload data]
        
//        [UIView transitionWithView:_currenciesTableView
//                          duration:0.7f
//                           options:UIViewAnimationOptionTransitionCrossDissolve
//                        animations:^(void) {
//        
//                            [_currenciesTableView reloadData];
//                        } completion:NULL];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error downloading data");
    }];
    [operation start];
}


@end
