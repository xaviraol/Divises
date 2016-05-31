//
//  CurrencyDataHelper.m
//  Divises
//
//  Created by Xavier Ramos Oliver on 31/5/16.
//  Copyright © 2016 Xavier Ramos. All rights reserved.
//

#import "CurrencyDataHelper.h"

@implementation CurrencyDataHelper

//TODO: practicament fer el mateix que en el sense-ios-sdk a l'hoar de passar de JSON a dictionary.

- (NSDictionary *)parseDataFromJsonsToDictionariesfromFilePath:(NSString*)filepath andFormat:(NSString *)formatType{
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:filepath ofType:formatType];
    
    NSData* data = [NSData dataWithContentsOfFile:filePath];
    __autoreleasing NSError* error = nil;
    id result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    NSDictionary *output = result;
    
    return  output;
}

@end
